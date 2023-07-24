class_name GriddedObject
extends KeyValuePack
## Designed for objects gridded into bodies.
## Each body occupies exactly one cell of grid. 
## To describe bodies, use [KeyValuePack] with every key to be 
## a bodytype, and corresponding value to be a position vector.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (private)
# The vector that indicates the position.
var _position := Vector2i.ZERO

# (private)
# The bool value of permission to move this object.
var _movable := true

# (private)
# The array of permitted bodytypes.
var _permitted := []

# (private)
# The array of objects bound with this object when moving.
var _bound := [self]

# (private)
# The input mapper for bodypack data.
func _input_mapper(pair):
	if pair[KEY] in self._permitted:
		return [pair[KEY], pair[VALUE] - self._position]
	else:
		return []

# (private)
# The output mapper for bodypack data.
func _output_mapper(pair):
	return [pair[KEY], pair[VALUE] + self._position]

# (initialization)
# The constructor of this class when instantiating.
func _init(bodypack = {}, init_movable := true, init_permitted := []):
	self._permitted = init_permitted if init_permitted else \
			KeyValuePack.new(bodypack).to_dict().keys()
	self._permitted.make_read_only()
	self._movable = init_movable
	self._position = Vector2i.ZERO
	super(bodypack, Callable(self, "_input_mapper"), Callable(self, "_output_mapper"))

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (read-only)
## Returns [code]true[/code] if this object is movable.
func is_movable() -> bool:
	return self._movable

# (writing)
## Set movability to given state.
func set_movable(movable := true):
	self._movable = movable

# (writing)
## Move this object by given displacement.
func do_displace(displacement := Vector2i.ZERO):
	if self._movable:
		self._position += displacement

# (writing)
## Add given bodies.
func add_body(bodypack = {}):
	self.add_pack(bodypack)

# (writing)
## Delete given bodies.
func delete_body(bodypack = {}):
	self.delete_pack(bodypack)

# (writing)
## Add a bound object.
func add_bound(obj: GriddedObject):
	if obj not in self._bound:
		self._bound.append(obj)

# (writing)
## Delete a bound object.
func delete_bound(obj: GriddedObject):
	self._bound.erase(obj)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (writing)
## Attempt to move if can.
func attempt_move(displacement := Vector2i.ZERO):
	pass
