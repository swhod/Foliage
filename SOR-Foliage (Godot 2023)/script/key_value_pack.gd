class_name KeyValuePack
extends RefCounted
## [br]There are at least two ways to manage key-value pairs,
## [Dictionary] and [Array]:
## Dictionaries are more efficient for long-term storage,
## while arrays are more straightforward in temporary case.
## This class is designed to provide a compatible solution.
##
## In array form, a pack should be [b]an array containing
## key-value pairs[/b]:
## [codeblock]pack = [["odd", 1], ["odd", 3], ["odd", 5],
## ["even", 2]][/codeblock]
## [br]And in dictionary form, [b]values are put together
## in an array when sharing the same key[/b]:
## [codeblock]
## pack = {
##     "odd": [1, 3, 5],
##     "even": 2,
## }
## [/codeblock]
## [br]Both forms are accepted by this class. The dictionary
## form is automatically applied when storing, while the
## custom iterator provides the data in array form. 
## [codeblock]
## pack = {"A": ["B", "C"]}
## for kvpair in pack:
##     print(kvpair) # Will print ["A", "B"], ["A", "C"].
## [/codeblock]

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const KEY = 0
const VALUE = 1

enum PackType {
	KVPAIR, ## An array containing exactly two non-container elements.
	ARRAY_PACK, ## An array pack containing key-value pairs.
	DICTIONARY_PACK, ## A dictionary pack (see [i]Description[/i] above).
	INVALID = -1, ## Invalid case.
}

enum KeyState {
	NONE, ## The key doesn't exist in the pack.
	HAS_VALUE, ## The key has at least one corresponding value in the pack.
	HAS_ARRAY, ## The key has an corresponding array in the pack.
	INVALID = -1, ## Invalid case.
}

# (private)
# The dictionary of stored data.
var _stored_pack: Dictionary = {}

# (private)
# The callable method for mapping values in iteration.
var _iter_map: Callable = func(e): return e

# (initialization)
# The constructor of this class when instantiating.
func _init(from = {}, method: Callable = func(e): return e):
	self._stored_pack = KeyValuePack.pack_to_dict(from)
	self._iter_map = method

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## (read-only)
## [br]Returns the state of given key.
func get_keystate(key) -> int:
	return KeyValuePack.pack_get_keystate(self, key)

## (read-only)
## [br]Returns [code]true[/code] if the given key-value pair exists.
func has_kvpair(kvpair) -> bool:
	return KeyValuePack.pack_has_kvpair(self, kvpair)

## (static, container read-only)
## [br]Call the method for all key-value pairs.
func for_all(method: Callable) -> void:
	return KeyValuePack.pack_for_all(self, method)

## (writing)
## [br]Map every value to a new value by given callable method.
func do_map(method: Callable) -> void:
	return KeyValuePack.pack_do_map(self, method)

## (writing)
## [br]Set the value-mapping method for this instance's iterator.
func set_iter_map(method: Callable) -> void:
	self._iter_map = method

## (writing)
## [br]Delete certain key-value pair.
func delete_kvpair(kvpair) -> void:
	return KeyValuePack.pack_delete_kvpair(self, kvpair)

## (writing)
## [br]Add the data from given key-value pair.
## [br]When [param redundant] is [code]false[/code], 
## ignore the pair if it already exists.
func add_kvpair(kvpair, redundant := false) -> void:
	return KeyValuePack.pack_add_kvpair(self, kvpair, redundant)

## (writing)
## [br]Delete data given by the pack.
func delete_pack(pack) -> void:
	return KeyValuePack.pack_delete_pack(self, pack)

## (writing)
## [br]Add data from given pack.
## [br]When [param redundant] is [code]false[/code], 
## ignore any redundant pair.
func add_pack(pack, redundant := false) -> void:
	return KeyValuePack.pack_add_pack(self, pack, redundant)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (iteration)
# Several variables declared for iterator.
var _iter_keys: Array
var _iter_x: int
var _iter_y: int
var _iter_keystate: int
var _iter_v: Variant
var _iter_return: Array

# (iteration)
# The continuing judgement of iterator.
func _iter_continue() -> bool:
	while self._iter_x < self._iter_keys.size():
		self._iter_keystate = self.get_keystate(self._iter_keys[self._iter_x])
		if self._iter_keystate != KeyState.NONE: break
		self._iter_x += 1
	return self._iter_x < self._iter_keys.size()

# (iteration)
# The initial statement of iterator.
func _iter_init(_arg) -> bool:
	self._iter_keys = self._stored_pack.keys()
	self._iter_x = 0
	self._iter_y = 0
	return _iter_continue()

