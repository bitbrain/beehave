class_name GdScriptParser
extends RefCounted

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")

const ALLOWED_CHARACTERS := "0123456789_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\""

var TOKEN_NOT_MATCH := Token.new("")
var TOKEN_SPACE := SkippableToken.new(" ")
var TOKEN_TABULATOR := SkippableToken.new("\t")
var TOKEN_NEW_LINE := SkippableToken.new("\n")
var TOKEN_COMMENT := SkippableToken.new("#")
var TOKEN_CLASS_NAME := Token.new("class_name")
var TOKEN_INNER_CLASS := Token.new("class")
var TOKEN_EXTENDS := Token.new("extends")
var TOKEN_ENUM := Token.new("enum")
var TOKEN_FUNCTION_STATIC_DECLARATION := Token.new("staticfunc")
var TOKEN_FUNCTION_DECLARATION := Token.new("func")
var TOKEN_FUNCTION := Token.new(".")
var TOKEN_FUNCTION_RETURN_TYPE := Token.new("->")
var TOKEN_FUNCTION_END := Token.new("):")
var TOKEN_ARGUMENT_ASIGNMENT := Token.new("=")
var TOKEN_ARGUMENT_TYPE_ASIGNMENT := Token.new(":=")
var TOKEN_ARGUMENT_FUZZER := FuzzerToken.new(GdUnitTools.to_regex("((?!(fuzzer_(seed|iterations)))fuzzer?\\w+)( ?+= ?+| ?+:= ?+| ?+:Fuzzer ?+= ?+|)"))
var TOKEN_ARGUMENT_TYPE := Token.new(":")
var TOKEN_ARGUMENT_SEPARATOR := Token.new(",")
var TOKEN_BRACKET_OPEN := Token.new("(")
var TOKEN_BRACKET_CLOSE := Token.new(")")
var TOKEN_ARRAY_OPEN := Token.new("[")
var TOKEN_ARRAY_CLOSE := Token.new("]")

var OPERATOR_ADD := Operator.new("+")
var OPERATOR_SUB := Operator.new("-")
var OPERATOR_MUL := Operator.new("*")
var OPERATOR_DIV := Operator.new("/")
var OPERATOR_REMAINDER := Operator.new("%")

var TOKENS := [
	TOKEN_SPACE,
	TOKEN_TABULATOR,
	TOKEN_NEW_LINE,
	TOKEN_COMMENT,
	TOKEN_BRACKET_OPEN,
	TOKEN_BRACKET_CLOSE,
	TOKEN_ARRAY_OPEN,
	TOKEN_ARRAY_CLOSE,
	TOKEN_CLASS_NAME,
	TOKEN_INNER_CLASS,
	TOKEN_EXTENDS,
	TOKEN_ENUM,
	TOKEN_FUNCTION_STATIC_DECLARATION,
	TOKEN_FUNCTION_DECLARATION,
	TOKEN_ARGUMENT_FUZZER,
	TOKEN_ARGUMENT_TYPE_ASIGNMENT,
	TOKEN_ARGUMENT_ASIGNMENT,
	TOKEN_ARGUMENT_TYPE,
	TOKEN_FUNCTION,
	TOKEN_ARGUMENT_SEPARATOR,
	TOKEN_FUNCTION_RETURN_TYPE,
	OPERATOR_ADD,
	OPERATOR_SUB,
	OPERATOR_MUL,
	OPERATOR_DIV,
	OPERATOR_REMAINDER,
]

var _regex_clazz_name :RegEx
var _base_clazz :String
var _scanned_inner_classes := PackedStringArray()


static func clean_up_row(row :String) -> String:
	return to_unix_format(row.replace(" ", "").replace("\t", ""))


static func to_unix_format(input :String) -> String:
	return input.replace("\r\n", "\n")


