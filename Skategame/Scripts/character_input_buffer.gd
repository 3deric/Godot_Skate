class_name InputBuffer

const MAX_SIZE : int = 8
const COOLDOWN : float = 0.5
var buffer: Array[int] = []
var cooldown : float = 0

func push(action: int):
	buffer.append(action)
	if buffer.size() > MAX_SIZE:
		buffer.pop_front()
	_set_cooldown()

func clear():
	buffer.clear()
	
func debug():
	print(buffer)

func get_last_input() -> int:
	var _size : int = buffer.size()
	if _size > 0:
		return buffer[_size -1]
	return -1
	
func get_second_last_input() -> int:
	var _size : int = buffer.size()
	if _size >= 2:
		return buffer[_size - 2]
	return -1
	
func _set_cooldown() -> void:
	cooldown = COOLDOWN
		
func input_cooldown(_delta) -> void:
	if cooldown > 0:
		cooldown -= _delta
	else:
		buffer.pop_front()
		_set_cooldown()
		
func get_buffer_cooldown() -> bool:
	return cooldown <= 0

func get_buffer_updated() -> bool:
	return cooldown == COOLDOWN
