extends Node

const MIX_RATE := 11025.0
var music_player: AudioStreamPlayer
var music_playback: AudioStreamGeneratorPlayback
var music_phase := 0.0
var music_time := 0.0
var sfx_player: AudioStreamPlayer

func _ready() -> void:
	add_to_group("audio_manager")
	music_player = AudioStreamPlayer.new()
	var music_stream := AudioStreamGenerator.new()
	music_stream.mix_rate = MIX_RATE
	music_stream.buffer_length = 1.0
	music_player.stream = music_stream
	music_player.volume_db = -18.0
	add_child(music_player)
	music_player.play()
	music_playback = music_player.get_stream_playback() as AudioStreamGeneratorPlayback

	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -4.0
	add_child(sfx_player)
	_fill_music_buffer()

func _process(_delta: float) -> void:
	if music_playback == null:
		return
	_fill_music_buffer()

func _fill_music_buffer() -> void:
	var frames := music_playback.get_frames_available()
	var inc := 220.0 / MIX_RATE
	for i in range(frames):
		var t := music_time
		var note := sin(TAU * (55.0 + 27.5 * sin(t * 0.18)))
		var shimmer := sin(TAU * (110.0 + 7.5 * sin(t * 0.11)))
		var sample := (note * 0.08 + shimmer * 0.035) * (0.65 + 0.35 * sin(t * 0.04))
		music_playback.push_frame(Vector2(sample, sample))
		music_time += inc
	music_phase = music_time

func play_sfx(kind: String) -> void:
	var wav := _make_sfx(kind)
	sfx_player.stream = wav
	sfx_player.play()

func _make_sfx(kind: String) -> AudioStreamWAV:
	var duration := 0.12
	var frequency := 440.0
	var decay := 12.0
	if kind == "hit":
		frequency = 110.0
		duration = 0.16
		decay = 18.0
	elif kind == "attack":
		frequency = 520.0
		duration = 0.09
		decay = 24.0
	elif kind == "pickup":
		frequency = 880.0
		duration = 0.13
		decay = 16.0
	var count := int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	for i in range(count):
		var t := float(i) / MIX_RATE
		var value := sin(TAU * frequency * t) * exp(-t * decay) * 0.5
		if kind == "hit":
			value += sin(TAU * 61.0 * t) * exp(-t * 28.0) * 0.25
		var sample := int(clamp(value, -1.0, 1.0) * 32767.0)
		bytes.append(sample & 255)
		bytes.append((sample >> 8) & 255)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(MIX_RATE)
	wav.stereo = false
	wav.data = bytes
	return wav

func set_music_enabled(enabled: bool) -> void:
	if music_player:
		if enabled and not music_player.playing: music_player.play()
		elif not enabled and music_player.playing: music_player.stop()
