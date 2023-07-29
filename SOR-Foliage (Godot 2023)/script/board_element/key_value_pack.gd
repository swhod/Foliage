class_name KeyValuePack
extends RefCounted
## There are two possible ways to manage key-value pairs: [Dictionary], which can be more efficient at storage;
## and [Array], which is straightforward when iterating. This class is designed as a compatible solution.
##
## In array form, a pack should be [b]an array containing key-value pairs[/b]:
## [codeblock]
## ["odd", 1, "odd", 3, "odd", 5, "even", 2]
## [/codeblock]
## [br]And in dictionary form, [b]values are put together in an array if sharing the same key[/b]:
## [codeblock]
## {"odd": [1, 3, 5], "even": 2}
## [/codeblock]
## [br]Both forms are accepted by this class. All valid forms are listed in [enum KeyValuePack.PackType].
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
	KVPACK, ## An instance of this class.
	ARRAY, ## An array containing key-value pairs.
	DICTIONARY, ## A dictionary putting together values of the same key.
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

# (initialization)
# The constructor of this class when instantiating.
func _init(from = {}, 
		init_input_map := func(e): return e,
		init_output_map := func(e): return e):
	self._output_map = init_output_map
	self._input_map = init_input_map
	self._stored_pack = {}
	self.add_pack(from)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (read-only)
## Returns an array converted from this pack.
func to_arr() -> Array:
	var arr := []
	for pair in self:
		var i = arr.find(pair[KEY])
		while i != -1:
			if i % 2 == KEY and arr[i + 1] == pair[VALUE]: break
			i = arr.find(pair[KEY], i + 1)
		if i == -1:
			arr.append_array(pair)
	return arr

# (read-only)
## Returns a dictionary converted from this pack.
func to_dict() -> Dictionary:
	var dict := {}
	for pair in self:
		if not dict.has(pair[KEY]):
			dict[pair[KEY]] = []
		if not dict[pair[KEY]].has(pair[VALUE]):
			dict[pair[KEY]].append(pair[VALUE])
	return dict

# (writing)
## Add pairs given by [param pack].
func add_pack(pack) -> void:
	KeyValuePack.pack_iterator(pack, func(pair): self._add_pair(pair))

# (writing)
## Delete pairs given by [param pack].
func delete_pack(pack) -> void:
	KeyValuePack.pack_iterator(pack, func(pair): self._delete_pair(pair))

# (writing)
## Set the value-mapping method that always called when inputting.
func set_input_map(input_map: Callable) -> void:
	self._input_map = input_map

# (writing)
## Set the value-mapping method that always called when outputting.
func set_output_map(output_map: Callable) -> void:
	self._output_map = output_map

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (private)
# Add given pair.
func _add_pair(pair: Array) -> void:
	var input_pair = self._input_map.call(pair)
	if not self._stored_pack.has(input_pair[KEY]):
		self._stored_pack[input_pair[KEY]] = []
	if not self._stored_pack[input_pair[KEY]].has(input_pair[VALUE]):
		self._stored_pack[input_pair[KEY]].append(input_pair[VALUE])

# (private)
# Delete given pair.
func _delete_pair(pair: Array) -> void:
	for k in self._stored_pack:
		for v in self._stored_pack[k]:
			if self._output_map.call([k, v]) == pair:
				self._stored_pack[k].erase(v)
		if self._stored_pack[k].is_empty():
			self._stored_pack.erase(k)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (iteration)
# Several variables declared for iterator.
var _iter_keys: Array
var _iter_values: Array
var _iter_x: int
var _iter_y: int
var _iter_return: Array

# (iteration)
# The continuing judgement of iterator.
func _iter_continue() -> bool:
	if self._iter_x < self._iter_keys.size():
		self._iter_values = self._stored_pack[self._iter_keys[self._iter_x]]
		return true
	return false

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
	self._iter_y += 1
	if not self._iter_y < self._iter_values.size():
		self._iter_x += 1
		self._iter_y = 0
		return self._iter_continue()
	return true

# (iteration)
# The returning variant of iterator.
func _iter_get(_arg) -> Array:
	self._iter_return.clear()
	self._iter_return.append(self._iter_keys[self._iter_x])
	self._iter_return.append(self._iter_values[self._iter_y])
	return self._output_map.call(self._iter_return)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (static)
# Returns the type in KeyValuePack.PackType of given pack.
static func _pack_get_packtype(pack) -> int:
	if pack is KeyValuePack: 
		return PackType.KVPACK
	if pack is Array:
		if pack.size % 2 != 0 or pack.any(func(v): return v is Array or v is Dictionary): return PackType.INVALID
		return PackType.ARRAY
	if pack is Dictionary:
		for k in pack:
			if pack[k] is Dictionary: return PackType.INVALID
			if pack[k] is Array and pack[k].any(func(v): return v is Array or v is Dictionary): return PackType.INVALID
		return PackType.DICTIONARY
	return PackType.INVALID

# (static)
## Call [param method] for every pair in [param pack].
## [br]To adjust the logic of returning, assign [param init_r] as starting value, and
## [param next_r] as the method to deal with values returned during iteration. For example:
## [codeblock]
## init_r = 0
## next_r = func(last_r, iter_r): return last_r + iter_r
## # Will return the sum of all the returning values.
## [/codeblock]
static func pack_iterator(pack, method: Callable, init_r = null, next_r: Callable = func(_last_r, _iter_r): return null):
	var r = init_r
	match _pack_get_packtype(pack):
		PackType.KVPACK:
			for pair in pack:
				r = next_r.call(r, method.call(pair))
		PackType.ARRAY:
			for i in pack.size() / 2:
				r = next_r.call(r, method.call([pack[2 * i], pack[2 * i + 1]]))
		PackType.DICTIONARY:
			for k in pack:
				if pack[k] is Array:
					for v in pack[k]:
						r = next_r.call(r, method.call([k, v]))
				else:
					r = next_r.call(r, method.call([k, pack[k]]))
		PackType.INVALID:
			push_error("This pack is invalid.")
	return r
