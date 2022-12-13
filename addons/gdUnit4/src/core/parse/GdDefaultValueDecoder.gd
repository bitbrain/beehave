# holds all decodings for default values 
class_name GdDefaultValueDecoder 
extends RefCounted

const __store := [{}]

static func _regex(pattern :String) -> RegEx:
	var regex := RegEx.new()
	var err = regex.compile(pattern)
	if err != OK:
		push_error("error '%s' checked pattern '%s'" % [err, pattern])
		return null
	return regex

static func _add_value(key : Variant, value : Variant, overwrite := false) -> Variant:
	if overwrite and __store[0].has(key):
		push_error("An value already exists with key: %s" % key)
		return null
	__store[0][key] = value
	return value

static func _get_value(key: Variant, default: Variant = null) -> Variant:
	return __store[0][key]

static func _is_empty() -> bool:
	return __store[0].is_empty()

static func clear() -> void:
	__store[0].clear()

static func _decoder(type :int) -> Callable:
	if not _is_empty():
		return _get_value(type, null)
	# cache all decodes
	var decoder := GdDefaultValueDecoder.new()
	_add_value("decoder", decoder)
	_add_value(TYPE_NIL, Callable(decoder, "_on_type_nill"))
	_add_value(TYPE_STRING, Callable(decoder, "_on_type_string"))
	_add_value(TYPE_STRING_NAME, Callable(decoder, "_on_type_string"))
	_add_value(TYPE_BOOL, Callable(decoder, "_on_type_bool"))
	_add_value(TYPE_RID, Callable(decoder, "_on_type_RID"))
	_add_value(TYPE_RECT2, Callable(decoder, "_on_decode_Rect2").bind(_regex("P: ?(\\(.+\\)), S: ?(\\(.+\\))")))
	_add_value(TYPE_RECT2I, Callable(decoder, "_on_decode_Rect2i").bind(_regex("P: ?(\\(.+\\)), S: ?(\\(.+\\))")))
	_add_value(TYPE_TRANSFORM2D, Callable(decoder, "_on_type_Transform2D"))
	_add_value(TYPE_TRANSFORM3D, Callable(decoder, "_on_type_Transform3D"))
	_add_value(TYPE_PACKED_COLOR_ARRAY, Callable(decoder, "_on_type_PackedColorArray"))
	return _get_value(type, null)

func _on_type_self(value :Variant) -> String:
	return str(value)

func _on_type_nill(value :Variant) -> String:
	return "null"

func _on_type_string(value :Variant) -> String:
	return "\"%s\"" % value

func _on_type_bool(value :Variant) -> String:
	return str(value).to_lower()

func _on_type_Transform2D(value :Variant) -> String:
	var transform := value as Transform2D
	return "Transform2D(Vector2%s, Vector2%s, Vector2%s)" % [transform.x, transform.y, transform.origin]

func _on_type_Transform3D(value :Variant) -> String:
	var transform :Transform3D = value
	return "Transform3D(Vector3%s, Vector3%s, Vector3%s, Vector3%s)" % [transform.basis.x, transform.basis.y, transform.basis.z, transform.origin]

func _on_type_PackedColorArray(value :Variant) -> String:
	var array := value as PackedColorArray
	if array.is_empty():
		return "[]"
	else:
		push_error("TODO, implemnt compile array values")
		return "invalid"

func _on_type_RID(value :Variant) -> String:
	return "RID()"

func _on_decode_Rect2(value :Variant, regEx :RegEx) -> String:
	for reg_match in regEx.search_all(str(value)):
		var decodeP = reg_match.get_string(1)
		var decodeS = reg_match.get_string(2)
		return "Rect2(Vector2%s, Vector2%s)" % [decodeP, decodeS]
	return "Rect2()"

func _on_decode_Rect2i(value :Variant, regEx :RegEx) -> String:

	for reg_match in regEx.search_all(str(value)):
		var decodeP = reg_match.get_string(1)
		var decodeS = reg_match.get_string(2)
		return "Rect2i(Vector2i%s, Vector2i%s)" % [decodeP, decodeS]
	return "Rect2i()"

static func decode(type :int, value :Variant) -> String:
	return _decoder(type).call(value)
