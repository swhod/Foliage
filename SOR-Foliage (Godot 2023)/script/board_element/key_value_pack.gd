class_name KeyValuePack
extends RefCounted
## There are two possible ways to manage key-value pairs: [Dictionary], which can be more efficient at storage;
## and [Array], which is straightforward when iterating. This class is designed as a compatible solution.
##
## In array form, a pack should be [b]an array containing key-value pairs[/b]:
## [codeblock]
## [["odd", 1], ["odd", 3], ["odd", 5], ["even", 2]]
## [/codeblock]
## [br]And in dictionary form, [b]values are put together in an array if sharing the same key[/b]:
## [codeblock]
## {"odd": [1, 3, 5], "even": 2}
## [/codeblock]
## [br]Both forms are accepted by this class. Besides, [b]a single pair is also supported[/b]. 
## All valid forms are listed in [enum KeyValuePack.PackType].
## [br]For the usage of going through all pairs, this class has its own iterator:
## [codeblock]
## pack = KeyValuePack.new({"A": ["B", "C"]})
## for pair in pack:
##     print(pair)
## # Will print ["A", "B"], ["A", "C"].
## [/codeblock]

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## The index of key in key-value pairs.
const KEY = 0
## The index of value in key-value pairs.
const VALUE = 1

enum PackType {
	KVPAIR, ## An array containing exactly two non-container elements.
	ARPACK, ## An array containing key-value pairs.
	DIPACK, ## A dictionary putting together values of the same key.
	KVPACK, ## An instance of this class.
	INVALID = -1, ## Invalid case.
}

enum KeyState {
	HAS_EMPTY, ## The key has no value in the pack.
	HAS_VALUE, ## The key has at least one value in the pack.
	HAS_ARRAY, ## The key has a non-empty array in the pack.
	INVALID = -1, ## Invalid case.
}

# (private)
# The dictionary containing stored pairs.
var _stored_pack: Dictionary = {}

# (private)
# The callable method to map values when inputting.
var _input_map: Callable = func(e): return e

# (private)
# The callable method to map values when outputting.
var _output_map: Callable = func(e): return e

# (private)
# The default bool value of permitting redundancy.
var _redundant: bool = false

# (initialization)
# The constructor of this class when instantiating.
func _init(from = {}, 
		init_input_map := func(e): return e,
		init_output_map := func(e): return e, 
		init_redundant := false):
	self._redundant = init_redundant
	self._output_map = init_output_map
	self._input_map = init_input_map
	self._stored_pack = KeyValuePack._pack_to_pack(from, PackType.DIPACK, init_redundant)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (read-only)
## Returns [code]true[/code] if all pairs given by [param pack] exist.
func has_pack(pack) -> bool:
	return KeyValuePack._pack_iterator(pack, func(kvpair): return KeyValuePack._pack_has_kvpair(self, kvpair))

# (read-only)
## Returns a new dictionary pack converted from this pack.
func to_dipack() -> Dictionary:
	return KeyValuePack._pack_to_pack(self, PackType.DIPACK, self._redundant)

# (read-only)
## Returns a new array pack converted from this pack.
func to_arpack() -> Array:
	return KeyValuePack._pack_to_pack(self, PackType.ARPACK, self._redundant)

# (writing)
## Set the value-mapping method that always called when inputting.
func set_input_map(input_map: Callable) -> void:
	self._input_map = input_map

# (writing)
## Set the value-mapping method that always called when outputting.
func set_output_map(output_map: Callable) -> void:
	self._output_map = output_map

# (writing)
## Set the bool value of redundancy-permitting.
func set_redundant(redundant) -> void:
	self._redundant = redundant

# (writing)
## Add pairs given by [param pack].
func add_pack(pack) -> void:
	KeyValuePack._pack_iterator(pack, func(kvpair): KeyValuePack._pack_add_kvpair(self, kvpair, self._redundant))

# (writing)
## Delete pairs given by [param pack].
func delete_pack(pack) -> void:
	KeyValuePack._pack_iterator(pack, func(kvpair): KeyValuePack._pack_delete_kvpair(self, kvpair))

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (iteration)
# Several variables declared for iterator.
var _iter_keys: Array
var _iter_x: int
var _iter_y: int
var _iter_keystate: int
var _iter_k: Variant
var _iter_v: Variant
var _iter_return: Array

