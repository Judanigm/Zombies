# 🧟 Zombies — Guía para el taller de Godot

¡Bienvenido/a! Este es un videojuego de zombis hecho con **Godot**. En este taller
vas a **abrir el juego, jugarlo y cambiar cosas** para hacerlo tuyo. No hace falta
saber programar: la mayoría de los cambios son cambiar un dibujo, un color, un sonido
o un número.

---

## 🎮 ¿De qué va el juego?

Eres un superviviente en un mapa lleno de zombis. Vienen en **oleadas**: cada vez
más zombis y más difíciles. Tienes que:

- **Moverte** con `W A S D` o las flechas (mantén `Shift` para correr).
- **Disparar** con el `Espacio` o el clic del ratón.
- **Usar power-ups** que sueltan los zombis (granadas, minas, botiquín, orbe de
  teletransporte...).
- **Sobrevivir** el mayor número de oleadas posible. ¡Hay un zombi jefe sorpresa!

---

## 🟢 Antes de empezar

1. Abre **Godot 4.6**.
2. Pulsa **Importar** y elige el archivo `project.godot` de esta carpeta.
3. Para **jugar**, pulsa el botón ▶️ de arriba a la derecha (o la tecla `F5`).
4. Para **parar**, pulsa el botón ⏹️ o cierra la ventana del juego.

> Los dibujos, sonidos y música están en la carpeta **`assets/`**.
> Las "instrucciones" del juego (el código) están en la carpeta **`scripts/`**.

---

## 📜 Reglas de oro (¡muy importante!)

1. **Haz una copia de seguridad** de la carpeta del juego antes de empezar. Así, si
   algo se rompe, vuelves a la copia y listo. 💾
2. **Cambia una sola cosa cada vez** y luego **prueba** el juego. Si algo falla,
   sabrás qué fue.
3. Al cambiar un dibujo, **usa el mismo nombre de archivo** que tenía el original
   (y un tamaño parecido).
4. Si tocas el código, **no borres** los `:` ni cambies los espacios del principio
   de la línea (Godot es muy tiquismiquis con eso).

---

## ✏️ Cambio 1 — Convertir el zombi en otro personaje

El zombi normal usa varios dibujos que están en:

```
assets/Zombies/Normal/
```

Ahí verás imágenes como `Andar abajo.png`, `Andar arriba.png`,
`Andar izquierda.png`, `Andar derecha.png`, `dead.png` y `Spawn.png`.

**La forma más fácil (sin tocar código):**

1. Dibuja tu personaje (un gato, un robot, tu profe... 🐱🤖) o busca una imagen.
2. Guárdala con **el mismo nombre** que la original, por ejemplo `Andar abajo.png`.
3. Copia tu imagen dentro de `assets/Zombies/Normal/` **reemplazando** la antigua.
4. Vuelve a Godot y ejecuta el juego: ¡ahora el "zombi" es tu personaje!

> Truco: cambia primero solo `Andar abajo.png` para ver que funciona, y luego el
> resto. Si todas las imágenes tienen el mismo tamaño que las originales, se verá
> mejor.

**¿Y los otros zombis?** Cada tipo tiene su propia carpeta dentro de
`assets/Zombies/` (`Fast`, `Fuerte`, `Minero`, `Atómico`, `Michael Jackson`). Cámbialos
igual.

---

## 🎨 Cambio 2 — Cambiar colores

En Godot los colores se escriben así: **`Color(R, G, B, A)`**, donde cada número va
de **0 a 1**:

- **R** = rojo, **G** = verde, **B** = azul, **A** = transparencia (1 = opaco).

Algunos ejemplos:

| Color | Código |
|-------|--------|
| Blanco | `Color(1, 1, 1, 1)` |
| Negro | `Color(0, 0, 0, 1)` |
| Rojo | `Color(1, 0, 0, 1)` |
| Verde | `Color(0, 1, 0, 1)` |
| Azul | `Color(0, 0, 1, 1)` |
| Morado | `Color(0.6, 0.2, 0.9, 1)` |

**Ejemplo fácil: el color de la barra de estamina** (la barrita de correr).

1. Abre `scripts/hud_controller.gd`.
2. Busca la función que pone `func update_stamina_bar`.
3. Verás líneas con colores, por ejemplo el verde de la barra llena:
   `var fill_color := Color(0.22, 0.92, 0.38, 1.0)`
4. Cambia esos tres números por los de tu color favorito y prueba el juego.

**Ejemplo aún más fácil (con el ratón): el color del teletransporte.**

1. En Godot, abre la escena del jugador (busca `Player` en `scenes/`).
2. Selecciona el nodo del jugador y mira el panel **Inspector** (a la derecha).
3. Busca la propiedad **Teleport Particles Color** y haz clic en el cuadrito de
   color: se abre un selector donde eliges el color con el ratón. 🎨

---

## 🔊 Cambio 3 — Cambiar un sonido

Los sonidos están en `assets/Sonido/Efectos/` y la música en `assets/Sonido/Música/`.

La forma más fácil es **reemplazar el archivo de sonido** por otro con el mismo
nombre (igual que con los dibujos). Algunos sonidos que puedes cambiar:

| Sonido | Archivo |
|--------|---------|
| Gruñido del zombi | `assets/Sonido/Efectos/Sonido zombie.mp3` |
| Recoger un objeto | `assets/Sonido/Efectos/Agarrar objeto.wav` |
| Explosión (granada/mina) | `assets/Sonido/Efectos/efecto de sonido de explosión.mp3` |
| Teletransporte | `assets/Sonido/Efectos/Enderman's Teleport - Sound Effect.mp3` |

**Pasos:**

1. Consigue o graba un sonido corto (puedes grabar tu voz diciendo "¡bum!" 😄).
2. Ponle **el mismo nombre** que el archivo que quieres sustituir.
3. Cópialo en `assets/Sonido/Efectos/` reemplazando el antiguo.
4. Ejecuta el juego y ¡a escuchar!

> **Reto avanzado (con código): darle sonido al disparo.**
> Ahora mismo disparar **no hace ruido**. Si quieres añadirle un sonido:
> 1. Abre `scripts/player.gd` y busca la línea que pone
>    `const TELEPORT_SOUND := preload(...)`.
> 2. Justo debajo añade una línea con tu sonido de disparo, por ejemplo:
>    `const SHOOT_SOUND := preload("res://assets/Sonido/Efectos/Agarrar objeto.wav")`
> 3. Busca la función `func _shoot() -> void:` y, justo debajo de su primera línea,
>    añade estas dos líneas (con la misma sangría/tabulación que el resto):
>    ```gdscript
>    	var shoot_sfx := AudioStreamPlayer2D.new()
>    	shoot_sfx.stream = SHOOT_SOUND
>    	add_child(shoot_sfx)
>    	shoot_sfx.play()
>    	shoot_sfx.finished.connect(shoot_sfx.queue_free)
>    ```
> ¡Pide ayuda a la persona que dirige el taller si te lías! 🙌

---

## 🛠️ Otros cambios rápidos y divertidos

### 🏃 Hacer los zombis más rápidos o más lentos
- Zombi **rápido**: abre `scripts/fast_zombie.gd`, busca `func _init()` y la línea
  `move_speed = 200.0`. Sube el número para que vaya más rápido, o bájalo para más
  lento.
- Zombi **normal**: abre `scripts/zombie_base.gd` y busca
  `@export var move_speed: float = 90.0`.

### 💪 Hacer al zombi fuerte más (o menos) duro
- Abre `scripts/strong_zombie.gd`, busca `func _init()` y la línea `max_health = 2`.
  Ponle `3` y necesitará 3 disparos. (El zombi normal aguanta 1 golpe.)

### 🌊 Cambiar las oleadas SIN tocar código (¡muy chulo!)
El juego tiene un **editor de oleadas** dentro del menú:
1. Ejecuta el juego.
2. En el menú principal, entra en **el editor de oleadas**.
3. Cambia valores como cuántos zombis salen o cada cuánto aparecen, y pulsa
   **Aplicar**.

### 📖 Cambiar el texto del tutorial
- Abre `scripts/menu.gd` y busca `const TUTORIAL_PAGE_TEXTS`. Ahí están las frases
  del tutorial: cámbialas por las tuyas (mantén las comillas `"..."`).

### 🔍 Cambiar el tamaño de un personaje
- En los scripts de zombi hay una propiedad `sprite_scale` (por ejemplo en
  `zombie_base.gd`: `sprite_scale: float = 0.28`). Súbela para hacerlo más grande o
  bájala para más pequeño.

---

## 🚑 Si algo se rompe

- **Deshacer:** en Godot, `Ctrl + Z` deshace el último cambio en el código.
- **Mira el error:** si el juego no arranca, abajo del todo de Godot aparece un
  mensaje en rojo. Suele decir el **archivo** y la **línea** del problema.
- **Vuelve a tu copia:** si nada funciona, recupera la copia de seguridad que
  hiciste al principio. Por eso era la **regla de oro nº 1** 😉.
- Casi siempre el fallo es un `:` borrado, unas comillas `"` que faltan, o haber
  cambiado los espacios del principio de una línea.

---

## 📚 Mini-glosario

- **Nodo:** cada "pieza" del juego (el jugador, un zombi, un sonido...).
- **Escena (`.tscn`):** un conjunto de nodos montados juntos (por ejemplo, el zombi).
- **Script (`.gd`):** las instrucciones que dicen qué hace un nodo.
- **Sprite:** un dibujo o imagen de un personaje u objeto.
- **Inspector:** el panel de la derecha en Godot donde cambias propiedades con el ratón.
- **RGBA:** las 4 partes de un color (Rojo, Verde, Azul, Transparencia).

---

## 📄 Licencia

Este juego es **open source** y se publica bajo la licencia **MIT**. Consulta
[`LICENSE`](../LICENSE) para ver los términos completos.

---

¿Quieres saber **cómo está hecho el juego por dentro** (para los más curiosos)?
Échale un ojo a **`DOCUMENTACION.md`**, en esta misma carpeta. 🚀

¡Diviértete y experimenta! La mejor forma de aprender es **probar cosas y ver qué pasa**. 💡
