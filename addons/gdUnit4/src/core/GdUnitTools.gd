extends RefCounted

static func normalize_text(text :String) -> String:
	return text.replace("\r", "");


static func richtext_normalize(input :String) -> String:
	return GdUnitSingleton.instance("regex_richtext", func _regex_richtext() -> RegEx:
		return to_regex("\\[/?(b|color|bgcolor|right|table|cell).*?\\]") )\
	.sub(input, "", true).replace("\r", "")


static func to_regex(pattern :String) -> RegEx:
	var regex := RegEx.new()
	var err := regex.compile(pattern)
	if err != OK:
		push_error("Can't compiling regx '%s'.\n ERROR: %s" % [pattern, error_string(err)])
	return regex


static func prints_verbose(message :String) -> void:
	if OS.is_stdout_verbose():
		prints(message)


static func free_instance(instance :Variant, is_stdout_verbose :=false) -> bool:
	if instance is Array:
		for element in instance:
			free_instance(element)
		instance.clear()
		return true
	# do not free an already freed instance
	if not is_instance_valid(instance):
		return false
	# do not free a class refernece
	if typeof(instance) == TYPE_OBJECT and (instance as Object).is_class("GDScriptNativeClass"):
		return false
	if is_stdout_verbose:
		print_verbose("GdUnit4:gc():free instance ", instance)
	release_double(instance)
	if instance is RefCounted:
		instance.notification(Object.NOTIFICATION_PREDELETE)
		await Engine.get_main_loop().process_frame
		await Engine.get_main_loop().physics_frame
		return true
	else:
		# is instance already freed?
		#if not is_instance_valid(instance) or ClassDB.class_get_property(instance, "new"):
		#	return false
		#release_connections(instance)
		if instance is Timer:
			instance.stop()
			instance.call_deferred("free")
			await Engine.get_main_loop().process_frame
			return true
		if instance is Node and instance.get_parent() != null:
			if is_stdout_verbose:
				print_verbose("GdUnit4:gc():remove node from parent ",  instance.get_parent(), instance)
			instance.get_parent().remove_child(instance)
			instance.set_owner(null)
		instance.free()
		return !is_instance_valid(instance)


static func _release_connections(instance :Object) -> void:
	if is_instance_valid(instance):
		# disconnect from all connected signals to force freeing, otherwise it ends up in orphans
		for connection in instance.get_incoming_connections():
			var signal_ :Signal = connection["signal"]
			var callable_ :Callable = connection["callable"]
			#prints(instance, connection)
			#prints("signal", signal_.get_name(), signal_.get_object())
			#prints("callable", callable_.get_object())
			if instance.has_signal(signal_.get_name()) and instance.is_connected(signal_.get_name(), callable_):
				#prints("disconnect signal", signal_.get_name(), callable_)
				instance.disconnect(signal_.get_name(), callable_)
	release_timers()


static func release_timers() -> void:
	# we go the new way to hold all gdunit timers in group 'GdUnitTimers'
	for node in Engine.get_main_loop().root.get_children():
		if is_instance_valid(node) and node.is_in_group("GdUnitTimers"):
			if is_instance_valid(node):
				Engine.get_main_loop().root.remove_child(node)
				node.stop()
				node.free()


# the finally cleaup unfreed resources and singletons
static func dispose_all() -> void:
	release_timers()
	GdUnitSignals.dispose()
	GdUnitSingleton.dispose()


# if instance an mock or spy we need manually freeing the self reference
static func release_double(instance :Object) -> void:
	if instance.has_method("__release_double"):
		instance.call("__release_double")


static func clear_push_errors() -> void:
	var runner :Node = Engine.get_meta("GdUnitRunner")
	if runner != null:
		runner.clear_push_errors()


static func register_expect_interupted_by_timeout(test_suite :Node, test_case_name :String) -> void:
	var test_case :Node = test_suite.find_child(test_case_name, false, false)
	test_case.expect_to_interupt()
