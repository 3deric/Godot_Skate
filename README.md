# GodotSkate
Skate game prototype in Godot
![GodotS Skate Preview](/img/preview.png)
![GodotS Skate Preview](/img/character_preview.png)
Textures by https://www.kenney.nl/
Characters are based on low res metahuman characters by EPIC Games.

# Class Documentation
I tried to keep most classes, their methods and additional functions self explainatory.

## character_statemachine

Handles state changes, keeps track of the current and previous state.

## character_input

Input handler for movement and tricks.

## character_controller

Main controller, handles the movement logic.

## character_animation

Handles animation states based on player state and input. Applies visual transform to the player to smooth the motion.

## character_ragdoll

Enables and disables the character ragdoll.

## character_tricks

Handles trick execution for the player. Trick execution is based on the character_input input_buffer.

## debug_view

Displays debugging information of the player controller.

## ingame_overlay

Handles the ui for the rail and lip balance view. Displays if the player has fallen.

## character_customization

## character_data

## customization manager

## setup_park

Park setup runs only in the editor. It requires 3d models as packed gltf scenes.

Select a packed gltf-scene in the editor and run the script.

### setup_park requirements
![Park Setup](/img/parksetup.png)

- *assetname*_Col_Pipe -> **Pipe collision**
- *assetname*_Col_Floor -> **Floor collision**
- *assetname*_Col_Wall -> **Wall collision**
- *assetname*_Rail_*X* -> **Rail line**
- *assetname*_Rail_*X*_Closed -> **Closed Rail line**

The script generates colliders for floor, wall and pipes. Concave colliders are created for each mesh. Keep them simple inside of your DCC. Curve objects for rails are generated from polylines. Each rail needs a unique identifier. For example A,B,C etc. Rails need to be created as polylines. You need to take care of the vertex order. 

### rail vertex order requirements

The rail generation requires a proper vertex order of the source polyline. Geometrynodes can be used to create a proper vertex order. To order the vertices you can convert the polyline to a curve and then back to a mesh in blender. This will order vertices based on connectivity.
![Order Vertices](/img/vertexorder.png)