class Token extends RefCounted:
	var _token: String
	var _consumed: int
	var _is_operator: bool
	var _regex :RegEx
	
	
	func _init(p_token: String, p_is_operator := false, p_regex :RegEx = null) -> void:
		_token = p_token
		_is_operator = p_is_operator
		_consumed = p_token.length()
		_regex = p_regex
	
	func match(input: String, pos: int) -> bool:
		if _regex:
			var result := _regex.search(input, pos)
			if result == null:
				return false
			_consumed = result.get_end() - result.get_start()
			return pos == result.get_start()
		return input.findn(_token, pos) == pos
	
	func is_operator() -> bool:
		return _is_operator
	
	func is_inner_class() -> bool:
		return _token == "class"
	
	func is_variable() -> bool:
		return false
	
	func is_token(token_name :String) -> bool:
		return _token == token_name
	
	func is_skippable() -> bool:
		return false
	
	func _to_string():
		return "Token{" + _token + "}"


class Operator extends Token:
	func _init(value: String):
		super(value, true)
	
	func _to_string():
		return "OperatorToken{%s}" % [_token]


# A skippable token, is just a placeholder like space or tabs
class SkippableToken extends Token:
	
	func _init(p_token: String):
		super(p_token)
	
	func is_skippable() -> bool:
		return true


# Token to parse Fuzzers
class FuzzerToken extends Token:
	var _name: String
	
	
	func _init(regex: RegEx):
		super("", false, regex)
	
	
	func match(input: String, pos: int) -> bool:
		if _regex:
			var result := _regex.search(input, pos)
			if result == null:
				return false
			_name = result.strings[1]
			_consumed = result.get_end() - result.get_start()
			return pos == result.get_start()
		return input.findn(_token, pos) == pos
	
	
	func name() -> String:
		return _name
	
	
	func type() -> int:
		return GdObjects.TYPE_FUZZER
	
	
	func _to_string():
		return "FuzzerToken{%s: '%s'}" % [_name, _token]


# Token to parse function arguments
class Variable extends Token:
	var _plain_value
	var _typed_value
	var _type :int = TYPE_NIL
	
	
	func _init(p_value: String):
		super(p_value)
		_type = _scan_type(p_value)
		_plain_value = p_value
		_typed_value = _cast_to_type(p_value, _type)
	
	
	func _scan_type(p_value: String) -> int:
		if p_value.begins_with("\"") and p_value.ends_with("\""):
			return TYPE_STRING
		var type_ := GdObjects.string_to_type(p_value)
		if type_ != TYPE_NIL:
			return type_
		if p_value.is_valid_int():
			return TYPE_INT
		if p_value.is_valid_float():
			return TYPE_FLOAT
		if p_value.is_valid_hex_number():
			return TYPE_INT
		return TYPE_OBJECT
	
	
	func _cast_to_type(p_value :String, p_type: int) -> Variant:
		match p_type:
			TYPE_STRING:
				return p_value#.substr(1, p_value.length() - 2)
			TYPE_INT:
				return p_value.to_int()
			TYPE_FLOAT:
				return p_value.to_float()
		return p_value
	
	
	func is_variable() -> bool:
		return true
	
	
	func type() -> int:
		return _type
	
	
	func value():
		return _typed_value
	
	
	func plain_value():
		return _plain_value
	
	
	func _to_string():
		return "Variable{%s: %s : '%s'}" % [_plain_value, GdObjects.type_as_string(_type), _token]


