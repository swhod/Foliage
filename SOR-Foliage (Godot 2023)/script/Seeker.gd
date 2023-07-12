class_name Seeker
extends Node

## The value that represents holding nothing.
var _HOLDING_NULL = null

## The unit displacement of moving downward.
var _DOWN_UNIT = Vector2.DOWN

## The object that the Seeker is holding.
var holding = _HOLDING_NULL

## The numerical value that indicates the distance from ground.
var height = 0

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## Returns if the Seeker is holding anything or not.
func is_holding() -> bool:
	return self.holding != self._HOLDING_NULL

## Returns an array of objects that binds with the Seeker.
func get_binding_array():
	var binding_array = [self]
	if is_holding():
		binding_array.append(self.holding)
	return binding_array

## Returns how far the Seeker can fall before grounding.
func get_binding_height():
	var binding_array = get_binding_array()
	var binding_height = self.height
	for obj in binding_array:
		if obj.has_prop("height"):
			binding_height = min(binding_height, obj.height)
	return binding_height

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## (needs to be overrided)
## Find if anything can be held.
func _find_holdable():
	pass

## (needs to be overrided)
## Move the Seeker by the given displacement.
## The property "height" should be updated in this function.
func _do_move(_displacement):
	pass

## Attempt to move if can.
func attempt_move(displacement) -> bool:
	
	var binding_array = self.get_binding_array()
	
	var can_move := true
	for obj in binding_array:
		if not obj.has_method("_do_move"):
			can_move = false
		if obj.has_prop("movable"):
			can_move = can_move and obj.movable
	
	if can_move:
		for obj in binding_array:
			obj._do_move(displacement)
	return can_move
	

## Attempt to fall if can.
func attempt_fall() -> bool:
	
	var binding_height = get_binding_height()
	if binding_height == 0:
		return false
	
	var fall_displacement = binding_height * self._DOWN_UNIT
	return attempt_move(fall_displacement)
	

## Attempt to hold something if can.
func attempt_hold() -> bool:
	
	if self.is_holding():
		return false
	
	self.holding = _find_holdable()
	return self.is_holding()
	

## Attempt to release the holding object if can.
func attempt_release() -> bool:
	
	if not self.is_holding():
		return false
	
	var can_release := true
	if self.holding.has_method("is_releasable"):
		can_release = self.holding.is_releasable()
	
	if can_release:
		self.holding = null
		self.attempt_fall()
	return can_release
	

## Attempt to do a horizontal move if can.
func attempt_horizontal_move():
	pass
