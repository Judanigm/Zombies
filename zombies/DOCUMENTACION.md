# Documentación técnica — Zombies

Este documento describe la arquitectura del juego, su organización en módulos, el
estado (variables) que maneja y cómo funciona a nivel técnico. Está pensado para
que cualquier persona pueda entender la estructura del proyecto y dónde tocar cada
cosa.

El juego está hecho en **Godot 4.6** con **GDScript**. Es un *survival* por oleadas
de zombis con vista cenital: el jugador dispara, sobrevive oleadas crecientes,
recoge power-ups, viaja a una "base" para construir, y se enfrenta a jefes.

---

## 1. Visión general de la arquitectura

El proyecto sigue un patrón **coordinador + módulos especializados**:

- **`main.gd`** es el nodo raíz de la escena de juego (`scenes/main.tscn`). Actúa
  como **coordinador**: crea y conecta los subsistemas, mantiene el estado
  compartido mínimo (oleada actual, si el jugador está muerto, si está en la base)
  y delega cada responsabilidad a un módulo.
- **Autoloads (singletons globales):** estado **persistente** que vive fuera de la
  escena y sobrevive a los reinicios — logros y economía de loot.
- **Controladores hijos:** nodos hijos de `main` que encapsulan un subsistema
  concreto (oleadas, base, ambiente, congelación de tiempo, HUD). Cada uno guarda
  una referencia `main` para leer el estado compartido.
- **Clases base con `class_name`:** `Zombie` y `PowerUp` factorizan el
  comportamiento común de sus jerarquías.
- **Helpers estáticos:** utilidades sin estado reutilizadas por varios módulos
  (`SpriteFont`, `MenuText`).

La idea central: **el estado compartido vive en `main`** (o en los autoloads si es
persistente), y **cada controlador lee ese estado a través de su referencia
`main`** y expone métodos que `main` (u otros controladores) invocan. Así se evita
el "objeto-dios" y cada archivo tiene una única responsabilidad.

### Diagrama de dependencias (simplificado)

```
                        ┌─────────────────────────────┐
   Autoloads globales   │  AchievementManager  (logros)│
   (persistentes)       │  LootEconomy        (loot)   │
                        └──────────────▲──────────────┘
                                       │ (señales + llamadas)
                          ┌────────────┴───────────┐
                          │        main.gd          │  nodo raíz / coordinador
                          │  - estado compartido    │  (current_wave, player_dead,
                          │  - navegación a la base │   is_in_base_zone, spawn_area)
                          │  - teletransporte       │
                          │  - UI de notificaciones │
                          └──┬───┬───┬───┬───┬──────┘
            crea como hijos  │   │   │   │   │
        ┌───────────────────┘   │   │   │   └────────────────┐
        ▼            ▼           ▼   ▼                        ▼
  WaveDirector  BaseZone   Atmosphere  TimeFreeze        HudController
  (oleadas)     Controller  Controller  Controller       (HUD)
                (base)      (niebla/    (congelar
                            música)      tiempo)
```

---

## 2. Estructura de carpetas