class TokenInnerClass extends Token:
	var _clazz_name
	var _content := PackedStringArray()
	
	
	static func _strip_leading_spaces(input :String) -> String:
		var characters := input.to_ascii_buffer()
		while not characters.is_empty():
			if characters[0] != 0x20:
				break
			characters.remove_at(0)
		return characters.get_string_from_ascii()
	
	
	static func _consumed_bytes(row :String) -> int:
		return row.replace(" ", "").replace("	", "").length()
	
	
	func _init(clazz_name :String):
		super("class")
		_clazz_name = clazz_name
	
	
	func is_class_name(clazz_name :String) -> bool:
		return _clazz_name == clazz_name
	
	
	func content() -> PackedStringArray:
		return _content
	
	
	func parse(source_rows :PackedStringArray, offset :int) -> void:
		# add class signature
		_content.append(source_rows[offset])
		# parse class content
		for row_index in range(offset+1, source_rows.size()):
			# scan until next non tab
			var source_row := source_rows[row_index]
			var row = TokenInnerClass._strip_leading_spaces(source_row)
			if row.is_empty() or row.begins_with("\t") or row.begins_with("#"):
				# fold all line to left by removing leading tabs and spaces
				if source_row.begins_with("\t"):
					source_row = source_row.trim_prefix("\t")
				# refomat invalid empty lines
				if source_row.dedent().is_empty():
					_content.append("")
				else:
					_content.append(source_row)
				continue
			break
		_consumed += TokenInnerClass._consumed_bytes("".join(_content))
	
	
	func _to_string():
		return "TokenInnerClass{%s}" % [_clazz_name]


func _init():
	_regex_clazz_name = GdUnitTools.to_regex("(class)([a-zA-Z0-9]+)(extends[a-zA-Z]+:)|(class)([a-zA-Z0-9]+)(:)")


func get_token(input :String, current_index) -> Token:
	for t in TOKENS:
		if t.match(input, current_index):
			return t
	return TOKEN_NOT_MATCH


func next_token(input: String, current_index: int) -> Token:
	var token := TOKEN_NOT_MATCH
	for t in TOKENS:
		if t.match(input, current_index):
			token = t
			break
	if token == OPERATOR_SUB:
		token = tokenize_value(input, current_index, token)
	if token == TOKEN_INNER_CLASS:
		token = tokenize_inner_class(input, current_index, token)
	if token == TOKEN_NOT_MATCH:
		return tokenize_value(input, current_index, token)
	return token


func tokenize_value(input: String, current: int, token: Token) -> Token:
	var next := 0
	var current_token := ""
	# test for '--', '+-', '*-', '/-', '%-', or at least '-x'
	var test_for_sign := (token == null or token.is_operator()) and input[current] == "-"
	while current + next < len(input):
		var character := input[current + next] as String
		# if first charater a sign
		# or allowend charset
		# or is a float value
		if (test_for_sign and next==0) \
			or character in ALLOWED_CHARACTERS \
			or (character == "." and current_token.is_valid_int()):
			current_token += character
			next += 1
			continue
		break
	if current_token != "":
		return Variable.new(current_token)
	return TOKEN_NOT_MATCH


func extract_clazz_name(value :String) -> String:
	var result := _regex_clazz_name.search(value)
	if result == null:
		push_error("Can't extract class name from '%s'" % value)
		return ""
	if result.get_string(2).is_empty():
		return result.get_string(5)
	else:
		return result.get_string(2)


@warning_ignore("unused_parameter")
func tokenize_inner_class(source_code: String, current: int, token: Token) -> Token:
	var clazz_name := extract_clazz_name(source_code.substr(current, 64))
	return TokenInnerClass.new(clazz_name)


@warning_ignore("assert_always_false")
func _process_values(left: Token, token_stack: Array, operator: Token) -> Token:
	# precheck
	if left.is_variable() and operator.is_operator():
		var lvalue = left.value()
		var value = null
		var next_token_ = token_stack.pop_front() as Token
		match operator:
			OPERATOR_ADD:
				value =  lvalue + next_token_.value()
			OPERATOR_SUB:
				value =  lvalue - next_token_.value()
			OPERATOR_MUL:
				value =  lvalue * next_token_.value()
			OPERATOR_DIV:
				value =  lvalue / next_token_.value()
			OPERATOR_REMAINDER:
				value =  lvalue & next_token_.value()
			_:
				assert(false, "Unsupported operator %s" % operator)
		return Variable.new( str(value))
	return operator


