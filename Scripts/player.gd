extends CharacterBody2D

signal died

const SPEED := 200.0
const JUMP_VELOCITY := -400.0
const FIRE_START_FRAME := 2   # frame of the dragon's "fire" animation when flames appear

@onready var body: AnimatedSprite2D = $Body
@onready var fire_pivot: Node2D = $FirePivot
@onready var fire: Area2D = $FirePivot/Fire
@onready var fire_shape: CollisionShape2D = $FirePivot/Fire/CollisionShape2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_breathing := false
var is_dead := false

func _ready() -> void:
	_set_fire(false)
	body.frame_changed.connect(_on_body_frame_changed)
	body.animation_finished.connect(_on_body_animation_finished)
	fire.body_entered.connect(_on_fire_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dead:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		move_and_slide()
		return

	var dir := Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("breathe_fire") and is_on_floor() and not is_breathing:
		_start_fire()

	if is_breathing:
		velocity.x = 0.0                      # stand still while breathing fire
	else:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		velocity.x = dir * SPEED
		if dir != 0.0:
			_face(dir)

	move_and_slide()
	_update_animation(dir)

func _face(dir: float) -> void:
	body.flip_h = dir < 0.0
	fire_pivot.scale.x = -1.0 if dir < 0.0 else 1.0

func _update_animation(dir: float) -> void:
	if is_breathing:
		return
	if not is_on_floor():
		body.play("jump")
	elif dir != 0.0:
		body.play("walk")
	else:
		body.play("idle")

# --- Fire breathing ---
func _start_fire() -> void:
	is_breathing = true
	body.play("fire")

func _on_body_frame_changed() -> void:
	if body.animation == "fire" and body.frame >= FIRE_START_FRAME and not fire.visible:
		_set_fire(true)

func _set_fire(on: bool) -> void:
	fire.visible = on
	fire_shape.set_deferred("disabled", not on)
	if on:
		$FirePivot/Fire/FireSprite.play("burn")

func _on_fire_body_entered(hit: Node) -> void:
	if hit.has_method("hit_by_fire"):
		hit.hit_by_fire()

# --- Death ---
func die() -> void:
	if is_dead:
		return
	is_dead = true
	is_breathing = false
	_set_fire(false)
	body.play("death")

func _on_body_animation_finished() -> void:
	match body.animation:
		"fire":
			is_breathing = false
			_set_fire(false)
		"death":
			died.emit()
