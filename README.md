# Godot Cpp Wizard for Godot 4.x+
This plugin aims to replicate the UX of developping in Unreal with Cpp.
This is very experimental and will scale with time, for now I just aim to add basic things such as adding a GDExtension module and classes

The project contains on the `main` branch the entire project environment and the plugin itself, another branch `release` will contain the addons only and you can still download the plugin only in the release section.

# Installation

## Requirements
- A Godot 4.x minimum
- Python installed
- Scons installed
- A C++ compiler (MSVC, Clang)

## Install the plugin
## Create a new Godot project
Download latest version of the plugin and extract it in `res://addons/` of your godot project. If it do not exist create it!
go in Project Settings > Plugins and activate the plugin

## .gitignore
Add this to your project's root `.gitignore`:

   modules/*/.sconsign.dblite
   modules/*/src/*.obj
   modules/*/src/*.o
   bin/*.dll
   bin/*.lib
   bin/*.pdb
   bin/*.exp
   bin/*.so
   bin/*.dylib
   addons/gdext_wizard/wizard_state.cfg
   .godot/
   compile_commands.json

## Create your first module
Go to `Tools > C++ > Create Module`, name your module
You should get some error such as:
  ERROR: platform/windows/os_windows.cpp:483 - Condition "!FileAccess::exists(path)" is true. Returning: ERR_FILE_NOT_FOUND
  ERROR: GDExtension dynamic library not found: 'res://bin/core.gdextension'.
This is normal, you have to compile the module in order to fix this error, then go to `Tools > C++ > Recompile all modules`
your godot window should freeze, this is normal: Scons is recompiling and placing the binaries in `res://bin`.
>[!warning] The first compilation can be much slower
> Do not close Godot in case the windows is freezing.

If there is no error godot should restart automatically.
Since there you can create any new class you want.

# Using the plugin
All the feature are available in the toolbar `Tools > C++`
## Feature
- Create modules
- Open modules folder
- Recompile all Module
- Add new C++ class in the desired module
- Remove existing C++ class in the desired module

Recompile all module when you want to apply your modification in Godot.

## Advanced infos
By default the plugin has the godot-cpp header files in the plugin directly, there is no way to specify a custom path for now this is a known limitation.

## Removing a Module
Unlike adding or removing classes, module removal is intentionally **not** exposed as a menu action in the plugin. Deleting a module means deleting compiled binaries that Windows may have locked while the editor had them loaded, so doing it by hand (with the editor closed) is actually simpler and safer than automating it through the UI.

To remove a module:

1. **Close the Godot editor.** This releases any lock on the module's compiled `.dll`/`.lib`/`.pdb` files.
2. **Delete the module's source folder**: `modules/<ModuleName>/` (e.g. `modules/DialogueSystem/`).
3. **Delete the module's build output** in `res://bin/`:
   - `<snake_name>.gdextension`
   - Any file starting with `lib<snake_name>.` (e.g. `libdialogue_system.windows.template_debug.x86_64.dll`, `.lib`, `.pdb`)

Reopen the editor — the module will no longer be detected. If it was set as the current module, `addons/gdext_wizard/wizard_state.cfg` may still reference its name; this is harmless and purely cosmetic (attempting to recompile it will simply fail with a clear "no metadata for module" error). You can optionally clear the `current_module` value in that file by hand if you'd like a clean state.