func parse_func_return_type(row: String) -> int:
	var token := parse_return_token(row)
	if token == TOKEN_NOT_MATCH:
		return TYPE_NIL
	return token.type()


func parse_return_token(input: String) -> Token:
	var index := input.rfind(TOKEN_FUNCTION_RETURN_TYPE._token)
	if index == -1:
		return TOKEN_NOT_MATCH
	index += TOKEN_FUNCTION_RETURN_TYPE._consumed
	var token := next_token(input, index)
	while !token.is_variable() and token != TOKEN_NOT_MATCH:
		index += token._consumed
		token = next_token(input, index)
	return token


# Parses the argument into a argument signature
# e.g. func foo(arg1 :int, arg2 = 20) -> [arg1, arg2]
func parse_arguments(input: String) -> Array[GdFunctionArgument]:
	var args :Array[GdFunctionArgument] = []
	var current_index := 0
	var token :Token = null
	var bracket := 0
	var in_function := false
	while current_index < len(input):
		token = next_token(input, current_index)
		# fallback to not end in a endless loop
		if token == TOKEN_NOT_MATCH:
			var error : = """
				Parsing Error: Invalid token at pos %d found.
				Please report this error!
				source_code:
				--------------------------------------------------------------
				%s
				--------------------------------------------------------------
			""".dedent() % [current_index, input]
			push_error(error)
			current_index += 1
			continue
		current_index += token._consumed
		if token.is_skippable():
			continue
		if token == TOKEN_BRACKET_OPEN:
			in_function = true
			bracket += 1
			continue
		if token == TOKEN_BRACKET_CLOSE:
			bracket -= 1
		# if function end?
		if in_function and bracket == 0:
			return args
		# is function
		if token == TOKEN_FUNCTION_DECLARATION:
			token = next_token(input, current_index)
			current_index += token._consumed
			continue
		# is fuzzer argument
		if token is FuzzerToken:
			var arg_value := _parse_end_function(input.substr(current_index), true)
			current_index += arg_value.length()
			args.append(GdFunctionArgument.new(token.name(), token.type(), arg_value))
			continue
		# is value argument
		if in_function and token.is_variable():
			var arg_name :String = token.plain_value()
			var arg_type :int = TYPE_NIL
			var arg_value = GdFunctionArgument.UNDEFINED
			# parse type and default value
			while current_index < len(input):
				token = next_token(input, current_index)
				current_index += token._consumed
				if token.is_skippable():
					continue
				match token:
					TOKEN_ARGUMENT_TYPE:
						token = next_token(input, current_index)
						if token == TOKEN_SPACE:
							current_index += token._consumed
							token = next_token(input, current_index)
						arg_type = GdObjects.string_as_typeof(token._token)
					TOKEN_ARGUMENT_TYPE_ASIGNMENT:
						arg_value = _parse_end_function(input.substr(current_index), true)
						current_index += arg_value.length()
					TOKEN_ARGUMENT_ASIGNMENT:
						token = next_token(input, current_index)
						arg_value = _parse_end_function(input.substr(current_index), true)
						current_index += arg_value.length()
					TOKEN_BRACKET_OPEN:
						bracket += 1
						# if value a function?
						if bracket > 1:
							# complete the argument value
							var func_begin = input.substr(current_index-TOKEN_BRACKET_OPEN._consumed)
							var func_body = _parse_end_function(func_begin)
							arg_value += func_body
							# fix parse index to end of value
							current_index += func_body.length() - TOKEN_BRACKET_OPEN._consumed - TOKEN_BRACKET_CLOSE._consumed
					TOKEN_BRACKET_CLOSE:
						bracket -= 1
						# end of function
						if bracket == 0:
							break
					TOKEN_ARGUMENT_SEPARATOR:
						if bracket <= 1:
							break
			arg_value = arg_value.lstrip(" ")
			if arg_type == TYPE_NIL and arg_value != GdFunctionArgument.UNDEFINED:
				if arg_value.begins_with("Color."):
					arg_type = TYPE_COLOR
				elif arg_value.begins_with("Vector2."):
					arg_type = TYPE_VECTOR2
				elif arg_value.begins_with("Vector3."):
					arg_type = TYPE_VECTOR3
				elif arg_value.begins_with("AABB("):
					arg_type = TYPE_AABB
				elif arg_value.begins_with("["):
					arg_type = TYPE_ARRAY
				elif arg_value.begins_with("{"):
					arg_type = TYPE_DICTIONARY
				else:
					arg_type = typeof(str_to_var(arg_value))
					if arg_value.rfind(")") == arg_value.length()-1:
						arg_type = GdObjects.TYPE_FUNC
					elif arg_type == TYPE_NIL:
						arg_type = TYPE_STRING
			args.append(GdFunctionArgument.new(arg_name, arg_type, arg_value))
	return args


