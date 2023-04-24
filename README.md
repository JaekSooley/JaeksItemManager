# Item Manager
Just a slightly more user-friendly way to manage a single .json file containing all items in a game.

# Features
- Add .json files to the "addons/itemmanager/data/item_templates" folder to define the default keys/values for new items.
- Multiple template files can be added, which will all appear in the Items drop down menu.
- Uses the "unique_id" key to sort/search items, and will not allow items with duplicate unique IDs.
- Will add a "unique_id" key to items if not specified in the template.
- Add new keys to items by updating the template file and using *File* > Sync *Templates* to add missing keys to all items created from each template.
- Use the search bar to easily items in the database.
- All items are stored in the "addons/itemmanager/data/item_database.json" file.
- Automatically adds an "item_manage_template" key to all items to track which template they were created from.
