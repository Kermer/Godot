# Inaccurate type retrieval by inspecting string made of given value

func getType( val ):
	if val == null:
		return null
	val = str(val)
	if val.is_valid_float():
		if val.is_valid_integer():
			return TYPE_INT
		else:
			return TYPE_REAL
	elif val.match("[*:*]"):
		return TYPE_OBJECT
	elif val.match("(*:*)"):
		return TYPE_DICTIONARY
	elif val.match("*,*"):
		# might be an array, but say it's string
		return TYPE_STRING
	else:
		return TYPE_STRING