# Parse an string for an argument with given name <argument_name> and returns the value
# if the argument not found the <default_value> is returned
func parse_argument(row: String, argument_name: String, default_value):
	var input := GdScriptParser.clean_up_row(row)
	var argument_found := false
	var current_index := 0
	var token :Token = null
	while current_index < len(input):
		token = next_token(input, current_index) as Token
		current_index += token._consumed
		if token == TOKEN_NOT_MATCH:
			return default_value
		if not argument_found and not token.is_token(argument_name):
			continue
		argument_found = true
		# extract value
		if token == TOKEN_ARGUMENT_TYPE_ASIGNMENT:
				token = next_token(input, current_index) as Token
				return token.value()
		elif token == TOKEN_ARGUMENT_ASIGNMENT:
				token = next_token(input, current_index) as Token
				return token.value()
	return default_value


func _parse_end_function(input: String, remove_trailing_char := false) -> String:
	# find end of function
	var current_index := 0
	var bracket_count := 0
	var in_array := 0
	var end_of_func = false
	
	while current_index < len(input) and not end_of_func:
		var character = input[current_index]
		# step over strings
		if character == "'" :
			current_index = input.find("'", current_index+1) + 1
			if current_index == 0:
				push_error("Parsing error on '%s', can't evaluate end of string." % input)
				return ""
			continue
		if character == '"' :
			# test for string blocks
			if input.find('"""', current_index) == current_index:
				current_index = input.find('"""', current_index+3) + 3
			else:
				current_index = input.find('"', current_index+1) + 1
			if current_index == 0:
				push_error("Parsing error on '%s', can't evaluate end of string." % input)
				return ""
			continue
		
		match character:
			# count if inside an array
			"[": in_array += 1
			"]": in_array -= 1
			# count if inside a function
			"(": bracket_count += 1
			")":
				bracket_count -= 1
				if bracket_count < 0 and in_array <= 0:
					end_of_func = true
			",":
				if bracket_count == 0 and in_array == 0:
					end_of_func = true
		current_index += 1
	if remove_trailing_char:
		# check if the parsed value ends with comma or end of doubled breaked
		# `<value>,` or `<function>())`
		var trailing_char := input[current_index-1]
		if trailing_char == ',' or (bracket_count < 0 and trailing_char == ')'):
			return input.substr(0, current_index-1)
	return input.substr(0, current_index)


func extract_inner_class(source_rows: PackedStringArray, clazz_name :String) -> PackedStringArray:
	for row_index in source_rows.size():
		var input := GdScriptParser.clean_up_row(source_rows[row_index])
		var token := next_token(input, 0)
		if token.is_inner_class():
			if token.is_class_name(clazz_name):
				token.parse(source_rows, row_index)
				return token.content()
	return PackedStringArray()


