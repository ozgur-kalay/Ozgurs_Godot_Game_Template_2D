extends TabContainer
#
#var current_tab_index: int = 0
#var pending_tab_index: int = -1
#
#@onready var apply_changes_dialog: ConfirmationDialog = $ConfirmationDialog
#
#func _ready() -> void:
	#current_tab_index = current_tab
	#tab_changed.connect(_on_tab_changed)
	#apply_changes_dialog.confirmed.connect(_on_confirmed)
#
#func _on_tab_changed(new_tab: int) -> void:
	## Prevent recursive call
	#if pending_tab_index != -1:
		#return
#
	#pending_tab_index = new_tab
#
	## Revert immediately
	#set_current_tab(current_tab_index)
#
	#apply_changes_dialog.popup_centered()
#
#
#func _on_confirmed() -> void:
	#current_tab_index = pending_tab_index
	#set_current_tab(current_tab_index)
	#pending_tab_index = -1
