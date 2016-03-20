# For getting translation strings with extra params
# Example:
# In your .csv file: PLAYER_HEALTH, %0's health is %1, <other language translation>
# get_string("PLAYER_HEALTH",["Player1",56]) will return "Player1's health is 56"

func get_string( key, params=Array() ):
	var string = tr(key)
	for i in range(params.size()):
		string = string.replace(str("%",i),str(params[i]))
	
	return string