```
zombies/
├── project.godot            # configuración del proyecto y autoloads
├── DOCUMENTACION.md         # este documento
├── assets/                  # sprites, sonidos, música, texto
├── scenes/                  # escenas (.tscn): main, zombis, balas, power-ups…
│   ├── main.tscn            # escena principal del juego
│   ├── zombie.tscn, fast_zombie.tscn, …
│   └── power_ups/…
└── scripts/                 # toda la lógica (GDScript)
    ├── main.gd                     # coordinador del juego
    ├── menu.gd                     # menú / pausa / game over / pantallas
    ├── player.gd                   # jugador (movimiento, disparo, power-ups)
    │
    ├── achievement_manager.gd      # AUTOLOAD: logros y estadísticas
    ├── loot_economy.gd             # AUTOLOAD: economía de loot
    │
    ├── wave_director.gd            # controlador: oleadas y aparición de zombis
    ├── base_zone_controller.gd     # controlador: zona base y construcción
    ├── atmosphere_controller.gd    # controlador: niebla, brillo y música
    ├── time_freeze_controller.gd   # controlador: power-up de congelar tiempo
    ├── hud_controller.gd           # controlador: HUD en partida
    │
    ├── sprite_font.gd              # helper estático: fuente de mapa de bits
    ├── menu_text.gd                # helper estático: texto con sprites del menú
    ├── menu_audio.gd               # controlador de audio del menú
    │
    ├── zombie_base.gd              # clase base: Zombie
    ├── zombie.gd, fast_zombie.gd, strong_zombie.gd,
    │   miner_zombie.gd, atomic_zombie.gd, zombie_michael_jackson.gd
    ├── atomic_acid_spit.gd, atomic_acid_puddle.gd   # ataque del zombi atómico
    │
    ├── power_up.gd                 # clase base: PowerUp
    ├── grenade_power_up.gd, medkit_power_up.gd, mine_power_up.gd, …
    ├── thrown_grenade.gd, placed_mine.gd,
    │   grenade_explosion.gd, mine_explosion.gd
    │
    ├── bullet.gd                   # proyectil del jugador
    └── loot_container.gd, loot_minecart.gd, collectible_loot.gd
```

---

## 3. `main.gd` — el coordinador

Es un `Node2D`, raíz de `main.tscn`. Sus hijos en la escena incluyen al `Player`,
el `Menu` (un `CanvasLayer`), el `CanvasLayer` del HUD y los reproductores de
música compartidos (`GameMusic`, `MenuMusic`, `DeathSound`).

### Responsabilidades que conserva
- **Ciclo de vida:** en `_init()` crea los controladores hijos (para que nunca sean
  `null`, ya que los hijos ejecutan `_ready` antes que el padre) y en `_ready()` los
  añade al árbol, ejecuta sus `setup()` y conecta las señales del jugador y de los
  autoloads.
- **Estado compartido** (lo leen otros módulos a través de `main`):
  - `player_dead: bool` — si el jugador ha muerto.
  - `is_in_base_zone: bool` — si estamos en la zona base.
  - `spawn_area: Rect2` — el rectángulo del campo de batalla.
  - `hard_mode_enabled: bool` — modo difícil.
  - `return_from_base_position: Vector2` — dónde devolver al jugador al salir de la base.
- **Navegación entre batalla y base:** `go_to_base()`, `return_from_base()`,
  `toggle_base_zone()`, `return_from_base_to_menu()`. Orquestan al jugador, la cámara,
  la pausa de zombis, la atmósfera, el HUD y el loot, y le piden a `BaseZoneController`
  que muestre/oculte la zona.
- **Teletransporte:** `get_safe_teleport_position()` y los ayudantes de "zombi más
  cercano" (el power-up de orbe lo invoca desde el jugador).
- **UI de notificación de logros:** el cartel deslizante de "logro desbloqueado".
- **Delegadores finos:** métodos públicos que reenvían a los módulos para no romper
  a quien llama desde fuera (ver §11).

### El bucle `_process`
`main._process(delta)` aplica las "puertas" de estado y delega:
1. Actualiza partículas de niebla, la UI de la base y el congelado de tiempo.
2. Si hay tiempo congelado / jugador muerto / estamos en la base → retorna.
3. Si no hay menú visible, gestiona la aparición de la vagoneta de loot.
4. Llama a `wave_director.tick(delta)`, que lleva toda la lógica de oleadas.

---

## 4. Autoloads (estado global persistente)

Registrados en `project.godot`:

```ini
[autoload]
AchievementManager="*res://scripts/achievement_manager.gd"
LootEconomy="*res://scripts/loot_economy.gd"
```

Son **singletons**: existen una sola vez, accesibles desde cualquier script por su
nombre, y **sobreviven a reiniciar la escena** (por eso guardan el estado que debe
persistir entre partidas).

### `AchievementManager` (`achievement_manager.gd`)
Modelo de **logros y estadísticas**, sin nada de interfaz.
- **Estado:** `unlocked_achievements`, `zombie_kill_counts`, `discovered_zombie_types`,
  `wave_record` (récord de oleada).
