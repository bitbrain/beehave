class_name GdUnitExpressionRunner
extends RefCounted

const CLASS_TEMPLATE = """
class_name _ExpressionRunner extends '${clazz_path}'

func __run_expression() -> Variant:
	return $expression

"""

func execute(src_script :GDScript, expression :String) -> Variant:
	var script := GDScript.new()
	var resource_path := "res://addons/gdUnit4/src/Fuzzers.gd" if src_script.resource_path.is_empty() else src_script.resource_path
	script.source_code = CLASS_TEMPLATE.dedent()\
		.replace("${clazz_path}", resource_path)\
		.replace("$expression", expression)
	script.reload(false)
	var runner :Variant = script.new()
	if runner.has_method("queue_free"):
		runner.queue_free()
	return runner.__run_expression()


func to_fuzzer(src_script :GDScript, expression :String) -> Fuzzer:
	return  execute(src_script, expression) as Fuzzer
