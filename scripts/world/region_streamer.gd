extends Node3D

signal region_changed(coord: Vector2i)
signal streaming_status(text: String)

@export var region_size := 80.0
@export var active_radius := 1
@export var world_seed := 777777

var loaded_regions: Dictionary = {}
var discovered_regions: Dictionary = {}
var region_scene: PackedScene
var current_coord := Vector2i(0, 0)
var loading_started := false

func _ready() -> void:
	add_to_group("region_streamer")
	ResourceLoader.load_threaded_request("res://scenes/world/Region.tscn")
	streaming_status.emit("Chargement du monde…")

func _process(_delta: float) -> void:
	if not loading_started:
		var status: int = ResourceLoader.load_threaded_get_status("res://scenes/world/Region.tscn")
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_resource: Resource = ResourceLoader.load_threaded_get("res://scenes/world/Region.tscn")
			if loaded_resource is PackedScene:
				region_scene = loaded_resource as PackedScene
			else:
				loading_started = true
				return
			loading_started = true
			var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
			current_coord = world_to_region(player.global_position) if player else Vector2i.ZERO
			_sync_regions()
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			loading_started = true
			streaming_status.emit("Streaming indisponible.")
			return
	if not loading_started or region_scene == null:
		return
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var next_coord := world_to_region(player.global_position)
	if next_coord != current_coord:
		current_coord = next_coord
		_sync_regions()
		region_changed.emit(current_coord)
	streaming_status.emit("Région %d,%d • %d régions actives" % [current_coord.x, current_coord.y, loaded_regions.size()])

func world_to_region(pos: Vector3) -> Vector2i:
	return Vector2i(floori(pos.x / region_size), floori(pos.z / region_size))

func _sync_regions() -> void:
	var desired: Dictionary = {}
	for dz in range(-active_radius, active_radius + 1):
		for dx in range(-active_radius, active_radius + 1):
			var c := current_coord + Vector2i(dx, dz)
			if c == Vector2i.ZERO:
				continue
			desired[_key(c)] = c
			if not loaded_regions.has(_key(c)):
				_load_region(c)
	for key in loaded_regions.keys():
		if not desired.has(key):
			var old: Node = loaded_regions[key]
			if is_instance_valid(old):
				old.queue_free()
			loaded_regions.erase(key)
	streaming_status.emit("Monde ouvert : streaming actif.")

func _load_region(c: Vector2i) -> void:
	var region: Node3D = region_scene.instantiate() as Node3D
	if region == null:
		return
	region.name = "Region_%d_%d" % [c.x, c.y]
	add_child(region)
	region.call("setup", c, region_size, world_seed)
	loaded_regions[_key(c)] = region
	discovered_regions[_key(c)] = {"x":c.x, "z":c.y}

func _key(c: Vector2i) -> String:
	return "%d:%d" % [c.x, c.y]

func serialize_state() -> Dictionary:
	return {"current_region":[current_coord.x, current_coord.y],"discovered_regions":discovered_regions}

func restore_state(data: Dictionary) -> void:
	var discovered = data.get("discovered_regions", {})
	if typeof(discovered) == TYPE_DICTIONARY:
		discovered_regions = discovered
