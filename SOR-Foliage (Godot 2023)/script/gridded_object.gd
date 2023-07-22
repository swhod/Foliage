class_name GriddedObject
extends KeyValuePack
## Designed for objects gridded into bodies.
## Each body occupies exactly one cell of grid. 
## To describe bodies, use [KeyValuePack] with every key to be 
## a bodytype, and corresponding value to be a position vector.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (private)
# The vector that indicates the position.
var _position := Vector2i.ZERO:
	set(position): 
		self.set_input_map(func(v): return v - position)
		self.set_output_map(func(v): return v + position)

# (private)
# The bool value of permission to move this object.
var _movable := true

# (private)
# The array of permitted bodytypes.
var _permitted := []

# (initialization)
# The constructor of this class when instantiating.
func _init(init_bodypack := {}, init_movable := true, init_permitted := []):
	self._permitted = init_permitted if init_permitted else init_bodypack.keys()
	self._permitted.make_read_only()
	self._movable = init_movable
	self._position = Vector2i.ZERO
	super(init_bodypack)

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
func do_move(displacement := Vector2i.ZERO):
	if self._movable:
		self._position += displacement

# (writing)
## Add given bodies, with only existing bodytypes allowed.
func add_body(bodypack = {}):
	self.add_pack(bodypack)

# (writing)
## Subtract given bodies.
func subtract_body(bodypack = {}):
	self.delete_pack(bodypack)
