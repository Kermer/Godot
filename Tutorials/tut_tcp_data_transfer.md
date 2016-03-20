In last tutorial I've explained how to connect server with clients using TCP. Connecting and disconnecting isn't enough for games, isn't it?  
  
## PacketPeerStream  
It's best way to send data. You create `PacketPeerStream` object, bind connection to it and start sending data with it's own `put_var` function and receive on the other side of the network with `get_var`.  
Simple as that.  
  
## Few things worth remembering  
The most important thing is knowing what are you going to receive - will it be an integer, string, or maybe an array of some data?  
From my personal experience, you'll be mostly using arrays, because you can send multiple data attributes, such as  player name, position and rotation, in 1 packet.  
If you're going to send more of different data you might want to reserve 1 or few first elements of data/array for sending command (so receiver can know what you're sending). Examples:  
`var data = [ PLAYER_DATA, player.name, player.pos.x, player.pos.y ]`  
`var data = [ MAP_SIZE, map.size.x, map.size.y ]`  
After reading first element of array receiver can decide what to do next.  
  
Some people prefer to make _client as client.scn_ and _server as server.scn with child client.scn_ to use share some functions, variables etc. with client, yet I'm going to use client as client and server as server schema here.
  
## Modifying last tutorial  
_We'll add posibility to send messages for [last tutorial](https://github.com/Kermer/Godot/tree/master/Tutorials/tut_tcp_connection.md) ( [link to completed tutorial](https://drive.google.com/open?id=0Bz_8S_euQkQVY1Z1cFhkT1F0RlE&authuser=0) ).  
[You can skip this if you want since I'm going to show something more useful when creating games.](https://github.com/Kermer/Godot/tree/master/Tutorials/tut_tcp_data_transfer.md#gaming-needs)_
  
***
What do we want to do:  
1. Client sends message  
2. Server receives message (and display it for itself)  
3. Server broadcast message to all connected Clients  
4. Clients receive messages and display it  
  
First add `LineEdit` nodes to both of your server and client scenes and resize, position it as you see fit  
  
![Adding LineEdit](http://i133.photobucket.com/albums/q50/95seba/Godot%20Tutorials/addinglineedit.png)  
  
### Server  
First we going to start with receiving data - all data we receive will be just a simple string. Get to your `_process` function and modify `for peer in peerstream:` code:
````python
for peer in peerstream:
	if peer.get_available_packet_count() > 0: # we received some data
		var data_received = peer.get_var()
		debug.add_text("Data: "+data_received); debug.newline() # we don't use str() here since we're sure it'll be string
		SendData( data_received ) # our data broadcast function, we'll create it soon
````  
This code is enough for our needs in this project (sending message). But in more advanced game you might send more than 1 packets per one _process frame. And with this code it might cause delay between receiving message ( since we're only able to receive 1 packet / frame with this code), but it's easy to fix:  
````python
for peer in peerstream:
	if peer.get_available_packet_count() > 0: # we received some data
		for i in range( peer.get_available_packet_count() ): # this is our fix
			# [...]
````  
No need to add it here, but you can if you want.  
  
Our broadcast data function:
````python
func SendData( data ):
	if data != "": # no point in sending nothing
		for peer in peerstream: # simple loop for all connected clients
			peer.put_var( data ) # sending data for each
````  
We can now receive data and then broadcast to others, it's time to allow ourselves to send messages:  
````python
func _process( delta ): # you might as well add this in _input
# [ ... rest of your code ]
	if Input.is_key_pressed( KEY_RETURN ): # Enter
		var data = get_node("LineEdit").get_text()
		if data != "":
			data = data.strip_edges() # erase spaces, etc. at beginning and end of the string
			debug.add_text("Data: "+data); debug.newline() # display for self
			SendData( data ) # send to others
			get_node("LineEdit").set_text("") # reset our message
````  
  
Now our server is done.  
  
### Client  
Most of client's functions looks similiar to those from server, you mainly just skip for loops since you're only contacting with server, no one else.  
````python
func _process( delta ):
	if peerstream.get_available_packet_count() > 0: # we received some data
		var data_received = peerstream.get_var()
		debug.add_text("Data: "+data_received); debug.newline()

	if Input.is_key_pressed( KEY_RETURN ):
		var data = get_node("LineEdit").get_text()
		if data != "":
			data = data.strip_edges()
			SendData( data ) # send to server
			get_node("LineEdit").set_text("")
			# we don't display for ourselves, waiting till server send us message
````  
````python
func SendData( data ):
	if data != "":
		peerstream.put_var( data )
````
### It is done...  
Export, run in few windows and test it.  
  

***  
  
***  
  
# Gaming needs...  
_This tutorial isn't about creating whole game, just adding networking for basic interactions._  
  
I was wondering for a while from what kind of game I want this tutorial to be made. Finally picked [Theo's Multiplayer sample](http://www.godotengine.org/forum/viewtopic.php?f=14&t=565).  
In his example (there's source code download) you can see usage of server with client as child schema. For server you use main.gd script and some of character.gd and for client character.gd, main.gd gets loaded, but you barely use it.  
Server -> main.gd + character.gd, client -> ~~main.gd~~ + character.gd.  
  
**I'm going to use sprites included in his game and will try to receive similiar end-effect while making code different.**
  
## One more thing...  
One more thing before we begin: you might think a while about how many data is processed by player and how many by server.  
More by server: more secure against cheaters, hackers, etc. (unless they're host); hosting might require better PC specs, if ping is higher clients might be more laggy ...  
More by client: less secure, decreases server load, client might be less laggy ...  
  
## Shall we begin?  
First I need you to download and open [this project](https://drive.google.com/open?id=0Bz_8S_euQkQVMzBaUDdWTG93QUk&authuser=0).  
If you run it now you'll be able to move your own character, connect/disconnect, but no data will be transfered between server and client.  
  
You might have noticed that scripts used here are similiar to those from my [previous tutorial](tut_connection), with some small changes:
* Menu:  
    * You can pick your name, after starting the game it's passed to server/client scripts  
* Server:
    * Instead of _connection_ and _peerstream_ arrays, created _class client_data_ ( line: 10 )
    * GoToMenu function (describes itself)
* Client:
    * Connection timeout ( lines: 30, 43-48 )
    * GoToMenu()  
  
### Creating constants  
It isn't necessary, but it is pretty useful. We'll create some constants for client and server scripts so we can know what are we sending/receiving. You might ask why we won't send those commands as strings - well it works fine this way, but it most likely uses more of our and other players bandwidth. Sending (int) 1 probably uses less of it than (string) "PLAYER_DATA". So we define our `const PLAYER_DATA = 1`.  
There are few ways to do this, depending where your constant will be used, different method might be more effective:  
  
1. Adding constant in single script (after "extends" with vars etc.)
2. Creating [Autoload](http://docs.godotengine.org/en/latest/tutorials/step_by_step/singletons_autoload.html) containing those constants
3. Using [Globals](http://docs.godotengine.org/en/latest/classes/class_globals.html) object functions
4. Making your script extend other script.  
  
I'm going to show you how to use the last method.  
  
Create new script and save it as `net_constants.gd`  
  
![script](http://i133.photobucket.com/albums/q50/95seba/Godot%20Tutorials/script.png)  
  
  
Now add this code to it:  
````python
extends Node

const PLAYER_CONNECT = 0
const PLAYER_DISCONNECT = 1
const PLAYER_DATA = 2
const NAME_TAKEN = 3
const MESSAGE = 4
````  
And save it.  
Now just in your server and client scripts instead of `extends Node` line write `extends "res://net_constants.gd"`. Now you can freely use your constants without referencing to any other object.  
  
### Requesting spawn  
Our code notify us know when some player has connected, but it doesn't do anything else... yet.  
First thing what we want to do is spawning our player (well in this tutorial at least). But before we spawn it, it would be nice to know his name, so lets prepare for first data from player.  
````python
#SERVER
func _process( delta ):
# [...]
# inside " for client in connection " loop
		if !client.is_connected(): # maybe not connected anymore?
			print("Client disconnected "+str(client.get_status()))
			if connection[client].player: # if he have character spawned
				connection[client].player.queue_free() # delete it
			connection.erase(client) # remove him from dictionary
			continue # skip this run of loop / go to next element in loop
		
		if connection[client].peer.get_available_packet_count() > 0:
			for i in range( connection[client].peer.get_available_packet_count() ):
				var data = connection[client].peer.get_var()
				if data[0] == PLAYER_CONNECT: # data sent by client when connected
					if connection[client].player: # if client already have character
						continue # then ignore this data
					
					var new_player = load("res://Player/player.scn").instance() # create instance of player
					new_player.name = data[1] # name sent by client
					connection[client].player = new_player # assign this character to client
					add_child(new_player) # add character to scene
					BroadcastConnect(client) # tell all connected players that someone has joined
					SendConnect(client) # send connected players to new player

func BroadcastConnect( client ):
	var data = [ PLAYER_CONNECT, connection[client].player.name ]
	for cl in connection:
		if cl == client: # no need to send data to himself
			continue # next one please
		
		connection[cl].peer.put_var( data )

func SendConnect( client ):
	var data = [ PLAYER_CONNECT ]
	data.append( player.name ) # add self ( server )
	for cl in connection:
		if cl == client: 
			continue
		
		data.append( connection[cl].player.name ) # add other clients names
	connection[ client ].peer.put_var( data ) # send that data to connecting client
````  
  
With this code, when player send us PLAYER_CONNECT (we will add it to client soon) we will spawn new player at our scene, send request to other clients to spawn him and to connecting player we'll send list of currently connected players (so he can spawn them). Lets add something to client now:  
```` python
# CLIENT
func _ready():
# [...]
	if connection.get_status() == connection.STATUS_CONNECTED:
		# [ .. rest of the code .. ]
		peer.put_var( [ PLAYER_CONNECT, player.name ] ) # send our name to server
# [...]

func _process( delta ):
	if !connected: # not connected, but processing - means we got STATUS_CONNECTING earlier
		if connection.get_status() == connection.STATUS_CONNECTED:
			# [ .. rest of the code .. ]
			peer.put_var( [ PLAYER_CONNECT, player.name ] ) # send our name to server
			return # end this _process run
````  
This will send our name to server when we successfully connect to server. Now lets handle data which server sends to us:  
````python
func _process( delta ):
# instead of peer.get_available_packet_count()
	if peer.get_available_packet_count() > 0:
		for i in range( peer.get_available_packet_count() ):
			var data = peer.get_var()
			if data[0] == PLAYER_CONNECT: # here we receive other players names
				data.remove(0) # removing command from array
				for name in data: # looping through names
					# if data[i] == player.name:	continue    not needed here since we skip it on server
					if clones.has(name): # looks like he is already spawned
						print( name," already spawned?")
						continue
					var new_player = load("res://Player/player.scn").instance()
					new_player.name = name
					add_child(new_player)
					clones[ name ] = new_player # add to our dictionary { "name":Player.instance() }
````  
Now when you connect new player should be spawned at 0,0 pos.  
Keep in mind that currently our code can't handle multiple players with the same name ( MAYBE will show you how to fix it later ), so having players with same name might cause some bugs.  
  
  
### Sending common data  
Now we're going to transfer characters positions and animations between server and clients.  
I've intentionally skipped disconnection handling, because we'll use player "Quit" animation for that.  
  
Lets start with the movement. Before we send all players positions to all connected clients we first need to have those positions, so lets start with client:  
````python
func _process():
# [...]
			var data = peer.get_var()
			if data[0] == PLAYER_CONNECT: # here we receive other players names
  				# [...]
			elif data[0] == PLAYER_DATA: # lets add handling data meantime
				# our data will be [ PLAYER_DATA, [name, pos.x, pos.y, anim(as string)], [name, pos.x, pos.y, anim(as string)] ... ]
				data.remove(0) # remove PLAYER_DATA
				for _data in data: # _data is 1 client array
					if _data[0] == player.name: # it's us
						continue # so skip
					
					if clones.has(_data[0]): # we got him spawned, don't we?
						clones[ _data[0] ].set_pos( Vector2(_data[1],_data[2]) )
						clones[ _data[0] ].anim = _data[3] # yeah, sending string is inefficient, you should try to fix it later by yourself
	
	if connected:
		var pos = player.get_pos()
		peer.put_var( [ PLAYER_DATA, int(pos.x), int(pos.y), player.anim ] ) # int uses less bandwidth than float and we wont notice difference
		# currently we spam server every _process run
````  
  
Handling data by server and broadcasting to others:  
````python
# SERVER
func _process():
# [...]
				var data = connection[client].peer.get_var()
				if data[0] == PLAYER_CONNECT: # data sent by client when connected
					# [...]
				elif data[0] == PLAYER_DATA: # received data from client
					# data = [ PLAYER_DATA, pos.x, pos.y, anim ]
					connection[client].player.set_pos( Vector2(data[1],data[2]) )
					connection[client].player.anim = data[3]
	
	BroadcastData()

func BroadcastData():
	var data = [ PLAYER_DATA, [player.name, int(player.get_pos().x), int(player.get_pos().y), player.anim] ] # add yourself
	for client in connection:
		var char = connection[client].player
		data.append( [ char.name, int(char.get_pos().x), int(char.get_pos().y), char.anim ] ) # add all connected clients
	
	for client in connection:
		connection[client].peer.put_var( data ) # send data
````  
  
Now you should be able to move and see movement of everyone.  
  
### One last thing  
Our disconnecting. We've got our `Quit()` function in our player.gd which is triggered when "Quit" animation ends playing, so this kind of makes things even easier. All we need to do is to send our clients "Quit" animation for disconnecting player.  
Change this code:  
````python
		if !client.is_connected(): # maybe not connected anymore?
			print("Client disconnected "+str(client.get_status()))
			if connection[client].player: # if he have character spawned
				connection[client].player.queue_free() # delete it
			connection.erase(client) # remove him from dictionary
			continue # skip this run of loop / go to next element in loop
````  
To this:  
````python
		if !client.is_connected(): # maybe not connected anymore?
			print("Client disconnected "+str(client.get_status()))
			if connection[client].player: # if he have character spawned
				for cl in connection:
					if cl == client:
						continue
					var pos = connection[client].player.get_pos()
					connection[cl].peer.put_var( [ PLAYER_DATA, [connection[client].player.name, int(pos.x), int(pos.y), "Quit"] ] )
				connection[client].player.anim = "Quit"
			connection.erase(client) # remove him from dictionary
			continue # skip this run of loop / go to next element in loop
````  
  
***  
  
## Notes  
* It doesn't handle multiple players with the same name
* Netcode can be much more optimalized ( animation as string, sending pos each _process run )
* _fixed_process might have been better, since we deal with physics
  
## Credits  
To Theo for his Multiplayer Sample (links removed, since old forum is gone).
  
***  
  
## Downloads  
  
[Tutorial](https://drive.google.com/open?id=0Bz_8S_euQkQVMzBaUDdWTG93QUk&authuser=0)  
[Completed Tutorial](https://drive.google.com/open?id=0Bz_8S_euQkQVNkNHU1dqY2FLVlU&authuser=0)