use godot::prelude::Vector3;

pub struct Body {
    pub id: usize,
    pub position: Vector3,
    pub velocity: Vector3,
    pub mass: f64,
    pub radius: f64,
}