- **Constantes:** los identificadores de logro, `ACHIEVEMENT_DEFINITIONS`
  (título/descripción), `ACHIEVEMENT_IMAGE_TEXTURES`, umbrales (`ZOMBIE_KILL_MILESTONE`,
  `ACTIVE_MINES_ACHIEVEMENT_TARGET`, `CLOSE_ZOMBIE_KILL_DISTANCE`).
- **API:** `unlock(id)`, `register_zombie_kill(zombie)`, `register_zombie_discovery(zombie)`,
  `register_wave_record(wave)`, `register_grenade_stock(n)`,
  `register_grenade_strong_zombie_kills(n)`, `check_active_mine_achievement()`,
  `get_achievements_data()`, `get_wave_record()`, `clear()`.
- **Señal:** `achievement_unlocked(id)`. La emite `unlock()`; `main` la escucha y
  muestra la notificación (separación **modelo / vista**).
- **Persistencia:** `user://achievements.cfg` (`ConfigFile`).

### `LootEconomy` (`loot_economy.gd`)
Modelo de la **economía de loot**.
- **Estado:** `expedition_loot_counts` (lo que llevas en la expedición),
  `stored_base_loot_counts` (lo guardado en la base).
- **Constantes:** `LOOT_TEXTURES`, `LOOT_DISPLAY_NAMES`, `LOOT_DISPLAY_ORDER`,
  costes de construcción (`BASE_BUILD_WOOD_COST`, `BASE_BUILD_IRON_COST`).
- **API:** `add_expedition_loot(id)`, `commit_expedition_to_base()`,
  `clear_expedition()`, `has_building_cost()`, `spend_building_cost()`,
  `get_base_loot_count(id)`.
- **Señal:** `base_loot_changed`. `main`/`BaseZoneController` la escuchan para
  refrescar el panel de loot.
- **Persistencia:** `user://base_loot.cfg`.

---

## 5. Controladores hijos

Todos siguen el mismo patrón: son `Node` hijos de `main`, tienen `var main: Node`
(referencia de vuelta) y exponen métodos que `main` llama. Crean sus nodos visuales
**bajo `main`** (no bajo sí mismos) para no alterar el orden de dibujado (z-index)
ni las transformaciones respecto a la versión anterior.

### `WaveDirector` (`wave_director.gd`)
El corazón del juego: **progresión de oleadas y aparición de zombis**.
- **Estado propio:** `current_wave`, `wave_active`, `wave_timer`, `spawn_timer`,
  y los contadores por tipo pendientes de aparecer (`zombies_left_to_spawn`,
  `normal/atomic/fast/strong/miner_zombies_left_to_spawn`), más
  `extraction_requested` / `extraction_wave_active`.
- **Tuning (`@export`):** todos los parámetros de oleada (zombis base por oleada,
  intervalos de aparición, oleada de inicio de cada tipo, probabilidades de drop de
  power-ups, jefe Michael Jackson…). Son los que edita el "editor de oleadas" del
  menú vía `get_wave_settings_text()` / `apply_wave_settings_text()`.
- **Funcionamiento:** `tick(delta)` cuenta el temporizador entre oleadas, inicia la
  siguiente (`_start_next_wave`), calcula la composición de la oleada
  (`_get_*_zombies_for_wave`, con suavizado de oleadas tardías), elige el siguiente
  zombi (`_get_next_zombie_scene`), su posición (`_get_edge_spawn_position`,
  `_get_random_spawn_position_inside_area`, evitando al jugador y al contenedor de
  loot), aplica el modo difícil, registra el zombi y reparte drops de power-ups.
- **Lee de `main`:** `player`, `spawn_area`, `player_dead`, `is_in_base_zone`,
  `hard_mode_enabled`; y llama a `main._update_wave_label()` /
  `main._update_fog_effect_for_wave()` para refrescar HUD/atmósfera.

