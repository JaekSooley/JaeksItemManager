@tool
class_name ItemManager
extends Control

var im_print = "ItemManager: "

# Hold all items in this dictionary, export to item_database.json when saving.
var items = {}
var item_list = [] # Used to display items keys in ItemList control
var current_item = {
	"name" : "",
	"index" : -1,
	"out_of_date" : false,
}
var database_out_of_date = false
var unique_id_key = "unique_id"
var unique_id_key_default_value = "id"
var template_key = "item_manager_template"
var item_database_path = "res://addons/itemmanager/data/item_database.json"
var default_item_path = "res://addons/itemmanager/data/item_templates/"
var item_templates = []


# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = DirAccess.open(default_item_path)
	if dir:
		var flist = dir.get_files()
		$VBoxContainer/HBoxContainer/ItemListContainer/HBoxContainer/MenuBar/Items.clear()
		item_templates.clear()
		for f in flist:
			var option_name = str("New ", f.get_basename())
			item_templates.append(str(dir.get_current_dir(), "/", f))
			$VBoxContainer/HBoxContainer/ItemListContainer/HBoxContainer/MenuBar/Items.add_item(option_name)
			print(im_print, "Found item template \"", dir.get_current_dir(), "/", f, "\"")
	else:
		print("An error occurred when trying to access the path.")
	read_database()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func new_item(fname):
	if FileAccess.file_exists(fname):
		var file_string = FileAccess.get_file_as_string(fname)
		var json_data = JSON.parse_string(file_string)
		if json_data:
			var temp_item = json_data
			if !temp_item.has(unique_id_key):
				temp_item[unique_id_key] = unique_id_key_default_value
			var new_id = str(temp_item[unique_id_key], "_", items.size() + 1)
			items[new_id] = json_data
			items[new_id][unique_id_key] = new_id
			items[new_id][template_key] = fname
			item_list.append(new_id)
			update_item_list("", false)
			set_item_out_of_date(false)
			set_database_out_of_date(true)
			select_item(item_list.find(new_id))
			print(im_print, "New item created \"", new_id, "\"")
		else:
			printerr(im_print, "Invalid JSON \"", fname, "\"!")
	else:
		print(im_print, "Invalid file \"", fname, "\"")


func remove_item(key):
	items.erase(key)
	item_list.erase(key)
	set_database_out_of_date(true)


func update_item_list(search_string = "", sort = true):
	$VBoxContainer/HBoxContainer/ItemListContainer/ItemList.clear()
	if sort: 
		item_list.sort()
	for i in item_list:
		if search_string != "":
			if i.contains(search_string):
				$VBoxContainer/HBoxContainer/ItemListContainer/ItemList.add_item(i)
		else:
			$VBoxContainer/HBoxContainer/ItemListContainer/ItemList.add_item(i)


func item_editor_load_item():
	$VBoxContainer/HBoxContainer/ItemEditorContainer/EditorHBox/ItemEditor.text = JSON.stringify(items[current_item["name"]], "\t", false)
	set_item_out_of_date(false)


func item_editor_clear():
	$VBoxContainer/HBoxContainer/ItemEditorContainer/EditorHBox/ItemEditor.text = ""
	current_item["index"] = -1
	current_item["name"] = ""
	set_item_out_of_date(false)


func write_database():
	if FileAccess.file_exists(item_database_path):
		var json_string = JSON.stringify(items, "\t", false)
		var file = FileAccess.open(item_database_path, FileAccess.WRITE)
		file.store_string(json_string)
		print(im_print, "Saved changes to \"", item_database_path, "\"")
		set_database_out_of_date(false)
	else:
		printerr(im_print, "Database \"", item_database_path,"\" not found!")


func read_database():
	if FileAccess.file_exists(item_database_path):
		items.clear()
		item_list.clear()
		var file_string = FileAccess.get_file_as_string(item_database_path)
		var json_data = JSON.parse_string(file_string)
		if json_data:
			items = json_data
			for i in items:
				item_list.append(items[i][unique_id_key])
			$VBoxContainer/HBoxContainer/ItemListContainer/HBoxContainer/ItemSearch.text = ""
			update_item_list()
			set_database_out_of_date(false)
			item_editor_clear()
			$VBoxContainer/HBoxContainer/ItemListContainer/ItemList.grab_focus()
			print(im_print, "Loaded database from \"", item_database_path, "\"")


func clear_database():
	if FileAccess.file_exists(item_database_path):
		items.clear()
		$VBoxContainer/HBoxContainer/ItemListContainer/ItemList.clear()
		item_editor_clear()
		var json_string = JSON.stringify(items, "\t", false)
		var file = FileAccess.open(item_database_path, FileAccess.WRITE)
		file.store_string(json_string)
		printerr(im_print, "Cleared Database \"", item_database_path, "\"!")
		set_database_out_of_date(false)
	else:
		printerr(im_print, "Database file not found!")


func select_item(index):
	current_item["index"] = index
	current_item["name"] = $VBoxContainer/HBoxContainer/ItemListContainer/ItemList.get_item_text(index)
	$VBoxContainer/HBoxContainer/ItemEditorContainer/EditorHBox/ItemEditor.grab_focus()
	item_editor_load_item()


