extends Sprite

var side

var id
var level

var advances_to

var base_experience
var current_experience setget _set_current_experience

var base_max_health
var base_max_moves

var current_health setget _set_current_health
var current_moves

var attacks = {}
var resistance = {}
var defense = {}
var movement = {}

var can_attack = true

var game
onready var lifebar = $"Lifebar"
onready var xpbar = $"XPbar"

func _ready():
	update_lifebar()
	update_xpbar()

func _process(delta):
	if current_experience >= base_experience and advances_to == null:
		amla()
	elif current_experience >= base_experience and UnitRegistry.registry.has(advances_to):
		advance(UnitRegistry.registry[advances_to])


func initialize(reg_entry, side):
	id = reg_entry.id
	level = reg_entry.level
	base_max_health = reg_entry.health
	current_health = base_max_health
	base_max_moves = reg_entry.moves
	current_moves = base_max_moves
	base_experience = reg_entry.experience
	current_experience = 0
	advances_to = reg_entry.advances_to
	attacks = reg_entry.attacks
	resistance = reg_entry.resistance
	defense = reg_entry.defense
	defense["impassable"] = 0
	movement = reg_entry.movement
	movement["impassable"] = 99
	texture = load(reg_entry.image)
	self.side = side

func advance(reg_entry):
	id = reg_entry.id
	level = reg_entry.level
	base_max_health = reg_entry.health
	current_health = base_max_health
	base_max_moves = reg_entry.moves
	base_experience = reg_entry.experience
	current_experience = 0
	attacks = reg_entry.attacks
	resistance = reg_entry.resistance
	defense = reg_entry.defense
	defense["impassable"] = 0
	movement = reg_entry.movement
	movement["impassable"] = 99
	texture = load(reg_entry.image)
	update_lifebar()
	update_xpbar()

func amla():
	base_max_health += 3
	_set_current_health(base_max_health)
	update_lifebar()
	var left_over = current_experience - base_experience 
	base_experience = int(base_experience * 1.2)
	current_experience = left_over
	update_xpbar()

func heal(value):
	_set_current_health(current_health + value)
	print(id, " healed by ", value)

func harm(attacker_unit_id, damage, attack_type, defense):
	var hit_chance = float(100 - defense) / 100.0
	if randf() <= hit_chance:
		var mod = float(resistance[attack_type]) / 100.0
		var new_damage = int(damage * mod)
		print("(", 100 - defense, "%)\t", attacker_unit_id, " deals ", new_damage, " damage (", damage, " * ", mod, " = ", new_damage, ")")
		_set_current_health(current_health - new_damage)
	else:
		print("(", 100 - defense, "%)\t", attacker_unit_id, " missed")

func restore_current_moves():
	current_moves = base_max_moves
	can_attack = true

func has_moved():
	return current_moves < base_max_moves

func get_attack_string():
	var string = ""
	for attack in attacks:
		string += str(attack.name, ":\n", attack.damage, "x", attack.strikes, " (", attack.type, ", ", attack.range, ")\n\n")
	return string

func update_lifebar():
	lifebar.set_max_value(base_max_health)
	lifebar.set_value(current_health)

func update_xpbar():
	xpbar.set_max_value(base_experience)
	xpbar.set_value(current_experience)

func get_movement_cost(terrain_type):
	if terrain_type[1] == "":
		return movement[terrain_type[0]]
	if movement[terrain_type[0]] > movement[terrain_type[1]] :
		return movement[terrain_type[0]]
	else:
		return movement[terrain_type[1]]

func get_defense(terrain_type):
	if terrain_type[1] == "":
		return defense[terrain_type[0]]
	if defense[terrain_type[0]] > defense[terrain_type[1]] :
		return defense[terrain_type[0]]
	else:
		return defense[terrain_type[1]]

func get_map_position():
	return game.terrain.world_to_map(position)

func get_adjacent_units():
	var units = []
	for cell in game.terrain._get_neighbors(get_map_position()):
		var otherUnit = game.get_unit_at_cell(cell)
		if otherUnit:
			units.append(otherUnit)
	return units

func _set_current_experience(value):
	current_experience = value
	update_xpbar()

func _set_current_health(value):
	if value <= base_max_health:
		current_health = value
	else:
		current_health = base_max_health
	update_lifebar()