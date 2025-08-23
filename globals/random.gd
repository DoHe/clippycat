class_name Random

static var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

static func shuffle(array: Array) -> void:
	for i in array.size() - 2:
		var j := RNG.randi_range(i, array.size() - 1)
		var tmp = array[i]
		array[i] = array[j]
		array[j] = tmp