func set_database_out_of_date(state):
	if state:
		if !database_out_of_date: printerr(im_print, "Database out of date. Go to File > Save Database to write changes to file.")
		database_out_of_date = true
	else:
		if database_out_of_date: print(im_print, "Database is up to date")
		database_out_of_date = false


func set_item_out_of_date(state):
	if state:
		if !current_item["out_of_date"]: print(im_print, "\"", current_item["name"], "\" is out of date")
		current_item["out_of_date"] = true
	else:
		if current_item["out_of_date"]: print(im_print, "\"", current_item["name"], "\" is up to date")
		current_item["out_of_date"] = false


func sync_items():
	print(im_print, "Adding missing keys to items...")
	for template in item_templates:
		if FileAccess.file_exists(template):
			var file_string = FileAccess.get_file_as_string(template)
			var template_data = JSON.parse_string(file_string)
			if template_data:
				print("\tloaded \"", template,"\"")
				for item_key in items.keys():
					if items[item_key][template_key] == template:
						print("\t\tchecking ", item_key, "...")
						for key in template_data:
							if !items[item_key].has(key):
								items[item_key][key] = template_data[key]
			else:
				printerr(im_print, "Invalid JSON \"", template, "\"!")
		else:
			printerr(im_print, "Template \"", template, "\" no longer exists!")


func _on_items_index_pressed(index):
	if index < item_templates.size():
		new_item(item_templates[index])


func _on_database_index_pressed(index):
	match index:
		0:
			# Sorts the list of items
			item_list.sort()
			update_item_list()
		1:
			# Adds missing keys from templates to items using that template.
			sync_items()
		3:
			# Save database to file
			write_database()
		4:
			# Load database from file, overwriting anything currently in editor
			read_database()


func _on_button_save_pressed():
	var json_data = JSON.parse_string($VBoxContainer/HBoxContainer/ItemEditorContainer/EditorHBox/ItemEditor.text)
	if json_data:
		var item_already_exists = false
		
		for i in item_list:
			if i == json_data[unique_id_key]:
				if item_list.find(i) != current_item["index"]:
					item_already_exists = true
		
		if !item_already_exists:
			# Check if all keys are found in the template
			if FileAccess.file_exists(json_data[template_key]):
				var file_string = FileAccess.get_file_as_string(json_data[template_key])
				var template_data = JSON.parse_string(file_string)
				if template_data:
					for key in json_data.keys():
						if !template_data.has(key) && key != template_key:
							printerr(im_print, "Unrecognised key \"", key, "\" found in \"", json_data[unique_id_key], "\"")
				else:
					printerr(im_print, "Invalid JSON in \"", json_data[unique_id_key], "\"!")
			else:
				printerr(im_print, "Template \"", json_data[template_key], "\" no longer exists!")
			# Save the item
			items.erase(current_item["name"])
			items[json_data[unique_id_key]] = json_data
			item_list[current_item["index"]] = json_data[unique_id_key]
			print(im_print, "\"", current_item["name"], "\" updated to \"", json_data[unique_id_key], "\"!")
			current_item["name"] = json_data[unique_id_key]
			set_item_out_of_date(false)
			set_database_out_of_date(true)
			update_item_list("", false)
		else:
			printerr(im_print, "\"", json_data[unique_id_key], "\" is not a unique ID!")
	else:
		printerr(im_print, "Invalid item JSON!")


func _on_button_reset_pressed():
	item_editor_load_item()


func _on_button_delete_pressed():
	if current_item["index"] != -1:
		items.erase(current_item["name"])
		item_list.remove_at(current_item["index"])
		current_item["name"] = ""
		current_item["index"] = -1
		set_database_out_of_date(true)
		update_item_list()
		item_editor_clear()


func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	select_item(index)


func _on_item_editor_text_changed():
	set_item_out_of_date(true)


func _on_item_search_text_changed(new_text):
	update_item_list(new_text)


func _on_button_copy_pressed():
	var json_data = JSON.parse_string($VBoxContainer/HBoxContainer/ItemEditorContainer/EditorHBox/ItemEditor.text)
	if json_data:
		var item_already_exists = false
		
		if json_data[unique_id_key] in items.keys():
			json_data[unique_id_key] = str(json_data[unique_id_key], "_", item_list.size() + 1)
		
		for i in item_list:
			if i == json_data[unique_id_key]:
				if item_list.find(i) != current_item["index"]:
					item_already_exists = true
		if !item_already_exists:
			items[json_data[unique_id_key]] = json_data
			item_list.append(json_data[unique_id_key])
			print(im_print, "\"", current_item["name"], "\" updated to \"", json_data[unique_id_key], "\"!")
			current_item["name"] = json_data[unique_id_key]
			set_item_out_of_date(false)
			set_database_out_of_date(true)
			update_item_list("", false)
			item_editor_clear()
		else:
			printerr(im_print, "\"", json_data[unique_id_key], "\" is not a unique ID!")
	else:
		printerr(im_print, "Invalid item JSON!")

