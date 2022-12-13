class_name GdUnit4Version
extends RefCounted

const VERSION_PATTERN = "[center][color=#9887c4]gd[/color][color=#7a57d6]Unit[/color][color=#9887c4]4[/color] [color=#9887c4]${version}[/color][/center]"

var _major :int
var _minor :int
var _patch :int

func _init(major :int,minor :int,patch :int):
	_major = major
	_minor = minor
	_patch = patch

static func parse(value :String) -> GdUnit4Version:
	var regex := RegEx.new()
	regex.compile("[a-zA-Z:,-]+")
	var cleaned := regex.sub(value, "", true)
	var parts := cleaned.split(".")
	var major := parts[0].to_int()
	var minor := parts[1].to_int()
	var patch := parts[2].to_int() if parts.size() > 2 else 0
	return GdUnit4Version.new(major, minor, patch)

static func current() -> GdUnit4Version:
	var config = ConfigFile.new()
	config.load('addons/gdUnit4/plugin.cfg')
	return parse(config.get_value('plugin', 'version'))

func equals(other :) -> bool:
	return _major == other._major and _minor == other._minor and _patch == other._patch

func is_greater(other :) -> bool:
	if _major > other._major:
		return true
	if _major == other._major and _minor > other._minor:
		return true
	return _major == other._major and _minor == other._minor and _patch > other._patch

static func init_version_label(label :Control) -> void:
	var config = ConfigFile.new()
	config.load('addons/gdUnit4/plugin.cfg')
	var version = config.get_value('plugin', 'version')
	if label is RichTextLabel:
		label.text = VERSION_PATTERN.replace('${version}', version)
	else:
		label.text = "gdUnit4 " + version

func _to_string() -> String:
	return "v%d.%d.%d" % [_major, _minor, _patch]
