<div align="center">

<img src="zombies/assets/Texto/Logo%20del%20juego.png" alt="Zombie" width="520">

### Survival arcade de oleadas hecho en **Godot** 🧟‍♂️🔫

*Dispara, sobrevive y construye mientras hordas de zombis —y un jefe que no veías venir— intentan merendarte.*

[![Godot](https://img.shields.io/badge/Godot-4.6-478CBF?style=for-the-badge&logo=godotengine&logoColor=white)](https://godotengine.org)
[![GDScript](https://img.shields.io/badge/GDScript-1f6feb?style=for-the-badge)](#-bajo-el-capó)
![Plataforma](https://img.shields.io/badge/Windows%20%7C%20Linux%20%7C%20macOS-6e6e6e?style=for-the-badge)
![Código abierto](https://img.shields.io/badge/c%C3%B3digo-abierto-e10600?style=for-the-badge)
![PRs bienvenidos](https://img.shields.io/badge/PRs-bienvenidos-2ea44f?style=for-the-badge)

**[Características](#-características) · [Bestiario](#-bestiario-zombi) · [Power-ups](#-power-ups) · [Controles](#-controles) · [Cómo jugar](#-cómo-jugar) · [Documentación](#-bajo-el-capó)**

</div>

<br>
<div align="center">
<img width="3839" height="2159" alt="image" src="https://github.com/user-attachments/assets/8a5818b6-625a-405a-b184-141be18cf338" />
</div>

## 🧟 ¿De qué va?

Eres el **último superviviente** en un mapa infestado y los muertos vivientes no paran de llegar.
Aguanta **oleadas** cada vez más numerosas y peligrosas, **recoge power-ups** que sueltan los
zombis, **viaja a tu base** para guardar el botín y construir... y prepárate, porque tarde o
temprano aparece un **jefe bailongo** muy especial. 🕺

Es un *survival* arcade con **vista cenital**: fácil de coger, difícil de soltar. Y como es
**código abierto**, también es un sitio estupendo para **aprender a hacer videojuegos** con Godot.

---

## ✨ Características

- 🌊 **Oleadas infinitas** que escalan en número y dificultad.
- 🧟 **6 tipos de zombi**, incluido un **jefe sorpresa** que secuestra la música y oscurece la escena.
- 💥 **8 power-ups**: granadas, minas, botiquín, orbe de teletransporte, congelar el tiempo, bala triple, balas teledirigidas y disparo sin enfriamiento.
- 🏗️ **Base construible**: viaja a tu explanada, guarda el botín y levanta estructuras.
- 🪙 **Economía de *loot*** que **persiste entre partidas**.
- 🏆 **10 logros** y **récord de oleada** guardados en disco.
- 🌫️ **Ambiente dinámico**: niebla, cambios de brillo y una banda sonora que reacciona a lo que pasa.
- 🎚️ **Editor de oleadas integrado**: cambia la dificultad **sin tocar código**.
- 💀 **Modo difícil** para quien quiera sufrir de verdad.
- 🎮 **Compatible con mando** (estilo Switch): el stick derecho hasta emula el ratón.
- 🧩 **Código abierto, comentado y documentado**, pensado para aprender y trastear.

---

## 🧟‍♂️ Bestiario zombi

| Zombi | Cómo te amarga la vida |
|-------|------------------------|
| 🧟 **Normal** | Va directo a por ti. Cae de un solo disparo. |
| ⚡ **Rápido** | Veloz y en zigzag; suelta chispas eléctricas. |
| 💪 **Fuerte** | Lento, pero aguanta varios impactos. |
| ⛏️ **Minero** | Se entierra y reaparece **a tu lado**... aunque sale mareado y vulnerable. |
| ☢️ **Atómico** | Se detiene a **escupir ácido** que deja charcos peligrosos en el suelo. |
| 🕺 **Michael Jackson** *(jefe)* | Baila, **secuestra la música** y oscurece la escena. Tiene muchísima vida y **solo las explosiones** le hacen daño de verdad. |

---

## 💥 Power-ups

Los sueltan los zombis al morir. Unos los **acumulas y usas cuando quieres**; otros se **activan
solos al recogerlos**.

| Power-up | Efecto | Cómo se usa |
|----------|--------|-------------|
| 💣 **Granada** | La lanzas en arco; explota en área | `F` o clic derecho |
| 🧨 **Mina** | La colocas en el suelo; se arma y detona al paso de un zombi | `C` |
| ❤️ **Botiquín** | Recuperas salud | `Q` |
| 🌀 **Orbe de teletransporte** | Te lleva a un lugar seguro lejos del peligro | `E` |
| ⏱️ **Reloj** | **Congela el tiempo** de todo lo que te rodea | al recogerlo |
| 🔱 **Bala triple** | Disparas tres balas en abanico durante un rato | al recogerlo |
| 🎯 **Balas teledirigidas** | Tus balas persiguen al zombi más cercano | al recogerlo |
| 🔥 **Sin enfriamiento** | Disparas a ráfaga, sin pausa entre balas | al recogerlo |

---

## 🎮 Controles

| Acción | Teclado / Ratón |
|--------|-----------------|
| Moverte | `W` `A` `S` `D` o las flechas |
| Apuntar | Ratón |
| Correr (esprint) | Mantén `Shift` |
| Disparar | `Espacio` o clic izquierdo |
| Lanzar granada | `F` o clic derecho |
| Colocar mina | `C` |
| Orbe de teletransporte | `E` |
| Botiquín | `Q` |

> 🎮 **¿Mando?** Totalmente compatible (botones estilo Switch). El **stick izquierdo** mueve, el
> **derecho** controla el puntero y los gatillos disparan.

---

## 🚀 Cómo jugar

### Requisitos
- **[Godot Engine 4.6](https://godotengine.org/download)** (no necesita nada más: ni instalar dependencias, ni compilar).

### Pasos
1. **Clona o descarga** este repositorio.
2. Abre **Godot 4.6** → pulsa **Importar** → elige el archivo **`zombies/project.godot`**.
3. Pulsa el botón **▶️** (o `F5`) y... ¡a sobrevivir!

> 💡 ¿Quieres un ejecutable? Desde Godot puedes **exportar** el juego a Windows, Linux o macOS
> (menú `Proyecto → Exportar`).

---

## 🏗️ Base, botín y progreso

- 🧳 Durante la partida recoges **loot** (madera, hierro, cobre, petróleo...).
- 🏠 Puedes **viajar a tu base**, guardar lo recogido y **construir** gastando recursos.
- 💾 Tu **botín guardado**, tus **logros** y tu **récord de oleada** se conservan **entre partidas**.
- 🎚️ ¿Demasiado fácil o difícil? Abre el **editor de oleadas** desde el menú y ajústalo a tu gusto,
  o activa el **modo difícil** para el reto definitivo.

---

## 🧩 Bajo el capó

Hecho con **Godot 4.6** y **GDScript**, con una arquitectura limpia de **coordinador + módulos
especializados** (oleadas, base, ambiente, congelación de tiempo, HUD), *autoloads* para el estado
persistente (logros y economía de loot) y jerarquías de clases para zombis y power-ups.

```
Zombies/
├── README.md                 ← estás aquí (presentación)
├── docs/                      ← capturas e imágenes del README
└── zombies/                   ← el proyecto de Godot
    ├── project.godot          ← ábrelo con Godot 4.6
    ├── assets/                ← sprites, sonidos, música y texto
    ├── scenes/                ← escenas (.tscn)
    ├── scripts/               ← toda la lógica (GDScript)
    ├── README.md              ← 🧰 Guía del taller (modifica el juego sin saber programar)
    └── DOCUMENTACION.md       ← 📐 Documentación técnica (arquitectura del código)
```

📚 **¿Quieres trastear o aprender?**
- 🧰 **[Guía del taller](zombies/README.md)** — cambia dibujos, colores, sonidos y números **sin saber programar**.
- 📐 **[Documentación técnica](zombies/DOCUMENTACION.md)** — cómo está montado el juego por dentro, módulo a módulo.

---

## 🤝 Contribuir

¡Las aportaciones son bienvenidas! Ideas para empezar:

- 🧟 Añadir un **nuevo tipo de zombi** o **power-up**.
- 🎨 Mejorar sprites, sonidos o efectos.
- 🌍 **Traducir** los textos del juego.
- 🐛 Corregir *bugs* o pulir el equilibrio de las oleadas.

1. Haz un *fork* del repositorio.
2. Crea una rama (`git checkout -b mi-mejora`).
3. Haz tus cambios y abre un *Pull Request* describiendo qué aportas.

---

## 📜 Licencia y créditos

Proyecto de **código abierto** creado con cariño y fines educativos. Si vas a reutilizarlo o
publicarlo, te recomendamos añadir un archivo **`LICENSE`** con la licencia que prefieras
(por ejemplo, [MIT](https://choosealicense.com/licenses/mit/)).

> ℹ️ Algunos recursos (ciertos sonidos, músicas o referencias) pueden provenir de terceros y usarse
> con fines de aprendizaje. Respeta siempre los derechos de sus autores originales antes de
> redistribuir el juego.

Hecho con 🧠, ❤️ y mucho 🧟 sobre **[Godot Engine](https://godotengine.org)**.

<div align="center">

---

⭐ *Si te ha gustado, deja una estrella y comparte tu mejor récord de oleada.* ⭐

</div>
