use godot::prelude::*;

mod sim;
mod body;
mod gravity;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}
