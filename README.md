# Jaek's Item Manager for Godot 4
Just a slightly more user-friendly way to manage a single .json file containing all items in a game.

![image](https://user-images.githubusercontent.com/117260365/234283366-530b2090-6fd5-45f0-9d81-9a35ac55b7e1.png)

## Features
- Add .json files to the "addons/itemmanager/data/item_templates" folder to define the default keys/values for new items.
- Multiple template files can be added, which will all appear in the Items drop down menu.
- Use *File > Rescan Templates Folder* when new template files are added (instead of reloading the plugin).
- Uses the "unique_id" key to sort/search items, and will not allow items with duplicate unique IDs.
- Will add a "unique_id" key to items if not specified in the template.
- Add/remove keys in an item by updating the .JSON template and using *File* > *Sync Templates* to apply changes to all items created from that template.
- Use the search bar to easily find items in the database.
- All items are stored in the "addons/itemmanager/data/item_database.json" file.
- Automatically adds an "item_manager_template" key to all items to track which template they were created from.
- Now remembers settings when closed.

## Note:
- All this does is manage a .JSON database, you'll have to work out loading the database into your game yourself.