extends Node2D
## 主菜单场景脚本 - 游戏入口

func _ready() -> void:
	print("主菜单加载完成 - 请点击 [开始游戏]")
	# 短暂延迟后检查按钮状态
	await get_tree().process_frame
	var btn := get_node_or_null("UICanvas/StartButton")
	if btn:
		print("StartButton 就绪: disabled=", btn.disabled, " visible=", btn.visible)
	else:
		push_error("StartButton 未找到!")


func _on_start_pressed() -> void:
	print(">>> 开始游戏按钮被点击!")
	get_tree().change_scene_to_file("res://scenes/shelter/ShelterMain.tscn")
