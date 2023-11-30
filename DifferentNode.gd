extends Node

@onready var localMessenger = $"../LocalMessenger"

func _ready() -> void:
  GlobalMessenger.add_listener('test_1', self, '_on_Test_1')
  localMessenger.dispatch_message('test_local', { 'animal': 'rabbit' })


func _on_Test_1(_data) -> void:
  print('Test 1 received')