# (iteration)
# The recurring statement of iterator.
func _iter_next(_arg) -> bool:
	match self._iter_keystate:
		KeyState.HAS_VALUE: self._iter_x += 1
		KeyState.HAS_ARRAY: 
			self._iter_y += 1
			if not self._iter_y < self._iter_v.size():
				self._iter_x += 1
				self._iter_y = 0
	return _iter_continue()

# (iteration)
# The returning variant of iterator.
func _iter_get(_arg) -> Array:
	self._iter_return.clear()
	self._iter_return.append(self._iter_keys[self._iter_x])
	self._iter_v = self._stored_pack[self._iter_keys[self._iter_x]]
	match self._iter_keystate:
		KeyState.HAS_VALUE: self._iter_return.append(self._iter_v)
		KeyState.HAS_ARRAY: self._iter_return.append(self._iter_v[self._iter_y])
	self._iter_return[VALUE] = self._iter_map.call(self._iter_return[VALUE])
	return self._iter_return

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## (static)
## [br]Returns [code]true[/code] if the variant is a dictionary or an array.
static func variant_is_container(v) -> bool:
	match typeof(v):
		TYPE_ARRAY, TYPE_DICTIONARY: return true
		_: return false

## (static)
## [br]Returns [code]true[/code] if the pack is a key-value pair.
static func pack_is_kvpair(pack) -> bool:
	if typeof(pack) != TYPE_ARRAY: return false
	if pack.size() != 2: return false
	return not variant_is_container(pack[KEY]) and \
			not variant_is_container(pack[VALUE])

## (static)
## [br]Returns [code]true[/code] if the pack is a valid array pack.
static func pack_is_array_pack(pack) -> bool:
	if typeof(pack) != TYPE_ARRAY: return false
	return pack.all(func(e): return pack_is_kvpair(e))

## (static)
## [br]Returns [code]true[/code] if the pack is a valid dictionary pack.
static func pack_is_dictionary_pack(pack) -> bool:
	if typeof(pack) != TYPE_DICTIONARY: return false
	for k in pack:
		if not variant_is_container(pack[k]): continue
		if typeof(pack[k]) == TYPE_DICTIONARY: return false
		if pack[k].any(func(e): return variant_is_container(e)): return false
	return true

## (static)
## [br]Returns [code]true[/code] if the pack can be treated as a key-value pack.
static func pack_is_kvpack(pack) -> bool:
	return "_stored_pack" in pack

## (static)
## [br]Returns the type of given pack.
static func pack_get_packtype(pack) -> int:
	if pack_is_kvpair(pack): return PackType.KVPAIR
	if pack_is_array_pack(pack): return PackType.ARRAY_PACK
	if pack_is_dictionary_pack(pack): return PackType.DICTIONARY_PACK
	return PackType.INVALID

## (static, container read-only)
## [br]Returns the state of given key in given pack.
static func pack_get_keystate(pack, key) -> int:
	if variant_is_container(key): return KeyState.INVALID
	match pack_get_packtype(pack):
		PackType.KVPAIR:
			return KeyState.NONE if key != pack[KEY] else \
					 KeyState.HAS_VALUE
		PackType.ARRAY_PACK:
			return KeyState.NONE if pack.all(func(kvpair): return kvpair[KEY] != key) else \
					KeyState.HAS_VALUE
		PackType.DICTIONARY_PACK:
			return KeyState.NONE if not pack.has(key) else \
					KeyState.HAS_VALUE if typeof(pack[key]) != TYPE_ARRAY else \
					KeyState.NONE if pack[key].is_empty() else \
					KeyState.HAS_ARRAY
	if pack_is_kvpack(pack): return pack_get_keystate(pack._stored_pack, key)
	return KeyState.INVALID

## (static, container read-only)
## [br]Returns [code]true[/code] if the given pack has given key-value pair.
static func pack_has_kvpair(pack, kvpair) -> bool:
	if not pack_is_kvpair(kvpair): return false
	match pack_get_packtype(pack):
		PackType.KVPAIR: return pack == kvpair
		PackType.ARRAY_PACK: return pack.has(kvpair)
		PackType.DICTIONARY_PACK:
			match pack_get_keystate(pack, kvpair[KEY]):
				KeyState.NONE: return false
				KeyState.HAS_VALUE: return pack[kvpair[KEY]] == kvpair[VALUE]
				KeyState.HAS_ARRAY: return pack[kvpair[KEY]].has(kvpair[VALUE])
				_: return false
	if pack_is_kvpack(pack): return pack_has_kvpair(pack._stored_pack, kvpair)
	return false