### `BaseZoneController` (`base_zone_controller.gd`)
La **zona base** ("explanada"): construcción de la escena (suelo, muros, vallas,
fogata con humo, cajas, edificio construible y su previsualización), la **UI de
construcción** (botón, selector, confirmación) y el **panel de loot guardado**.
- **Estado:** referencias a los nodos de la base, flags de construcción
  (`base_build_picker_open`, `base_build_preview_active`, `base_building_placed`).
- **Constantes:** dimensiones de la zona (`BASE_ZONE_ORIGIN`, `BASE_ZONE_SIZE`,
  `BASE_ZONE_WALL_THICKNESS`…) y texturas. `main` las lee como `base_zone.BASE_ZONE_*`.
- **API:** `setup()`, `show_zone()`, `hide_zone()`, `update_travel_ui()`,
  `update_loot_display()`, `cancel_build_preview()`. El coste de construcción se
  consulta/descuenta en `LootEconomy`.

### `AtmosphereController` (`atmosphere_controller.gd`)
**Niebla, brillo del entorno y máquina de estados de la música.**
- **Estado:** `fog_overlay`, `fog_brightness_modulate`, los reproductores `fog_music`
  y `base_music`, y las partículas de niebla dura.
- **Funcionamiento:** `update_for_wave()` decide si toca niebla según la oleada (o el
  modo difícil), ajusta el brillo y conmuta la música; `_update_fog_music_for_state()`
  es la máquina que decide qué suena (juego / niebla / base / menú / silencio), y
  cede prioridad al tiempo congelado y al jefe Michael Jackson.
- **Detalle:** `get_music_players()` lo usa `TimeFreezeController` para saber qué
  música pausar.

### `TimeFreezeController` (`time_freeze_controller.gd`)
El power-up de **congelar el tiempo**.
- **Estado:** `time_freeze_timer` y diccionarios con el estado capturado de zombis,
  objetos congelables y música.
- **Funcionamiento:** `activate(duration)` captura y pausa el `process`,
  `physics_process`, animaciones, partículas y audio de todo lo del grupo
  `"zombies"` y `"time_freezable_objects"`, además de la música; `update(delta)`
  cuenta el temporizador y al terminar restaura el estado guardado.

### `HudController` (`hud_controller.gd`)
La **interfaz dentro de la partida**: etiqueta "WAVE" + número, iconos y contadores
de power-ups (granada, botiquín, mina, orbe), resaltado del power-up seleccionado y
barra de estamina. Resuelve los nodos del HUD desde `main/CanvasLayer` y construye
los widgets dinámicos allí. `main` conecta directamente las señales del jugador a
los métodos `update_*` del HUD.

---

## 6. Jerarquía de zombis

Antes cada zombi reimplementaba la misma máquina de estados. Ahora hay una clase
base con `class_name Zombie` (`zombie_base.gd`, extiende `CharacterBody2D`).

### `Zombie` (base) — qué aporta
- **Máquina de estados común:** aparición (con animación y "temblor"), persecución,
  muerte (cadáver temporal) — todo en `_physics_process`.
- **Tunables `@export`:** `move_speed`, escalas/desfases de sprite, duraciones,
  `max_health`, parámetros de sonido.
- **Tipos canónicos:** constantes `TYPE_NORMAL`, `TYPE_FAST`, `TYPE_STRONG`,
  `TYPE_MINER`, `TYPE_ATOMIC`, `TYPE_MICHAEL_JACKSON` (las usan `main`/autoloads).
- **Caché de `SpriteFrames`** compartida por tipo y constructores estáticos de
  animaciones a partir de tiras de sprites.
- **Salud unificada:** `take_damage(amount)` resta a `current_health` y muere al
  llegar a 0 (un zombi normal tiene `max_health = 1`).
- **Ganchos virtuales (los sobreescriben las subclases):**
  - `_on_ready()` — preparación extra.
  - `_process_active(delta)` — comportamiento por frame ya vivo (por defecto:
    perseguir al jugador en línea recta).
  - `_on_death()` — limpieza extra (p. ej. apagar partículas).
  - `_can_take_damage()` — bloquear daño en estados especiales.
  - `_build_sprite_frames()` — construir las animaciones del tipo.
  - `get_zombie_type()` — identificador del tipo.

