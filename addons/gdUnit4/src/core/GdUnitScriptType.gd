class_name GdUnitScriptType
extends RefCounted

const UNKNOWN := ""
const CS := "cs"
const GD := "gd"
const NATIVE := "gdns"
const VS := "vs"

static func type_of(script :Script) -> String:
	if script == null:
		return UNKNOWN
	if GdObjects.is_gd_script(script):
		return GD
	if GdObjects.is_vs_script(script):
		return VS
	if GdObjects.is_native_script(script):
		return NATIVE
	if GdObjects.is_cs_script(script):
		return CS
	return UNKNOWN
