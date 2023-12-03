extends RefCounted
class_name ErrorLogEntry


enum TYPE {
	SCRIPT_ERROR,
	PUSH_ERROR,
	PUSH_WARNING
}


const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")

const PATTERN_SCRIPT_ERROR := "USER SCRIPT ERROR:"
const PATTERN_PUSH_ERROR := "USER ERROR:"
const PATTERN_PUSH_WARNING := "USER WARNING:"


var _type :TYPE
var _line :int
var _message :String
var _details :String


func _init(type :TYPE, line :int, message :String, details :String):
	_type = type
	_line = line
	_message = message
	_details = details


static func extract_push_warning(records :PackedStringArray, index :int) -> ErrorLogEntry:
	return _extract(records, index, TYPE.PUSH_WARNING, PATTERN_PUSH_WARNING)


static func extract_push_error(records :PackedStringArray, index :int) -> ErrorLogEntry:
	return _extract(records, index, TYPE.PUSH_ERROR, PATTERN_PUSH_ERROR)


static func extract_error(records :PackedStringArray, index :int) -> ErrorLogEntry:
	return _extract(records, index, TYPE.SCRIPT_ERROR, PATTERN_SCRIPT_ERROR)


static func _extract(records :PackedStringArray, index :int, type :TYPE, pattern :String) -> ErrorLogEntry:
	var message := records[index]
	if message.contains(pattern):
		var error := message.replace(pattern, "").strip_edges()
		var details := records[index+1].strip_edges()
		var line := _parse_error_line_number(details)
		return ErrorLogEntry.new(type, line, error, details)
	return null


static func _parse_error_line_number(record :String) -> int:
	var regex := GdUnitSingleton.instance("error_line_regex", func() : return GdUnitTools.to_regex("at: .*res://.*:(\\d+)")) as RegEx
	var matches := regex.search(record)
	if matches != null:
		return matches.get_string(1).to_int()
	return -1
