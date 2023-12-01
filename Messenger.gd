class_name Messenger
extends Node


var _message_listeners := {} # Stores nodes that are listening for messages.
var _message_queue := [] # Stores messages that are being deferred until the next physics process tick.
var _messenger_ready := false # Is set to true once the root node is ready, indicating the messenger is ready to process messages.


func _ready() -> void:
  get_tree().get_root().ready.connect(_on_Root_ready)


# Is called when the root node of the main scene tree emits the ready signal.
func _on_Root_ready() -> void:
  _messenger_ready = true  
  _process_message_queue()


# Invoke all listener callbacks for specified message.
func _process_message_listeners(message: Dictionary) -> void:
  var message_name = message.name
  
  # If there aren't any listeners for this message name, we can return early.
  if not _message_listeners.has(message_name):
    return
  
  # Loop through all listeners of the message and invoke their callback.
  var listeners = _message_listeners[message_name]
  for listener in listeners.values():
    # If the listener no longer exists, remove it from the stored list of listeners.
    if _purge_listener(listeners, listener):
      # Check if there are any remaining listeners, and erase the message_name from listeners if so.
      if not _message_listeners.has(message_name):
        _message_listeners.erase(message_name)
        return
      else:
        continue
    
    # Invoke the callback.
    listener.object.call(listener.method_name, message.data)


# Process all messages in the message queue and reset the queue to an empty array.
func _process_message_queue() -> void:
  for message in _message_queue:
    _process_message_listeners(message)
  
  _message_queue = []


# Removes a listener if it no longer exists, and returns whether the listener was removed.
func _purge_listener(listeners: Dictionary, listener: Dictionary) -> bool:
  var object_exists = !!weakref(listener.object).get_ref() and is_instance_valid(listener.object)
    
  if !object_exists or listener.object.get_instance_id() != listener.object_id:
    listeners.erase(listener.object_id)
    return true

  return false



# Add object as a listener for the specified message.
func add_listener(message_name: String, object: Object, method_name: String) -> void:
  var listener = { 'object': object, 'object_id': object.get_instance_id(), 'method_name': method_name }
  
  if _message_listeners.has(message_name) == false:
    _message_listeners[message_name] = {}
  
  _message_listeners[message_name][object.get_instance_id()] = listener


# Sends a message and triggers _callbacks on its listeners.
func dispatch_message(message_name: String, data := {}) -> void:
  var message = { 'name': message_name, 'data': data }

  if _messenger_ready:
    _process_message_listeners(message)
  else:
    _message_queue.push_back(message)


# Remove object from listening for the specified message.
func remove_listener(message_name: String, object: Object) -> void:
  if not _message_listeners.has(message_name):
    return
  
  if _message_listeners[message_name].has(object.get_instance_id()):
    _message_listeners[message_name].erase(object.get_instance_id())
  
  if _message_listeners[message_name].is_empty():
    _message_listeners.erase(message_name)
