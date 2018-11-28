# Introduction  
When creating a game it's good idea to think a while if you want game to be singleplayer (eventually with local co-op) or multiplayer. Why? Even if game looks similiar when playing local co-op or co-op through network, code in it is totally different.  
  
When you decide to change connection type of your game in the middle of your project you'll need to rewrite **ALL** your code! So take (some) time thinking about this.  
  
If you still want to make game which will use network you're welcome to read this tutorial...  
  
## Server  
  
At first I need you to download [pre-configured scene](https://drive.google.com/open?id=0Bz_8S_euQkQVZGxHbjkwOTdLSVk&authuser=0) so we can save some time creating nodes and focus on the code.  
  
Done downloading? Lets open it. I've made 3 scenes: `main_scene` (is here to load other two), `server` and `client`. For server and client I've added node "Debug" for printing in "game" window instead of debug window.  
  
We will start with opening `server.gd` script, first thing we want to do is creating our server object:  
````gdscript
func _ready():
	debug = get_node("Debug")
	server = TCP_Server.new()
```
and then we pick which port we want to listen:
```gdscript
	server.listen( port ) # 3560
````  
If `server.listen` returns something else than 0 that means there was some error, most likely something else on your PC is using this port. To avoid creating server to which people can't connect you should change that line to this code:
````gdscript
	if server.listen( port ) == 0:
		debug.add_text( "Server started on port "+str(port) ); debug.newline()
		set_process( true )
	else:
		debug.add_text( "Failed to start server on port "+str(port) ); debug.newline()
````
Now you will know if your server has started.  
Next part is handling connection:
````gdscript
func _process( delta ):
	if server.is_connection_available(): # check if someone's trying to connect
		var client = server.take_connection() # accept connection
		connection.append( client ) # we need to store him somewhere, that's why we created our Array
		peerstream.append( PacketPeerStream.new() ) # make new data transfer object for him
		var index = connection.find( client )
		peerstream[ index ].set_stream_peer( client ) # bind peerstream to new client
		debug.add_text( "Client has connected!" ); debug.newline()
````  
And handling client disconnect:
````gdscript
func _process( delta ):
# [ ... previous code ... ]
	for client in connection:
		if !client.is_connected(): # NOT connected
			debug.add_text("Client disconnected"); debug.newline()
			var index = connection.find( client )
			connection.remove( index ) # remove his connection
			peerstream.remove( index ) # remove his data transfer
````  
  
  
## Client  
Server looks ready for connections now. Lets start making our client. For server we had `TCP_Server` object and for client we need `StreamPeerTCP` object, so open `client.gd` script and add it:  
````gdscript
func _ready():
	debug = get_node("Debug")
	connection = StreamPeerTCP.new()
````
Now lets connect and check if we have succeeded:
````gdscript
func _ready():
# [ ... previous code ... ]
	connection.connect( ip, port )
	# since connection is created from StreamPeerTCP it also inherits its constants
	# get_status() returns following (int 0-3) values:
	if connection.get_status() == connection.STATUS_CONNECTED:
		debug.add_text( "Connected to "+ip+" :"+str(port) ); debug.newline()
		set_process(true) # start processing if connected
		connected = true # finally you can use this var ;)
	elif connection.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		debug.add_text( "Trying to connect "+ip+" :"+str(port) ); debug.newline()
		set_process(true) # or if trying to connect
	elif connection.get_status() == connection.STATUS_NONE or connection.get_status() == StreamPeerTCP.STATUS_ERROR:
		debug.add_text( "Couldn't connect to "+ip+" :"+str(port) ); debug.newline()
````  
When connecting to your own PC via any local IP( f.e. 127.0.0.1 ) and maybe (haven't tested yet) some LAN PC, `get_status()` in _ready() function will return `STATUS_CONNECTED`, but when you try to connect via network (even to your own IP) it'll return `STATUS_CONNECTING` because it didn't received reply instantly but after few (or more) miliseconds, so after _ready() function ended.  
  
**So now we process...**
````gdscript
func _process( delta ):
	if !connected: # it's inside _process, so if last status was STATUS_CONNECTING
		if connection.get_status() == connection.STATUS_CONNECTED:
			debug.add_text( "Connected to "+ip+" :"+str(port) ); debug.newline()
			connected = true
			return # skipping this _process run
	
	if connection.get_status() == connection.STATUS_NONE or connection.get_status() == connection.STATUS_ERROR:
		debug.add_text( "Server disconnected? " )
		set_process( false )
````  
  
Now you can test how your connection works - export it and run it in two windows.  
  

### Problem?  
If you tested this program you might have noticed that connection works fine, but you'll never get "Server disconnected?" or "Client disconnected".  
  
Why? Code so far is good. Everything works as it suppose to.  
  
I don't know if it work like that for some reason, but I know how to fix it. You just need to make some use of your peerstreams:
````gdscript
# Server
func _process( delta ):
# [ ... rest of the code ... ]
	for peer in peerstream:
		peer.get_available_packet_count()
````
````gdscript
# Client
func _ready():
# Anywhere after  connection.connect( ip, port )
	peerstream = PacketPeerStream.new()
	peerstream.set_stream_peer( connection )

func _process( delta ):
# [ ... rest of the code ... ]
	peerstream.get_available_packet_count()
````  
Now export and run again and see if disconnecting displays correctly.  
  
### PacketPeerStream  
We used [PacketPeerStream](http://docs.godotengine.org/en/latest/classes/class_packetpeerstream.html) here to let know if opposite site of link disconnected, but it have much more important job - it's most commonly used for receiving and sending data via network.  
  
I'll say more about `PacketPeerStream` and data transfering in my [TCP Data Transfer](https://github.com/Kermer/Godot/tree/master/Tutorials/tut_tcp_data_transfer.md) tutorial.  
  
### Downloads  
  
[Tutorial - empty](https://drive.google.com/open?id=0Bz_8S_euQkQVZGxHbjkwOTdLSVk&authuser=0)  
  
[Tutorial - completed](https://drive.google.com/open?id=0Bz_8S_euQkQVY1Z1cFhkT1F0RlE&authuser=0)
