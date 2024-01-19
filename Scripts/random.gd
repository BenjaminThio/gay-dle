class_name Random extends Node

static func choice(seq):
	if typeof(seq) in [TYPE_ARRAY, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_COLOR_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY]:
		return seq[randi() % seq.size()]

static func choices(seq, k: int = 1) -> Array:
	var result: Array = []
	
	for _i in range(k):
		result.append(choice(seq))
	
	return result

static func sample(seq, k: int = 1):
	var result: Array = []
	var duplicated_seq = seq.duplicate(true)
	
	if k > duplicated_seq.size():
		var error: String = "ValueError: Sample larger than population or is negative"
		
		printerr(error)
		push_error(error)
		return
	
	for _i in range(k):
		var random_index = randi() % duplicated_seq.size()
		
		result.append(duplicated_seq[random_index])
		duplicated_seq.pop_at(random_index)
	
	return result