### Subclases (solo añaden lo propio)
- **`zombie.gd`** (normal): persecución recta, muere de un golpe.
- **`fast_zombie.gd`**: rápido, movimiento en zigzag, partículas eléctricas.
- **`strong_zombie.gd`**: lento, `max_health = 2`.
- **`miner_zombie.gd`**: se entierra, se reubica cerca del jugador y reaparece
  "mareado" y vulnerable (máquina de estados propia que sobreescribe
  `_physics_process`).
- **`atomic_zombie.gd`**: persigue pero se detiene a escupir ácido a distancia
  (`atomic_acid_spit.gd` → `atomic_acid_puddle.gd`).
- **`zombie_michael_jackson.gd`** (jefe): deambula y baila, secuestra la música y
  oscurece la escena, mucha vida, daño reducido a explosiones.

---

## 7. Power-ups

Tienen una jerarquía limpia con base `class_name PowerUp` (`power_up.gd`, extiende
`Area2D`). La base gestiona la animación flotante, la detección de recogida, el
sonido y la señal; cada subclase solo redefine `_try_collect()` para aplicar su
efecto sobre quien lo recoge (p. ej. `collector.add_grenades(...)`,
`collector.activate_triple_bullet(...)`). El de congelar tiempo es especial: llama a
`activate_time_freeze` en la escena (efecto global, no del jugador).

Objetos asociados: `thrown_grenade.gd` (granada con arco) → `grenade_explosion.gd`;
`placed_mine.gd` (mina que se arma y detona) → `mine_explosion.gd`.

---

## 8. Helpers compartidos

- **`SpriteFont` (`sprite_font.gd`)** — clase con métodos **estáticos** y sin estado.
  Centraliza la fuente de mapa de bits del juego: texturas de dígitos, atlas de
  letras, normalización de acentos, saneado de texto y ajuste de líneas. La usan
  tanto el HUD (`main`) como el menú.
- **`MenuText` (`menu_text.gd`)** — métodos estáticos que construyen "texto con
  sprites" para el menú (filas de glifos con acentos y espaciado de dígitos) y
  cambian el contenido de botones/etiquetas por ese texto. Apoya su búsqueda de
  glifos en `SpriteFont`.
- **`MenuAudio` (`menu_audio.gd`)** — controlador hijo del menú con la música, el
  sonido de los botones, el sonido de muerte y la vibración del mando.

---

## 9. `menu.gd` — menú, pausa, game over y pantallas

Es un `CanvasLayer` hijo de `main`. Gestiona el menú principal, la pausa, el game
over, y las pantallas de **logros**, **tutorial** y **editor de oleadas**, además de
la navegación con teclado/ratón/mando (emula el ratón con el stick derecho). Delega
el texto en `MenuText`, el audio en `MenuAudio`, y habla con el juego a través de
`main` (p. ej. `get_achievements_data()`, `skip_to_wave()`,
`apply_wave_settings_text()`).

---

## 10. `player.gd` — el jugador

`CharacterBody2D` en el grupo `"player"`. Maneja movimiento (con esprint y estamina),
disparo (`bullet.gd`, con variantes de triple bala / teledirigidas / sin cooldown),
los contadores de power-ups (granadas, minas, botiquines, orbes), el sistema de daño
por fases con invulnerabilidad temporal, y el teletransporte. Comunica su estado al
resto **emitiendo señales** (ver abajo). Es uno de los archivos más limpios y sirve
de referencia de estilo.

---

## 11. Comunicación entre componentes

Se usan cuatro mecanismos, según el caso:

1. **Señales** (desacople jugador → UI/lógica):
   `player.died`, `player.stamina_changed`, `player.*_count_changed`,
   `player.selected_power_up_changed`; `AchievementManager.achievement_unlocked`;
   `LootEconomy.base_loot_changed`. `main` las conecta en `_ready`.
2. **Grupos** (consultas por tipo sin acoplar referencias):
   `"player"`, `"zombies"`, `"power_ups"`, `"placed_mines"`, `"collectible_loot"`,
   `"time_freezable_objects"`.