# (iteration)
# The continuing judgement of iterator.
func _iter_continue() -> bool:
	while self._iter_x < self._iter_keys.size():
		self._iter_k = self._iter_keys[self._iter_x]
		self._iter_keystate = KeyValuePack._pack_get_keystate(self, self._iter_k)
		if self._iter_keystate != KeyState.HAS_EMPTY: break
		self._iter_x += 1
	return self._iter_x < self._iter_keys.size()

# (iteration)
# The initial statement of iterator.
func _iter_init(_arg) -> bool:
	self._iter_keys = self._stored_pack.keys()
	self._iter_x = 0
	self._iter_y = 0
	return self._iter_continue()

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
	return self._iter_continue()

# (iteration)
# The returning variant of iterator.
func _iter_get(_arg) -> Array:
	self._iter_return.clear()
	self._iter_return.append(self._iter_k)
	self._iter_v = self._stored_pack[self._iter_k]
	match self._iter_keystate:
		KeyState.HAS_VALUE: self._iter_return.append(self._iter_v)
		KeyState.HAS_ARRAY: self._iter_return.append(self._iter_v[self._iter_y])
	self._iter_return = self._output_map.call(self._iter_return)
	return self._iter_return

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (static)
# Returns true if the variant is a dictionary or an array.
static func _variant_is_container(v) -> bool:
	match typeof(v):
		TYPE_ARRAY, TYPE_DICTIONARY: return true
		_: return false

# (static)
# Returns true if the pack is a key-value pair.
static func _pack_is_kvpair(pack) -> bool:
	if typeof(pack) != TYPE_ARRAY: return false
	if pack.size() != 2: return false
	return not _variant_is_container(pack[KEY]) and \
			not _variant_is_container(pack[VALUE])

# (static)
# Returns true if the pack is a valid array pack.
static func _pack_is_arpack(pack) -> bool:
	if typeof(pack) != TYPE_ARRAY: return false
	return pack.all(func(e): return _pack_is_kvpair(e))

# (static)
# Returns true if the pack is a valid dictionary pack.
static func _pack_is_dipack(pack) -> bool:
	if typeof(pack) != TYPE_DICTIONARY: return false
	for k in pack:
		if not _variant_is_container(pack[k]): continue
		if typeof(pack[k]) == TYPE_DICTIONARY: return false
		if pack[k].any(func(e): return _variant_is_container(e)): return false
	return true

# (static)
# Returns true if the pack is a key-value pack.
static func _pack_is_kvpack(pack) -> bool:
	return pack is KeyValuePack

# (static)
# Returns the type in KeyValuePack.PackType of given pack.
static func _pack_get_packtype(pack) -> int:
	if _pack_is_kvpair(pack): return PackType.KVPAIR
	if _pack_is_arpack(pack): return PackType.ARPACK
	if _pack_is_dipack(pack): return PackType.DIPACK
	if _pack_is_kvpack(pack): return PackType.KVPACK
	return PackType.INVALID

# (static)
# Returns the state in KeyValuePack.KeyState of given key in given pack.
static func _pack_get_keystate(pack, key) -> int:
	if _variant_is_container(key): return KeyState.INVALID
	match _pack_get_packtype(pack):
		PackType.KVPAIR:
			return KeyState.HAS_EMPTY if pack[KEY] != key or pack[VALUE] == null else \
					 KeyState.HAS_VALUE
		PackType.ARPACK:
			return KeyState.HAS_EMPTY if pack.all(func(kvpair): return kvpair[KEY] != key) else \
					KeyState.HAS_VALUE
		PackType.DIPACK:
			return KeyState.HAS_EMPTY if not pack.has(key) else \
					KeyState.HAS_VALUE if typeof(pack[key]) != TYPE_ARRAY else \
					KeyState.HAS_EMPTY if pack[key].is_empty() else \
					KeyState.HAS_ARRAY
		PackType.KVPACK:
			return _pack_get_keystate(pack._stored_pack, key)
		_: 
			return KeyState.INVALID

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (static)
# Call the method for all key-value pairs read from given pack.
static func _pack_iterator(pack,
		method_on_pair: Callable,
		method_on_return: Callable = func(all, r): return all if r else r,
		init_return = true):
	var pack_return = init_return
	match _pack_get_packtype(pack):
		PackType.KVPAIR:
			pack_return = method_on_return.call(pack_return, method_on_pair.call(pack.duplicate()))
		PackType.ARPACK, PackType.KVPACK:
			for pair in pack:
				pack_return = method_on_return.call(pack_return, method_on_pair.call(pair))
		PackType.DIPACK:
			for k in pack:
				if _variant_is_container(pack[k]):
					for v in pack[k]:
						pack_return = method_on_return.call(pack_return, method_on_pair.call([k, v]))
				else:
					pack_return = method_on_return.call(pack_return, method_on_pair.call([k, pack[k]]))
	return pack_return

