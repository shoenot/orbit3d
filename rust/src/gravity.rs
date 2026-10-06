use godot::prelude::*;

use crate::body::Body;

pub fn g_force(b1: &Body, b2: &Body, big_g: f64) -> Vector3 {
    let s = b2.position - b1.position;
    let r_sq = s.length_squared() as f64;
    if r_sq == 0.0 { return Vector3::ZERO }

    s * (big_g * b1.mass * b2.mass / (r_sq * s.length() as f64)) as f32
}
