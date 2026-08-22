# GodotSkate

A skateboarding videogame which is inspired by the "Tony Hawks Pro Skater" games. The game has keyboard and controller support.

![GodotS Skate Preview](/img/preview.png)

# Requirements
The project is compatible with Godot 4.5.
https://godotengine.org/download/archive/4.5-stable/
# Controls
The game is meant to be controlled with a keyboard or controller. 

> [!IMPORTANT]
> At the moment only the xbox shows correct input prompts.

## Input Mapping
| Action   | Keyboard | X-Box |
|----------|----------|-------|
| UP       | W        | Stick Up/Dpad Up    |
| Left     | A        | Stick Left/Dpad Left |
| Right    | D        | Stick Right/Dpad Right |
| Down     | S        | Stick Down/Dpad Down    |
| Jump     | Space    | A     |
| Grind/Lip| X        | Y     |
| Grab     | G        | B     |
| Flip     | F        | X     |

# Assets

Textures and input images by https://www.kenney.nl

Characters are based on modified low res metahuman characters by EPIC Games https://www.epicgames.com

![GodotS Skate Preview](/img/character_preview.png)

# Skatepark Asset Setup

Skatepark elements need to be imported in the gltf format. Objects inside the gltf files need to follow a strict naming convention.

I´m using the godot **_Col** Suffix to automatically create mesh colliders on the import.

https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/node_type_customization.html

The structure of a skatepark element or whole park should be as in the following example.

- GLTF
  - Skatepark_**Mesh**
  - Skatepark_**Col_Wall**
  - Skatepark_**Col_Floor**
  - Skatepark_**Col_Pipe**
  - Skatepark_**Rail**_A

> [!TIP]
> A skatepark element can contain only one element. For example a halfpipe or a rail. But it is possible to export a whole skatepark in a single gltf file.

## Description
- **Col_Wall** Creates wall colliders
 - **Col_Floor** Creates floor colliders
- **Col_Pipe** Creates the floor for halfpipes
- **Rail** Creates a rail from a polyline 

## Automatic Godot Setup

I generated a import script to automate the generation of rails, assignment of wall, floor and pipe colliders.

### Script usage

Assign the script `res://Scripts/Editor/park_import.gd` as the import script of a gltf file and reimport it.

## Rail Setup in Blender

Rails are imported as polylines from blender. These polylines require a clean vertex order.

I create a small Geometrynodes setup to get a clean polyline. The nodegroup converts a mesh into a curve and then back into a polyline.

> [!CAUTION]
> Every rail requires its own polyline.

![Geonodes Vertexorder](/img/vertexorder.png)