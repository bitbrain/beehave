# holds all decodings for default values 
class_name GdDefaultValueDecoder 
extends GdUnitSingleton

@warning_ignore("unused_parameter")
var _decoders = {
	TYPE_NIL: func(value): return "<null>",
	TYPE_STRING: func(value): return '"%s"' % value,
	TYPE_STRING_NAME: func(value): return '"%s"' % value,
	TYPE_BOOL: func(value): return str(value).to_lower(),
	TYPE_FLOAT: func(value): return '%f' % value,
	TYPE_COLOR: func(value): return "Color%s" % value,
	TYPE_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_BYTE_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_STRING_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_FLOAT32_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_FLOAT64_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_INT32_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_INT64_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_COLOR_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_VECTOR2_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_PACKED_VECTOR3_ARRAY: func(value): return GdArrayTools.as_string(value),
	TYPE_RID: _on_type_RID,
	TYPE_VECTOR2: func(value): return "Vector2%s" % value,
	TYPE_VECTOR2I: func(value): return "Vector2i%s" % value,
	TYPE_VECTOR3: func(value): return "Vector3%s" % value,
	TYPE_VECTOR3I: func(value): return "Vector3i%s" % value,
	TYPE_VECTOR4: func(value): return "Vector4%s" % value,
	TYPE_VECTOR4I: func(value): return "Vector4i%s" % value,
	TYPE_RECT2: _on_decode_Rect2.bind(GdDefaultValueDecoder._regex("P: ?(\\(.+\\)), S: ?(\\(.+\\))")),
	TYPE_RECT2I: _on_decode_Rect2i.bind(GdDefaultValueDecoder._regex("P: ?(\\(.+\\)), S: ?(\\(.+\\))")),
	TYPE_TRANSFORM2D: _on_type_Transform2D,
	TYPE_TRANSFORM3D: _on_type_Transform3D,
}

static func _regex(pattern :String) -> RegEx:
	var regex := RegEx.new()
	var err = regex.compile(pattern)
	if err != OK:
		push_error("error '%s' checked pattern '%s'" % [err, pattern])
		return null
	return regex


func get_decoder(type :int) -> Callable:
	return _decoders.get(type, func(value): return '%s' % value)


func _on_type_Transform2D(value :Variant) -> String:
	var transform := value as Transform2D
	return "Transform2D(Vector2%s, Vector2%s, Vector2%s)" % [transform.x, transform.y, transform.origin]


func _on_type_Transform3D(value :Variant) -> String:
	var transform :Transform3D = value
	return "Transform3D(Vector3%s, Vector3%s, Vector3%s, Vector3%s)" % [transform.basis.x, transform.basis.y, transform.basis.z, transform.origin]


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


static func decode(value :Variant) -> String:
	var type := typeof(value) 
	var decoder :Callable = instance("GdUnitDefaultValueDecoders", func(): return GdDefaultValueDecoder.new()).get_decoder(type)
	if decoder == null:
		push_error("No value decoder registered for type '%d'! Please open a Bug issue at 'https://github.com/MikeSchulze/gdUnit4/issues/new/choose'." % type)
		return "null"
	return decoder.call(value)


static func decode_typed(type :int, value :Variant) -> String:
	var decoder :Callable = instance("GdUnitDefaultValueDecoders", func(): return GdDefaultValueDecoder.new()).get_decoder(type)
	if decoder == null:
		push_error("No value decoder registered for type '%d'! Please open a Bug issue at 'https://github.com/MikeSchulze/gdUnit4/issues/new/choose'." % type)
		return "null"
	return decoder.call(value)
