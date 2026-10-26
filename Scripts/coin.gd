extends Area2D

signal collected(coin_type: int, value: int)

enum CoinType { REGULAR, DRAGON }

@export var coin_type: CoinType = CoinType.REGULAR
@export var value := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite.play("dragon" if coin_type == CoinType.DRAGON else "regular")

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	set_deferred("monitoring", false)   # prevents double pickup
	collected.emit(coin_type, value)

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
