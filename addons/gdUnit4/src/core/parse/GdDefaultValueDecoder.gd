# holds all decodings for default values 
class_name GdDefaultValueDecoder 
extends GdUnitSingleton


var _decoders = {
	TYPE_NIL: Callable(self, "_on_type_nill"),
	TYPE_STRING: Callable(self, "_on_type_string"),
	TYPE_STRING_NAME: Callable(self, "_on_type_string"),
	TYPE_BOOL: Callable(self, "_on_type_bool"),
	TYPE_RID: Callable(self, "_on_type_RID"),
	TYPE_RECT2: Callable(self, "_on_decode_Rect2").bind(GdDefaultValueDecoder._regex("P: ?(\\(.+\\)), S: ?(\\(.+\\))")),
	TYPE_RECT2I: Callable(self, "_on_decode_Rect2i").bind(GdDefaultValueDecoder._regex("P: ?(\\(.+\\)), S: ?(\\(.+\\))")),
	TYPE_TRANSFORM2D: Callable(self, "_on_type_Transform2D"),
	TYPE_TRANSFORM3D: Callable(self, "_on_type_Transform3D"),
	TYPE_PACKED_COLOR_ARRAY: Callable(self, "_on_type_PackedColorArray"),
}

static func _regex(pattern :String) -> RegEx:
	var regex := RegEx.new()
	var err = regex.compile(pattern)
	if err != OK:
		push_error("error '%s' checked pattern '%s'" % [err, pattern])
		return null
	return regex


func get_decoder(type :int) -> Callable:
	return _decoders.get(type)


func _on_type_self(value :Variant) -> String:
	return str(value)


@warning_ignore("unused_parameter")
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


@warning_ignore("unused_parameter")
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
	var decoder :Callable = instance("GdUnitDefaultValueDecoders", func(): return GdDefaultValueDecoder.new()).get_decoder(type)
	if decoder == null:
		push_error("No value decoder registered for type '%d'! Please open a Bug issue at 'https://github.com/MikeSchulze/gdUnit4/issues/new/choose'." % type)
		return "null"
	return decoder.call(value)
