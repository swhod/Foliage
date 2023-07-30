class_name GriddedObject
extends RefCounted

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (private)
# The zipped data describing all bodies.
var _bodyzip = {}

# (private)
# The bool value of permission to move this object.
var _movable := true

# (private)
# The array of all bodies permitted.
var _permitted_bodies := []

# (private)
# The vector that indicates the position.
var _position := Vector2.ZERO

# (initialization)
# The constructor of this class when instantiating.
func _init(init_bodypack := {}):
	self._position = self._init_position()
	self._permitted_bodies = self._init_permitted_bodies()
	self._permitted_bodies.make_read_only()
	self._movable = self._init_movable()
	self._bodyzip = self._init_bodyzip()
	self.add_bodypack(init_bodypack)

# (initialization, virtual)
## Returns the initial position.
func _init_position() -> Vector2:
	return Vector2.ZERO

# (initialization, virtual)
## Returns an array of all bodies permitted.
func _init_permitted_bodies() -> Array:
	return []

# (initialization, virtual)
## Returns the initial state of movability.
func _init_movable() -> bool:
	return true

# (initialization, virtual)
## Returns the initial bodyzip.
func _init_bodyzip():
	return {}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (read-only)
## Returns [code]true[/code] if this object is movable.
func is_movable() -> bool:
	return self._movable

# (read-only)
## Returns the body pack of this object.
func get_bodypack() -> Dictionary:
	return self._to_bodypack(self._bodyzip)

# (writing)
## Move this object by [param displacement].
func do_move(displacement := Vector2.ZERO):
	if self._movable:
		self._position += displacement

# (writing)
## Add bodies given by [param bodypack].
func add_bodypack(bodypack: Dictionary):
	return self._add_bodyzip(self._to_bodyzip(bodypack))

# (writing)
## Delete bodies given by [param bodypack].
func delete_bodypack(bodypack: Dictionary):
	return self._delete_bodyzip(self._to_bodyzip(bodypack))

# (private)
# Returns the body pack according to given bodyzip.
func _to_bodypack(bodyzip) -> Dictionary:
	var unzipped := self._unzip(bodyzip)
	var bodypack := {}
	for b in unzipped:
		bodypack[b] = unzipped[b].map(func(pos): return pos + self._position)
	return bodypack

# (private)
# Returns the body zip according to given bodypack.
func _to_bodyzip(bodypack: Dictionary):
	var not_zipped_yet := {}
	for b in bodypack:
		if b not in self._permitted_bodies: continue
		not_zipped_yet[b] = bodypack[b].map(func(pos): return pos - self._position)
	return self._zip(not_zipped_yet)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# (virtual)
## Returns the body pack unzipped from [param bodyzip].
func _unzip(bodyzip) -> Dictionary:
	return bodyzip

# (virtual)
## Returns the body zip unzipped from [param bodypack].
func _zip(bodypack: Dictionary):
	return bodypack

# (writing, virtual)
## Add bodies specified by [param bodyzip].
func _add_bodyzip(bodyzip):
	for b in bodyzip:
		for pos in bodyzip[b]:
			if not self._bodyzip[b].has(pos):
				self._bodyzip[b].append(pos)

# (writing, virtual)
## Delete bodies specified by [param bodyzip].
func _delete_bodyzip(bodyzip):
	for b in bodyzip:
		if not self._bodyzip.has(b): continue
		for pos in bodyzip[b]:
			self._bodyzip[b].erase(pos)
