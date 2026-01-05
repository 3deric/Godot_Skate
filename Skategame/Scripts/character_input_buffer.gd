class_name InputBuffer

const MAX_SIZE := 4 
var buffer: Array[int] = []

func push(action: int):
	buffer.append(action)
	if buffer.size() > MAX_SIZE:
		buffer.pop_front()

func clear():
	buffer.clear()
	
func debug():
	print(buffer)
