extends Node

@onready var localMessenger = $"../LocalMessenger"

func _ready() -> void:
  GlobalMessenger.dispatch_message('test_1', { 'fish': 'shark' })
  localMessenger.add_listener('test_local', self, '_on_Test_local')

func _on_Test_local(data) -> void:
  print('Do you like looking at the ', data.animal, '?')
