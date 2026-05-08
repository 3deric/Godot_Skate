@tool
extends EditorScenePostImport

const OFFSET : float = 0.05
const PATH_INTERVAL : float = 0.25

func _post_import(scene):
	var nodes : Array = scene.get_children()
	for node in nodes:
		if node.name.split('_')[1] == 'Col':
			setup_static_body(node)
			
		if node.name.split('_')[1] == 'Rail':
			setup_rail(node, scene)
	return scene

func setup_static_body(node : Node3D) -> void:
	var name = node.name
	match name.split('_')[2]:
		'Floor':
			node.add_to_group('floor', true)
		'Wall':
			node.add_to_group('wall', true)
		'Pipe':
			node.add_to_group('pipe', true)
			
func setup_rail(node : Node3D, scene : Node3D) -> void:
	var parent : Node = node.get_parent()
	var name = node.name
	var _csg: CSGPolygon3D = CSGPolygon3D.new()
	var _mesh = node.get_mesh()
	var _mesh_arrays = _mesh.surface_get_arrays(0)
	var _path : Path3D = Path3D.new()
	var _curve: Curve3D = Curve3D.new()
	for i : int in len(_mesh_arrays[0]):
		#add points with parent offset
		var _pos : Vector3 = _mesh_arrays[0][i]
		var _t : Transform3D = parent.transform.affine_inverse()
		_pos *= _t
		_curve.add_point(_pos)
	if name.split('_')[2] == 'Closed':
		_curve.closed = true
		
	# add path and csg to the scene
	_path.curve = _curve
	parent.add_child(_path)
	_path.owner = scene
	_path.name = name + "_Path"
	_path.add_child(_csg)
	_csg.owner = scene
	_csg.name = name + "_CSG"

	#offset _path to the scene orgin
	#_path.global_position = Vector3.ZERO
	#_path.global_rotation = Vector3.ZERO
	
	#center extruded _path and change thickness
	_csg.mode = CSGPolygon3D.MODE_PATH
	_csg.path_interval = PATH_INTERVAL
	_csg.path_node = _csg.get_path_to(_path)
	_csg.polygon = PackedVector2Array([
		Vector2(-OFFSET/2, -OFFSET/2),
		Vector2(-OFFSET/2, OFFSET/2),
		Vector2(OFFSET/2, OFFSET/2),
		Vector2(OFFSET/2, -OFFSET/2),
		])
	#add _csg to rampRail group
	_csg.add_to_group('rampRail', true)
	#enable collision
	_csg.use_collision = true
	#set collision layer
	_csg.set_collision_layer_value(1,false)
	_csg.set_collision_layer_value(4,true)
	#turn off shadow casting
	_csg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	#set material
	_csg.material = load('res://Assets/Materials/M_path.tres')
	#_csg.set_script(load('res://Scripts/Editor/rail_init.gd'))