# (static)
# Returns true if the given pack has given key-value pair.
static func _pack_has_kvpair(pack, kvpair) -> bool:
	if not _pack_is_kvpair(kvpair): return false
	match _pack_get_packtype(pack):
		PackType.KVPAIR: return pack == kvpair
		PackType.ARPACK: return pack.has(kvpair)
		PackType.DIPACK:
			match _pack_get_keystate(pack, kvpair[KEY]):
				KeyState.HAS_EMPTY: return false
				KeyState.HAS_VALUE: return pack[kvpair[KEY]] == kvpair[VALUE]
				KeyState.HAS_ARRAY: return pack[kvpair[KEY]].has(kvpair[VALUE])
		PackType.KVPACK: return _pack_has_kvpair(pack._stored_pack, kvpair)
	return false

# (static)
# Add the data from given key-value pair to given pack.
# When redundant is false, ignore the pair if it already exists.
static func _pack_add_kvpair(pack, kvpair, redundant := false) -> void:
	if not _pack_is_kvpair(kvpair): return
	if _pack_has_kvpair(pack, kvpair) and not redundant: return
	match _pack_get_packtype(pack):
		PackType.KVPAIR: pack.assign(kvpair)
		PackType.ARPACK: pack.append([kvpair[KEY], kvpair[VALUE]])
		PackType.DIPACK:
			match _pack_get_keystate(pack, kvpair[KEY]):
				KeyState.HAS_EMPTY: pack[kvpair[KEY]] = kvpair[VALUE]
				KeyState.HAS_VALUE: pack[kvpair[KEY]] = [pack[kvpair[KEY]], kvpair[VALUE]]
				KeyState.HAS_ARRAY: pack[kvpair[KEY]].append(kvpair[VALUE])
		PackType.KVPACK: _pack_add_kvpair(pack._stored_pack, pack._input_map.call(kvpair), redundant)

# (static)
# Delete certain key-value pair in given pack.
static func _pack_delete_kvpair(pack, kvpair) -> void:
	if not _pack_is_kvpair(kvpair): return
	if not _pack_has_kvpair(pack, kvpair): return
	match _pack_get_packtype(pack):
		PackType.KVPAIR: pack.fill(null)
		PackType.ARPACK: pack.erase(kvpair)
		PackType.DIPACK:
			match _pack_get_keystate(pack, kvpair[KEY]):
				KeyState.HAS_EMPTY: pass
				KeyState.HAS_VALUE: pack.erase(kvpair[KEY])
				KeyState.HAS_ARRAY: pack[kvpair[KEY]].erase(kvpair[VALUE])
		PackType.KVPACK: _pack_delete_kvpair(pack._stored_pack, pack._input_map.call(kvpair))

# (static)
# Returns a new pack in given packtype converted from given pack.
static func _pack_to_pack(pack, packtype := PackType.KVPACK, redundant := false):
	var new_pack
	match packtype:
		PackType.KVPAIR: new_pack = [null, null]
		PackType.ARPACK: new_pack = []
		PackType.DIPACK: new_pack = {}
		PackType.KVPACK: new_pack = KeyValuePack.new()
	_pack_iterator(pack, func(kvpair): _pack_add_kvpair(new_pack, kvpair, redundant))
	return new_pack