func extract_source_code(script_path :PackedStringArray) -> PackedStringArray:
	if script_path.is_empty():
		push_error("Invalid script path '%s'" % script_path)
		return PackedStringArray()
	#load the source code
	var resource_path := script_path[0]
	var script :GDScript = load(resource_path)
	var source_code := load_source_code(script, script_path)
	var base_script := script.get_base_script()
	if base_script:
		_base_clazz = GdObjects.extract_class_name_from_class_path([base_script.resource_path])
		source_code += load_source_code(base_script, script_path)
	return source_code


func extract_func_signature(rows :PackedStringArray, index :int) -> String:
	var signature := ""
	
	for rowIndex in range(index, rows.size()):
		var row := rows[rowIndex]
		signature += row + "\n"
		if is_func_end(row):
			return signature.strip_edges()
	push_error("Can't fully extract function signature of '%s'" % rows[index])
	return ""


func load_source_code(script :GDScript, script_path :PackedStringArray) -> PackedStringArray:
	var map := script.get_script_constant_map()
	for key in map.keys():
		var value = map.get(key)
		if value is GDScript:
			var class_path := GdObjects.extract_class_path(value)
			if class_path.size() > 1:
				_scanned_inner_classes.append(class_path[1])
	
	var source_code := GdScriptParser.to_unix_format(script.source_code)
	var source_rows := source_code.split("\n")
	# extract all inner class names
	# want to extract an inner class?
	if script_path.size() > 1:
		var inner_clazz = script_path[1]
		source_rows = extract_inner_class(source_rows, inner_clazz)
	return PackedStringArray(source_rows)


func get_class_name(script :GDScript) -> String:
	var source_code := GdScriptParser.to_unix_format(script.source_code)
	var source_rows := source_code.split("\n")
	
	for index in min(10, source_rows.size()):
		var input = GdScriptParser.clean_up_row(source_rows[index])
		var token := next_token(input, 0)
		if token == TOKEN_CLASS_NAME:
			token = tokenize_value(input, token._consumed, token)
			return token.value()
	# if no class_name found extract from file name
	return GdObjects.to_pascal_case(script.resource_path.get_basename().get_file())


func parse_func_name(row :String) -> String:
	var input = GdScriptParser.clean_up_row(row)
	var current_index = 0
	var token := next_token(input, current_index)
	current_index += token._consumed
	if token != TOKEN_FUNCTION_STATIC_DECLARATION and token != TOKEN_FUNCTION_DECLARATION:
		return ""
	while not token is Variable:
		token = next_token(input, current_index)
		current_index += token._consumed
	return token._token


func parse_functions(rows :PackedStringArray, clazz_name :String, clazz_path :PackedStringArray, included_functions := PackedStringArray()) -> Array[GdFunctionDescriptor]:
	var func_descriptors :Array[GdFunctionDescriptor] = []
	for rowIndex in rows.size():
		var row = rows[rowIndex]
		# step over inner class functions
		if row.begins_with("\t"):
			continue
		var input = GdScriptParser.clean_up_row(row)
		# skip comments and empty lines
		if input.begins_with("#") or input.length() == 0:
			continue
		var token := next_token(input, 0)
		if token == TOKEN_FUNCTION_STATIC_DECLARATION or token == TOKEN_FUNCTION_DECLARATION:
			if _is_func_included(input, included_functions):
				var func_signature = extract_func_signature(rows, rowIndex)
				var fd := parse_func_description(func_signature, clazz_name, clazz_path, rowIndex+1)
				fd._is_coroutine = is_func_coroutine(rows, rowIndex)
				func_descriptors.append(fd)
	return func_descriptors


func is_func_coroutine(rows :PackedStringArray, index :int) -> bool:
	var is_coroutine := false
	for rowIndex in range( index+1, rows.size()):
		var row = rows[rowIndex]
		is_coroutine = row.contains("await")
		if is_coroutine:
			return true
		var input = GdScriptParser.clean_up_row(row)
		var token := next_token(input, 0)
		if token == TOKEN_FUNCTION_STATIC_DECLARATION or token == TOKEN_FUNCTION_DECLARATION:
			break
	return is_coroutine


