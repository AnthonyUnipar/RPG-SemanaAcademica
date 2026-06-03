extends CharacterBody2D

#Coisos do Personagem
@export var max_hp : int = 5 ;
@export var speed : int = 200 ;
@export var damage : int = 5;
@export var jump_force : int = 500 ;

#Coisos do Ambiente
@export var gravity : int = 1000;

#Estado Atual do Playa
var hp = max_hp;
var is_attacking : bool = false ;
var touching_grass : bool = false ;
var doing_good : bool = true;

#Camada de Nós do Playa
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attackhitbox: Area2D = $AttackHitbox

func _ready():
	attackhitbox.get_node("CollisionShape2D").disabled = true
func _physics_process(delta: float):
	if not doing_good:
		return
	_apply_gravity(delta)
	_handle_movement()
	_handle_attack()
	_handle_jump()
	_update_sprites() 
	move_and_slide()
	
func _apply_gravity(delta : float):
	if not is_on_floor():
		velocity.y += gravity * delta
func _handle_movement():
	if is_attacking:
		velocity.x = 0
		return
	var direction = Input.get_axis("mov_left","mov_right")
	velocity.x = direction * speed
	if direction != 0:
		sprite.flip_h = direction < 0
func _handle_jump():
	if Input.is_action_just_pressed("jump") and not is_attacking and is_on_floor():
		velocity.y = -jump_force
func _handle_attack():
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attackhitbox.get_node("CollisionShape2D").disabled = false
		attackhitbox.position.x = 24.5 if sprite.flip_h else -26.5
		is_attacking = true
		await sprite.animation_finished
		is_attacking = false
		attackhitbox.get_node("CollisionShape2D").disabled = true
func _update_sprites():
	var new_animation : String
	var on_floor: bool = is_on_floor()
	if is_attacking:
		new_animation = "attack"
	elif not on_floor:
		if velocity.y < 0:
			new_animation = "jump_start"
		else:
			new_animation = "jump_end"
	elif velocity.x != 0:
		new_animation = "running"
	else:
		new_animation = "idle"
	if new_animation != sprite.animation :
		sprite.play(new_animation)
	