3. **Referencia `main`** (controladores → estado compartido): cada controlador lee
   `main.current_wave`, `main.is_in_base_zone`, etc., y se llama entre sí vía
   `main.wave_director`, `main.atmosphere`, `main.time_freeze`…
4. **Métodos delegadores en `main`** (compatibilidad con código externo): los scripts
   que llaman a la escena por método (`current_scene.unlock_achievement(...)`,
   `register_grenade_stock(...)`, `check_active_mine_achievement(...)`,
   `get_safe_teleport_position(...)`…) siguen funcionando porque `main` mantiene esos
   métodos como envoltorios finos que reenvían al módulo correspondiente. Por eso
   `bullet.gd`, `placed_mine.gd`, `grenade_explosion.gd` y `player.gd` no necesitaron
   cambios al extraer la lógica.

---

## 12. Flujo de ejecución (resumen)

1. **Arranque:** Godot carga los autoloads (`AchievementManager`, `LootEconomy`),
   que leen sus `.cfg`. Se instancia `main.tscn`.
2. **`main._init()`** crea los controladores hijos (no nulos desde el principio).
3. **`main._ready()`** los añade al árbol, ejecuta `setup()` de cada uno, conecta
   señales y deja el juego en espera de la primera oleada. El menú es visible al
   inicio.
4. **Cada frame (`_process`)** `main` aplica las puertas de estado y delega la lógica
   de oleadas a `wave_director.tick()`.
5. **Oleada:** `WaveDirector` cuenta el temporizador, inicia la oleada, va apareciendo
   zombis según la composición calculada y, al morir todos, programa la siguiente.
6. **Muerte de zombi:** emite `died` → `WaveDirector` registra la muerte en
   `AchievementManager` y puede soltar un power-up.
7. **Muerte del jugador:** emite `died` → `main` reinicia el estado de oleada, oculta
   HUD y muestra el game over.
8. **Base:** desde el menú/acción el jugador "viaja" a la base; `main` mueve cámara y
   jugador, pausa zombis y pide a `BaseZoneController`/`AtmosphereController` el cambio
   de UI y música.

---

## 13. Persistencia

- `user://achievements.cfg` — logros, contadores de muertes por tipo, tipos
  descubiertos y récord de oleada (`AchievementManager`).
- `user://base_loot.cfg` — loot guardado en la base (`LootEconomy`).
- `user://settings.cfg` — ajustes del menú, p. ej. modo difícil (`menu.gd`).

(`user://` es la carpeta de datos de usuario que gestiona Godot por plataforma.)

---

## 14. Convenciones y decisiones de diseño

- **Una responsabilidad por archivo.** `main.gd` coordina; cada subsistema vive en su
  propio módulo.
- **Modelo separado de la vista.** Los autoloads (logros, loot) guardan datos y
  **emiten señales**; la interfaz (notificación de logros, panel de loot) vive en
  `main`/controladores y reacciona a esas señales.
- **Estado compartido en `main`, no duplicado.** Los controladores lo leen por
  referencia en vez de tener copias.
- **Nodos visuales bajo `main`.** Aunque la lógica esté en un controlador, sus
  sprites/UI se cuelgan de `main` o de su `CanvasLayer` para conservar el dibujado.
- **Herencia para jerarquías** (`Zombie`, `PowerUp`): la base trae el comportamiento
  común y las subclases solo añaden lo suyo mediante ganchos virtuales.
- **Helpers estáticos** para utilidades sin estado (`SpriteFont`, `MenuText`).

### Posibles mejoras futuras (opcionales)
- Separar las pantallas del menú (logros / tutorial / editor de oleadas) en sus
  propios controladores.
- Centralizar los nombres de grupo (`"zombies"`, `"player"`…) en constantes.
- Un helper común para el patrón repetido `get_tree().current_scene` con
  *fallback* a `get_tree().root`.
- Sustituir las comprobaciones por `has_method()`/`call()` por comprobaciones de
  tipo (`is Zombie`, `is PowerUp`) ahora que existen las clases base.
```
