class_name KeyValuePack
extends Object
## There are at least two ways to manage key-value pairs,
## [Dictionary] and [Array]:
## Dictionaries are more efficient for long-term storage,
## while arrays are more straightforward in temporary case.
## This class is designed to provide a compatible solution.
##
## In array form, a pack should be [b]an array containing
## key-value pairs[/b]:
## [codeblock]pack = [[1, 2], [1, -5], ["key", "value"],
## [Vector2i.ZERO, true]][/codeblock]
## [br]And in dictionary form, [b]values are put together
## in an array if they share the same key[/b]:
## [codeblock]
## pack = {
##     1: [2, -5],
##     "key": "value",
##     Vector2i.ZERO: true
## }
## [/codeblock]
## [br]Both forms are accepted by this class. The dictionary
## form is automatically applied when storing, while the
## iterator provides the data in array form.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const KEY = 0
const VALUE = 1

enum PackType {
	KVPAIR, 
	ARRAY_PACK, 
	DICTIONARY_PACK,
	NOT_A_PACK = -1,
}

# (private)
# The dictionary of stored data.
var _stored_data: Dictionary = {}

# (initialization)
# The constructor of this class when instantiating.
func _init(from = {}):
	pass

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## (static)
## Returns true if the variant is a dictionary or an array.
static func is_container(v) -> bool:
	match typeof(v):
		TYPE_ARRAY, TYPE_DICTIONARY: return true
		_: return false

## (static)
## Returns true if the variant is a key-value pair.
static func is_kvpair(arr) -> bool:
	if typeof(arr) != TYPE_ARRAY: return false
	return not is_container(arr[KEY]) and \
			not is_container(arr[VALUE]) and \
			arr.size() == 2

## (static)
## Returns true if the variant is a valid array pack.
static func is_array_pack(arr) -> bool:
	if typeof(arr) != TYPE_ARRAY: return false
	for e in arr:
		if not is_kvpair(arr): return false
	return true

## (static)
## Returns true if the variant is a valid dictionary pack.
static func is_dictionary_pack(dict) -> bool:
	if typeof(dict) != TYPE_DICTIONARY: return false
	for k in dict:
		match typeof(dict[k]):
			TYPE_DICTIONARY: return false
			TYPE_ARRAY:
				for v in dict[k]:
					if is_container(v): return false
	return true

## (static)
## Returns the type of given pack.
static func get_packtype(pack) -> int:
	if is_kvpair(pack): return PackType.KVPAIR
	if is_array_pack(pack): return PackType.ARRAY_PACK
	if is_dictionary_pack(pack): return PackType.DICTIONARY_PACK
	return PackType.NOT_A_PACK

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## (static, container writing)
## Add the data from given key-value pair to given pack.
static func append_kvpair(pack, kvpair):
	if is_kvpair(kvpair):
		match get_packtype(pack):
			PackType.ARRAY_PACK:
				pack.append([kvpair[KEY], kvpair[VALUE]])
			PackType.DICTIONARY_PACK:
				if kvpair[KEY] not in pack:
					pack[kvpair[KEY]] = kvpair[VALUE]
				else:
					if not is_container(pack[kvpair[KEY]]):
						pack[kvpair[KEY]] = [pack[kvpair[KEY]]]
					pack[kvpair[KEY]].append(kvpair[VALUE])

## (static, container writing)
## Add the given addition to every value of given pack.
## [br]WARNING: Make sure the addition is valid.
static func shift(pack, addition):
	match get_packtype(pack):
		PackType.KVPAIR:
			pack[VALUE] += addition
		PackType.ARRAY_PACK:
			for kvpair in pack:
				kvpair[VALUE] += addition
		PackType.DICTIONARY_PACK:
			for k in pack:
				if not is_container(pack[k]):
					pack[k] += addition
				else:
					for v in pack[k]:
						v += addition

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## (static, container producing)
## Returns a new dictionary pack converted from given pack.
static func pack_to_dict(pack) -> Dictionary:
	match typeof(pack):
		TYPE_DICTIONARY:
			return pack.duplicate()
		_:
			var dict := {}
			if is_kvpair(pack):
				dict[pack[KEY]] = pack[VALUE]
			elif is_array_pack(pack):
				for kva in pack:
					if kva[KEY] not in dict:
						dict[kva[KEY]] = []
					dict[kva[KEY]].append(kva[VALUE])
			return dict

## (static, container producing)
## Returns a new array pack converted from given pack.
static func pack_to_arr(pack := {}) -> Array:
	var kvaa := []
	for k in pack:
		if typeof(pack[k]) == TYPE_ARRAY:
			for v in pack[k]:
				kvaa.append([k, v])
		else:
			kvaa.append([k, pack[k]])
	return kvaa
