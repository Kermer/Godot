# Simple GUI Collisions
In this tutorial I want to show you how [StaticBody2D](http://docs.godotengine.org/en/latest/classes/class_staticbody2d.html), [KinematicBody2D](http://docs.godotengine.org/en/latest/classes/class_kinematicbody2d.html) and [Area2D](http://docs.godotengine.org/en/latest/classes/class_area2d.html) interact and collide with eachother.  
You may treat this tutorial as shorter version of official [Physics & Collision (2D) and Kinematic Character (2D)](http://docs.godotengine.org/en/latest/tutorials/2d/_2d_physics.html) tutorials.  
This tutorial isn't going to cover [RigidBody2D](http://docs.godotengine.org/en/latest/classes/class_rigidbody2d.html) functionality.  
I assume that you have some (general) knowledge about GDScript, creating scenes and nodes.  
You can download completed tutorial at the bottom of this site.  
  
----  
## Lets Begin...  
Before you will pick your CollisionObject (Kinematic/Static/Area) you must think about how you want it to behave...  
  
* Is it going to just stand and block everything like a wall?  
* Or maybe it needs to move in different directions?  
* I think I'm gonna leave it just bouncing off every wall...  
  
Depending on needed behaviour you should pick correct type. 

### StaticBody2D
The simplest node in the physics engine is the StaticBody2D, which provides a static collision. This means that other objects can collide against it, but StaticBody2D will not move by itself or generate any kind of interaction when colliding other bodies.
* is not intended to move, 
* blocks any Kinematic and Rigid Body,  
* best for making walls and similiar objects.   

### KinematicBody2D  
Kinematic bodies are special types of bodies that are meant to be user-controlled. They are not affected by the physics at all (to other types of bodies, such a character or a rigidbody, these are the same as a staticbody).  
* can move however you want to ( simple `move()` and `move_to()` functions )  
* blocks any Kinematic and Rigid body,
* collides with any Kinematic, Rigid and Static Body,
* isn't affected by gravity, impulses, etc.
* best for controlled characters.  

### Area2D  
Area2D is mostly used to check if any other body (Kinematic or Rigid) has entered or exited its region ( CollisionShape ).  
It can also override physics (gravity etc.) for bodies inside it. This function is mostly useful for RigidBody.  

### RigidBody2D  
Physics oriented CollisionObject. Doesn't contain direct movement functions, yet it can move via applying impulses and different forces to it. Most advanced of all Collision Objects.  
NOT IMPLEMENTED IN THIS TUTORIAL  

### CollisionShape2D
[CollisionShape2D](http://docs.godotengine.org/en/latest/tutorials/2d/physics_introduction.html#shapes) is required for any CollisionObject to work (to check for collisions). Every CollisionObject can have multiple Shapes which can be created either via GUI editor - as a child of CollisionObject or via code, f.e.:
```gdscript
#create a circle
var c = CircleShape2D.new()
c.set_radius(20)

#create a box
var b = RectangleShape2D.new()
b.set_extents(Vector2(20,10))
```  
Have in mind that CollisionShape2D cannot be accessed as node through code (get_node won't work). If you really need to get your shape you can use `get_shape( shape_index )` function, it'll return Shape2D object.  

### CollisionPolygon2D
It works the same as CollisionShape2D, but instead of picking one of shapes you can draw your own.  
To start drawing polygon select your CollisionPolygon2D node, then click pencil tool in the editor:  
  
![Drawing Polygon](https://imgur.com/ktSPn2V.png)
  
  
# Make some collisions!  
I've decided that for this tutorial we don't need any extra resources (we'll use icon.png as sprites) so just create new, empty project.    
- Everything will be made in one scene. Lets start with creating a new `Node`.    
    - Our first object will be `KinematicBody2D`, add it to the Node.  
        - KinematicBody needs some `Sprite` so we can see it.
        - And `CollisionShape2D` to collide properly.  
  
To Sprite assign `icon.png` texture and create `New RectangleShape2D` for CollisionShape2D.  
`Edit Shape` extents so it matches the Sprite.  
  
![New RectangleShape2D](https://imgur.com/TJdskpy.png) ![Edit Shape](https://imgur.com/kXKAahX.png)  
  
You've created your first colliding object! But how do you want to collide if there is only one object?  
Create `StaticBody2D` and `Area2D` same way as you created KinematicBody2D.  
Position your objects inside the scene with some space between each other.  
You might want to add some Labels or modulate Sprite colors to know who is who.  
  
Now we need to move something, we'll use our KinematicBody2D for it. Create new GDScript to it and start editing it:  
```gdscript
extends KinematicBody2D

const speed = 100

func _ready():
	set_fixed_process(true)
```  
If you don't know what is `fixed_process` or why we use it here - in short it's close to `process` but have fixed delta (fires once per frame) related to GPU physics processing. So when using collisions it's better to use fixed_process instead of normal.  
Add another part of the code...  
  
```gdscript
func _fixed_process(delta):
	var direction = Vector2(0,0)
	if ( Input.is_action_pressed("ui_up") ):
		direction += Vector2(0,-1)
	if ( Input.is_action_pressed("ui_down") ):
		direction += Vector2(0,1)
	if ( Input.is_action_pressed("ui_left") ):
		direction += Vector2(-1,0)
	if ( Input.is_action_pressed("ui_right") ):
		direction += Vector2(1,0)
	
	move( direction * speed * delta)
```  
  
Now your character will be able to move! It'll move 100 (speed value) pixels per second into direction specified by input.  
  
`move` function is really not just about movement (it's more like set_pos job) - it's **TRYING TO MOVE** your object to wanted position but if collision appears it'll stop its movement and try to free itself (move to non-colliding position), `move_to()` function works the same way.  
  
```gdscript
set_pos( get_pos() + direction * speed * delta )
move( Vector2(0,0) )
  # PROBABLY will work the same as
move( direction * speed * delta )

  # ----------------

set_pos( some_pos )
move( Vector2(0,0) )
  # MIGHT work the same as
move_to( some_pos )
```  
  
It's mostly because of distance between points - at first example you check collision about each 1 pixel ( 100 * delta ), but in second example it might be much bigger distance. Here's difference between move(and move_to) and set_pos functions:
![](https://imgur.com/OUQVgdM.png)  
  
### Collision detection  
Now you are able to move your character and collide with your StaticBody. But usually this isn't enough, you need to something happen on collision and here comes `is_colliding()` function and `body_enter`, `body_exit` signals.  
  
```gdscript
func _fixed_process(delta):
# [ ... previous code ... ]
	if is_colliding():	# colliding with Static, Kinematic, Rigid
		# do something
		print ("Collision with ", get_collider() )	# get_collider() returns CollisionObject
```  
Now your KinematicBody will run some code when you're trying to enter your StaticBody. But Area2D doesn't seem to do anything yet. You need to connect it's signal to some function. You can do that either via Editor's GUI or via code:  
  
```gdscript
func _ready():
# [ ... rest of your code ... ]
	get_node("Area2D").connect("body_enter",self,"_on_Area2D_body_enter")
	get_node("Area2D").connect("body_exit",self,"_on_Area2D_body_exit")
```  
  
```gdscript
func _on_Area2D_body_enter( body ):
	print("Entered Area2D with body ", body)
func _on_Area2D_body_exit( body ):
	print("Exited Area2D with body ", body)
```  
  
Now run your scene and test collisions!  
  
### Sliding  
Note that when you are colliding you are unable to move in other directions (f.e. when colliding at bottom, you can't move left/right). To continue movement Godot includes some useful functions: `slide()` and `get_collision_normal()`.  
Lets modify our code now...  
  
```gdscript
func _fixed_process( delta ):
# [ ... your code ... ]
	if is_colliding():
		var n = get_collision_normal()
		direction = n.slide( direction )
		move(direction*speed*delta)
```  
  
Run your scene again. Noticed the difference?  
  
### Demo (finished tutorial)
  
[CLICK TO DOWNLOAD DEMO](https://drive.google.com/open?id=0Bz_8S_euQkQVUk92VDRKQTByTzA&authuser=0)
