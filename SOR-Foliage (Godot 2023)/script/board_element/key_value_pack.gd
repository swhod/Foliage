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
	KVPAIR, ## An array containing exactly a key and a non-container value.
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
	self._stored_pack = KeyValuePack.pack_to_dict(from, init_redundant)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (read-only)
## Returns [code]true[/code] if all pairs given by [param pack] exist.
func has_pack(pack) -> bool:
	return KeyValuePack.pack_iterator(pack,
			func(kvpair): return KeyValuePack._dict_has_kvpair(self._stored_pack, kvpair),
			true,
			func(r, iter_r): return r if iter_r else false)

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
	KeyValuePack.pack_iterator(pack, func(kvpair): KeyValuePack._dict_add_kvpair(self._stored_pack, kvpair, self._redundant))

# (writing)
## Delete pairs given by [param pack].
func delete_pack(pack) -> void:
	KeyValuePack.pack_iterator(pack, func(kvpair): KeyValuePack._dict_delete_kvpair(self._stored_pack, kvpair))

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
		self._iter_keystate = KeyValuePack._dict_get_keystate(self._stored_pack, self._iter_k)
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
	return true if v is Array or v is Dictionary else false

# (static)
# Returns true if the pack is a key-value pair.
static func _pack_is_kvpair(pack) -> bool:
	if not pack is Array: return false
	if pack.size() != 2: return false
	return not _variant_is_container(pack[VALUE])

# (static)
# Returns true if the pack is a valid array pack.
static func _pack_is_arpack(pack) -> bool:
	if not pack is Array: return false
	return pack.all(func(e): return _pack_is_kvpair(e))

# (static)
# Returns true if the pack is a valid dictionary pack.
static func _pack_is_dipack(pack) -> bool:
	if not pack is Dictionary: return false
	for k in pack:
		if pack[k] is Dictionary: return false
		if pack[k] is Array:
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (static)
# Returns the state in KeyValuePack.KeyState of given key in given dictionary.
static func _dict_get_keystate(dict: Dictionary, key) -> int:
	return KeyState.HAS_EMPTY if not dict.has(key) else \
			KeyState.INVALID if dict[key] is Dictionary else \
			KeyState.HAS_VALUE if not dict[key] is Array else \
			KeyState.HAS_EMPTY if dict[key].is_empty() else \
			KeyState.HAS_ARRAY

# (static)
# Returns true if the given dictionary has given key-value pair.
static func _dict_has_kvpair(dict: Dictionary, kvpair) -> bool:
	if not _pack_is_kvpair(kvpair): return false
	match _dict_get_keystate(dict, kvpair[KEY]):
		KeyState.HAS_VALUE: return dict[kvpair[KEY]] == kvpair[VALUE]
		KeyState.HAS_ARRAY: return dict[kvpair[KEY]].has(kvpair[VALUE])
		_: return false

# (static)
# Add the data from given key-value pair to given dictionary.
# When redundant is false, ignore the pair if it already exists.
static func _dict_add_kvpair(dict: Dictionary, kvpair, redundant := false) -> void:
	if not _pack_is_kvpair(kvpair): return
	if _dict_has_kvpair(dict, kvpair) and not redundant: return
	match _dict_get_keystate(dict, kvpair[KEY]):
		KeyState.HAS_EMPTY: dict[kvpair[KEY]] = kvpair[VALUE]
		KeyState.HAS_VALUE: dict[kvpair[KEY]] = [dict[kvpair[KEY]], kvpair[VALUE]]
		KeyState.HAS_ARRAY: dict[kvpair[KEY]].append(kvpair[VALUE])

# (static)
# Delete certain key-value pair in given dictionary.
static func _dict_delete_kvpair(dict: Dictionary, kvpair) -> void:
	if not _pack_is_kvpair(kvpair): return
	if not _dict_has_kvpair(dict, kvpair): return
	match _dict_get_keystate(dict, kvpair[KEY]):
		KeyState.HAS_VALUE: dict.erase(kvpair[KEY])
		KeyState.HAS_ARRAY: dict[kvpair[KEY]].erase(kvpair[VALUE])

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (static)
## Call [param method] for every pair in [param pack].
## [br]The default returning logic is equivalent to "any", which is to return [code]true[/code]
## if any [code]true[/code] is returned during iteration, else [code]false[/code]:
## [codeblock]
## init_r = false
## next_r = func(r, iter_r): return true if iter_r else r
## [/codeblock]
## [br]To adjust the logic, assign [param init_r] as starting value, and
## [param next_r] as the method to deal with values returned during iteration.
static func pack_iterator(pack, 
		method: Callable,
		init_r = false,
		next_r: Callable = func(r, iter_r): return true if iter_r else r):
	var r = init_r
	match _pack_get_packtype(pack):
		PackType.KVPAIR:
			r = next_r.call(r, method.call(pack.duplicate()))
		PackType.ARPACK, PackType.KVPACK:
			for pair in pack:
				r = next_r.call(r, method.call(pair))
		PackType.DIPACK:
			for k in pack:
				if _variant_is_container(pack[k]):
					for v in pack[k]:
						r = next_r.call(r, method.call([k, v]))
				else:
					r = next_r.call(r, method.call([k, pack[k]]))
	return r

# (static)
## Returns a new dictionary converted from given [param pack].
static func pack_to_dict(pack, redundant := false) -> Dictionary:
	var dict := {}
	pack_iterator(pack, func(kvpair): _dict_add_kvpair(dict, kvpair, redundant))
	return dict
