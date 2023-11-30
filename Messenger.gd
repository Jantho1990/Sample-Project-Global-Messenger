extends Node

class_name Messenger

var _message_listeners := {}
var _message_queue := []
var _messenger_ready := false

func _ready() -> void:
#	get_tree().get_root().connect('ready', Callable(self, '_on_Root_ready'))
	get_tree().get_root().connect('ready', _on_Root_ready)


# Is called when the root node of the main scene tree emits the ready signal.
func _on_Root_ready() -> void:
	_process_message_queue()


# Process all messages in the message queue and reset the queue to an empty array.
func _process_message_queue() -> void:
	for message in _message_queue:
		_process_message_listeners(message)

	_message_queue = []

# Add object as a listener for the specified message.
func add_listener(message_name: String, object: Object, method_name: String) -> void:
	var listener = { 'object': object, 'object_id': object.get_instance_id(), 'method_name': method_name }

	if _message_listeners.has(message_name) == false:
		_message_listeners[message_name] = {}
		_message_listeners[message_name][object.get_instance_id()] = listener

# Remove object from listening for the specified message.
func remove_listner(message_name: String, object: Object) -> void:
	if not _message_listeners.has(message_name):
		return

	if _message_listeners[message_name].has(object.get_instance_id()):
		_message_listeners[message_name].erase()

	if _message_listeners[message_name].is_empty():
		_message_listeners.erase(message_name)

# Sends a message and triggers _callbacks on its listeners.
func dispatch_message(message_name: String, data := {}) -> void:
	var message = { 'name': message_name, 'data': data }

	if _messenger_ready:
		_process_message_listeners(message)
	else:
		_message_queue.push_back(message)

# Invoke all listener callbacks for specified message.
func _process_message_listeners(message: Dictionary) -> void:
	var message_name = message.name

	if not _message_listeners.has(message_name):
		return

	var listeners = _message_listeners[message_name]

	for listener in listeners.values():
		# If the listener has been freed, remove it
		if _purge_listener(listeners, listener):
		# Check if there are any remaining listeners, and erase the message_name from listeners if so.
			if not _message_listeners.has(message_name):
				_message_listeners.erase(message_name)
				return
			else:
				continue

		listener.object.call(listener.method_name, message.data)

# Removes a listener if it no longer exists, and returns whether the listener was removed.
func _purge_listener(listeners: Dictionary, listener: Dictionary) -> bool:
	var object_exists = !!weakref(listener.object).get_ref() and is_instance_valid(listener.object)

	if !object_exists or listener.object.get_instance_id() != listener.object_id:
		listeners.erase(listener.object_id)
		return true

	return false