## (static, container read-only)
## [br]Call the method for all key-value pairs in given pack.
static func pack_for_all(pack, method: Callable) -> void:
	match pack_get_packtype(pack):
		PackType.KVPAIR: method.call(pack)
		PackType.ARRAY_PACK:
			for kvpair in pack:
				method.call(kvpair)
		PackType.DICTIONARY_PACK:
			for k in pack:
				if variant_is_container(pack[k]):
					for v in pack[k]:
						method.call([k, v])
				else:
					method.call([k, pack[k]])
	if pack_is_kvpack(pack): pack_for_all(pack._stored_pack, method)

## (static, container writing)
## [br]Map every value of given pack to a new value by given callable method.
static func pack_do_map(pack, method: Callable) -> void:
	match pack_get_packtype(pack):
		PackType.KVPAIR:
			pack[VALUE] = method.call(pack[VALUE])
		PackType.ARRAY_PACK:
			for kvpair in pack:
				kvpair[VALUE] = method.call(kvpair[VALUE])
		PackType.DICTIONARY_PACK:
			for k in pack:
				if variant_is_container(pack[k]):
					for i in pack[k].size():
						pack[k][i] = method.call(pack[k][i])
				else:
					pack[k] = method.call(pack[k])
	if pack_is_kvpack(pack): return pack_do_map(pack._stored_pack, method)

## (static, container writing)
## [br]Delete certain key-value pair in given pack.
static func pack_delete_kvpair(pack, kvpair) -> void:
	if not pack_is_kvpair(kvpair): return
	match pack_get_packtype(pack):
		PackType.KVPAIR:
			pack[KEY] = null
			pack[VALUE] = null
		PackType.ARRAY_PACK:
			pack.erase(kvpair)
		PackType.DICTIONARY_PACK:
			match pack_get_keystate(pack, kvpair[KEY]):
				KeyState.HAS_VALUE: 
					pack.erase(kvpair[KEY])
				KeyState.HAS_ARRAY: 
					pack[kvpair[KEY]].erase(kvpair[VALUE])
	if pack_is_kvpack(pack): return pack_delete_kvpair(pack._stored_pack, kvpair)

## (static, container writing)
## [br]Add the data from given key-value pair to given pack.
## [br]When [param redundant] is [code]false[/code], 
## ignore the pair if it already exists.
static func pack_add_kvpair(pack, kvpair, redundant := false) -> void:
	if not pack_is_kvpair(kvpair): return
	if pack_has_kvpair(pack, kvpair) and not redundant: return
	match pack_get_packtype(pack):
		PackType.KVPAIR:
			pack[KEY] = kvpair[KEY]
			pack[VALUE] = kvpair[VALUE]
		PackType.ARRAY_PACK:
			pack.append([kvpair[KEY], kvpair[VALUE]])
		PackType.DICTIONARY_PACK:
			match pack_get_keystate(pack, kvpair[KEY]):
				KeyState.NONE: 
					pack[kvpair[KEY]] = kvpair[VALUE]
				KeyState.HAS_VALUE: 
					pack[kvpair[KEY]] = [pack[kvpair[KEY]], kvpair[VALUE]]
				KeyState.HAS_ARRAY: 
					pack[kvpair[KEY]].append(kvpair[VALUE])
	if pack_is_kvpack(pack): return pack_add_kvpair(pack._stored_pack, kvpair, redundant)

## (static, container writing)
## [br]Delete data given by the second pack in the first pack.
static func pack_delete_pack(pack1, pack2) -> void:
	pack_for_all(pack2, func(kvpair): pack_delete_kvpair(pack1, kvpair))

## (static, container writing)
## [br]Add data of the second pack to the first pack.
## [br]When [param redundant] is [code]false[/code], 
## ignore any redundant pair.
static func pack_add_pack(pack1, pack2, redundant := false) -> void:
	pack_for_all(pack2, func(kvpair): pack_add_kvpair(pack1, kvpair, redundant))

## (static, container producing)
## [br]Returns a new dictionary converted from given pack.
## [br]When [param redundant] is [code]false[/code], 
## ignore any redundant pair.
static func pack_to_dict(pack, redundant := false) -> Dictionary:
	var dict := {}
	pack_add_pack(dict, pack, redundant)
	return dict

## (static, container producing)
## [br]Returns a new array converted from given pack.
## [br]When [param redundant] is [code]false[/code], 
## ignore any redundant pair.
static func pack_to_arr(pack, redundant := false) -> Array:
	var arr := []
	pack_add_pack(arr, pack, redundant)
	return arr