func _is_func_included(row :String, included_functions :PackedStringArray) -> bool:
	if included_functions.is_empty():
		return true
	for name in included_functions:
		if row.find(name) != -1:
			return true
	return false


func parse_func_description(func_signature :String, clazz_name :String, clazz_path :PackedStringArray, line_number :int) -> GdFunctionDescriptor:
	var name =  parse_func_name(func_signature)
	var return_type :int
	var return_clazz := ""
	var token := parse_return_token(func_signature)
	if token == TOKEN_NOT_MATCH:
		return_type = GdObjects.TYPE_VARIANT
	else:
		return_type = token.type()
		if token.type() == TYPE_OBJECT:
			return_clazz = _patch_inner_class_names(token.value(), clazz_name)
	
	return GdFunctionDescriptor.new(
		name,
		line_number,
		is_virtual_func(clazz_name, clazz_path, name),
		is_static_func(func_signature),
		false,
		return_type,
		return_clazz,
		parse_arguments(func_signature)
	)


# caches already parsed classes for virtual functions
# key: <clazz_name> value: a Array of virtual function names
var _virtual_func_cache := Dictionary()

func is_virtual_func(clazz_name :String, clazz_path :PackedStringArray, func_name :String) -> bool:
	if _virtual_func_cache.has(clazz_name):
		return _virtual_func_cache[clazz_name].has(func_name)
	var virtual_functions := Array()
	var method_list := GdObjects.extract_class_functions(clazz_name, clazz_path)
	for method_descriptor in method_list:
		var is_virtual_function :bool = method_descriptor["flags"] & METHOD_FLAG_VIRTUAL
		if is_virtual_function:
			virtual_functions.append(method_descriptor["name"])
	_virtual_func_cache[clazz_name] = virtual_functions
	return _virtual_func_cache[clazz_name].has(func_name)


func is_static_func(func_signature :String) -> bool:
	var input := GdScriptParser.clean_up_row(func_signature)
	var token := next_token(input, 0)
	return token == TOKEN_FUNCTION_STATIC_DECLARATION


func is_inner_class(clazz_path :PackedStringArray) -> bool:
	return clazz_path.size() > 1


func is_func_end(row :String) -> bool:
	return row.strip_edges(false, true).ends_with(":")


func _patch_inner_class_names(value :String, clazz_name :String) -> String:
	var patch := value
	var base_clazz := clazz_name.split(".")[0]
	for inner_clazz_name in _scanned_inner_classes:
		var full_inner_clazz_path = base_clazz + "." + inner_clazz_name
		patch = patch.replace(inner_clazz_name, full_inner_clazz_path)
	return patch


func extract_functions(script :GDScript, clazz_name :String, clazz_path :PackedStringArray) -> Array:
	var source_code := load_source_code(script, clazz_path)
	return parse_functions(source_code, clazz_name, clazz_path)


func parse(clazz_name :String, clazz_path :PackedStringArray) -> GdUnitResult:
	if clazz_path.is_empty():
		return GdUnitResult.error("Invalid script path '%s'" % clazz_path)
	var is_inner_class_ := is_inner_class(clazz_path)
	var script :GDScript = load(clazz_path[0])
	var function_descriptors := extract_functions(script, clazz_name, clazz_path)
	var gd_class := GdClassDescriptor.new(clazz_name, is_inner_class_, function_descriptors)
	# iterate over class dependencies
	script = script.get_base_script()
	while script != null:
		clazz_name = GdObjects.extract_class_name_from_class_path([script.resource_path])
		function_descriptors = extract_functions(script, clazz_name, clazz_path)
		gd_class.set_parent_clazz(GdClassDescriptor.new(clazz_name, is_inner_class_, function_descriptors))
		script = script.get_base_script()
	return GdUnitResult.success(gd_class)
