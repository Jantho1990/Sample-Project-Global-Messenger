# Creates a global messenger that can be accessed from anywhere in the program.
extends Messenger


func _ready() -> void:
  set_physics_process(false)


func _physics_process(_delta) -> void:
  ._process_message_queue()
  set_physics_process(false) # We don't need to keep updating once messages are processed.


# Queues a message to be dispatched on the next physics processing tick.
func dispatch_message_deferred(message_name: String, data := {}) -> void:
  _message_queue.push_back({ 'name': message_name, 'data': data })
  
  set_physics_process(true)
