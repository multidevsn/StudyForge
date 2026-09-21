# ECLYRIA roadmap

## V0.1 — Fondations jouables (complete)
- [x] Terrain 3D, sky/soleil, éclairage
- [x] Player 3D + caméra troisième personne
- [x] Déplacement, sprint, saut, collisions
- [x] Première zone : vallée, arbres, rochers, rivière
- [x] Village + PNJ + premier ennemi
- [x] Combat basique
- [x] HUD + sauvegarde

## V0.2 — RPG progression (complete)
- [x] Inventaire
- [x] Équipement
- [x] Loot
- [x] XP
- [x] Niveaux
- [x] Compétences
- [x] Récompenses reliées au combat
- [x] Sauvegarde des données RPG
- [x] HUD progression
- [x] Raccourcis I/K/J/U

## V0.3 — Monde et contenu (complete)
- [x] Quêtes
- [x] Dialogues
- [x] PNJ
- [x] Marchand
- [x] Donjon
- [x] Boss
- [x] Événements dynamiques
- [x] Récompenses de quêtes
- [x] Boucle dialogue → quête → combat → loot → XP → récompense
- [x] Boucle marchand → achat → inventaire → équipement

### Limites V0.3
- Donjon procédural léger.
- Marchand avec interaction clavier minimale.
- Événements déclenchés par timer.
- Navigation mesh complète reportée à V0.4.

## V0.4 — Production combat
- [ ] Hitboxes / hurtboxes avancées
- [ ] Armes avec statistiques
- [ ] Combos
- [ ] Variantes d'ennemis
- [ ] Feedback VFX/SFX
- [ ] Navigation meshes / agents
- [ ] IA avancée

## V0.5 — Monde ouvert
- [ ] Plusieurs régions
- [ ] Streaming de régions
- [ ] LOD
- [ ] Occlusion
- [ ] Carte du monde
- [ ] Fast travel
- [ ] Événements persistants


## V1.0 — Monde ouvert et finition (complete)
- [x] Monde ouvert à régions contiguës
- [x] Streaming asynchrone des régions
- [x] Déchargement/rechargement autour du joueur
- [x] Optimisation 3D et culling
- [x] Sauvegarde complète joueur + RPG + monde
- [x] Persistance des ennemis vaincus
- [x] Audio procédural musique + SFX
- [x] HUD finalisé / crosshair / indicateur de région
- [x] Version projet 1.0.0

### Limites V1.0
- Les assets 3D Quaternius/Poly Haven restent une étape d'intégration séparée : aucun ancien asset StudyForge n'est réutilisé.
- Le streaming porte actuellement sur les régions de décor/terrain procédurales; les gros contenus narratifs restent dans la région centrale.
- Le runtime FPS/compatibilité matériel n'a pas été exécuté dans cet environnement.


## V1.1 — Professional asset rebuild (in progress)
### Integrated
- [x] Real Quaternius humanoid GLB for player
- [x] Real Quaternius humanoid GLB for elder/merchant visuals
- [x] Real Quaternius trees and bushes
- [x] Real Quaternius rocks
- [x] Real Quaternius village houses
- [x] Real Quaternius inn / blacksmith / market / well
- [x] Real Quaternius Goblin enemy
- [x] Real Quaternius Demon boss
- [x] Real Quaternius Orc reserved for enemy variants
- [x] Asset provenance ledger

### Remaining production pass
- [ ] Embed and retarget Universal Animation Library Standard/2 to the humanoid
- [ ] Add weapon/armor models from Fantasy Props / RPG packs
- [ ] Add PBR terrain/stone/wood materials from Poly Haven
- [ ] Add grass/flowers/mushrooms and biome-specific nature variation
- [ ] Replace remaining procedural water with authored water material/VFX
- [ ] Final combat VFX/SFX pass
- [ ] LOD/impostor pass for large forests
- [ ] Runtime profiling and hardware matrix
