class_name GriddedObject
extends Object
## Designed for objects gridded into bodies.
## Each body occupies exactly one cell of grid. 
## To describe bodies, use [KeyValuePack] with every key to be 
## a bodytype, and corresponding value to be a position vector.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# private data and initialization:

# (private)
# The dictionary containing relative positions of bodies.
var _bodydict := {}

# (private)
# The vector that indicates the position.
var _position := Vector2i.ZERO

# (private)
# The bool value of permission to move this object.
var _movable := true

## (initialization)
## The constructor of this class when instantiating.
func _init(init_bodypack := {}, init_movable := true):
	self._movable = init_movable
	self._position = Vector2i.ZERO
	self._bodydict = GriddedObject._subtract_vector(init_bodypack, self._position)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# read-only methods:

## (read-only)
## Returns true if this object is movable.
func is_movable() -> bool:
	return self._movable

## (read-only)
## Returns a new dictionary containing absolute positions of bodies.
func get_bodydict() -> Dictionary:
	return self._rel_to_abs(self._bodydict)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# writing methods:

## (writing)
## Set movability to given state.
func set_movable(movable := true):
	self._movable = movable

## (writing)
## Move this object by given displacement.
func do_move(displacement := Vector2i.ZERO):
	if self._movable: 
		self._position += displacement

## 

## (writing)
## Add given bodies, with only existing bodytypes allowed.
## For each bodytype, positions that already exist will be ignored,
## while different bodytypes can share same position.
func add_body(bodypack := {}):
	for b in bodypack:
		if not self._bodydict.has(b): continue
		for pos in bodypack[b]:
			var rel_pos = _abs_to_rel(pos)
			if self._bodydict[b].has(rel_pos): continue
			self._bodydict[b].append(rel_pos)

## (writing)
## Subtract given bodies.
func subtract_body(bodypack := {}):
	for b in bodypack:
		if not self._bodydict.has(b): continue
		for pos in bodypack[b]:
			var rel_pos = _abs_to_rel(pos)
			while self._bodydict[b].has(rel_pos):
				self._bodydict[b].erase(rel_pos)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# private methods:

# (private)
# Returns an absolute position pack converted from given pack.
func _rel_to_abs(pack):
	return GriddedObject._add_vector(pack, self._position)

# (private)
# Returns a relative position pack converted from given pack.
func _abs_to_rel(pack):
	return GriddedObject._subtract_vector(pack, self._position)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# static methods:

# (static)
# Returns a new Vector2i pack after adding the given Vector2i.
static func _add_vector(pack, addition := Vector2i.ZERO):
	match (typeof(pack)):
		TYPE_VECTOR2I:
			return pack + addition
		TYPE_ARRAY:
			var returned_pack := []
			for v in pack:
				assert(typeof(v) == TYPE_VECTOR2I)
				returned_pack.append(v + addition)
			return returned_pack
		TYPE_DICTIONARY:
			var returned_pack := {}
			for key in pack:
				returned_pack[key] = []
				assert(typeof(pack[key]) == TYPE_ARRAY)
				for v in pack[key]:
					assert(typeof(v) == TYPE_VECTOR2I)
					returned_pack[key].append(v + addition)
			return returned_pack
		_:
			return null

# (static)
# Returns a new Vector2i pack after subtracting the given Vector2i.
static func _subtract_vector(pack, subtraction := Vector2i.ZERO):
	return GriddedObject._add_vector(pack, subtraction * (-1))

# (static)
# Returns a KVA array converted from given dictionary.
static func _dict_to_kvaa(dict := {}, addition = null) -> Array:
	var kvaa := []
	for k in dict:
		if typeof(dict[k]) == TYPE_ARRAY:
			for v in dict[k]:
				kvaa.append([k, v])
		else:
			kvaa.append([k, dict[k]])
	if addition:
		for a in kvaa:
			a[1] += addition
	return kvaa

# (static)
# Returns a dictionary converted from given KVA array.
static func _kvaa_to_dict(kvaa := [], addition = null) -> Dictionary:
	var dict := {}
	for kva in kvaa:
		pass
	return dict

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# custom iterator:

# (iteration)
# Several variables declared for iterator.
var _iter_bodytypes: Array
var _iter_positions: Array
var _iter_x: int
var _iter_y: int
var _iter_return: Array

# (iteration)
# The continuing judgement of iterator.
func _iter_continue() -> bool:
	while (self._iter_x < self._iter_bodytypes.size()):
		self._iter_positions = self._bodydict[self._iter_bodytypes[self._iter_x]]
		if not self._iter_positions.is_empty(): break
		self._iter_x += 1
	return self._iter_x < self._iter_bodytypes.size()

# (iteration)
# The initial statement of iterator.
func _iter_init(_arg) -> bool:
	self._iter_bodytypes = self._bodydict.keys()
	self._iter_x = 0
	self._iter_y = 0
	return self._iter_continue()

# (iteration)
# The recurring statement of iterator.
func _iter_next(_arg) -> bool:
	self._iter_y += 1
	if not self._iter_y < self._iter_positions.size():
		self._iter_x += 1
		self._iter_y = 0
	return self._iter_continue()

# (iteration)
# The returning variant of iterator.
func _iter_get(_arg) -> Array:
	self._iter_return.clear()
	self._iter_return.append(self._iter_bodytypes[self._iter_x])
	self._iter_return.append(self._rel_to_abs(self._iter_positions[self._iter_y]))
	return self._iter_return
