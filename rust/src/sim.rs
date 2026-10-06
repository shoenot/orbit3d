use godot::classes::{INode, Node};
use godot::prelude::*;

use crate::body::Body;
use crate::gravity::g_force;

#[derive(GodotClass)]
#[class(base=Node)]
struct GravitySim {
    bodies: Vec<Body>,
    big_g: f64,
    base: Base<Node>,
}

#[godot_api]
impl INode for GravitySim {
    fn init(base: Base<Node>) -> Self {
        Self {
            bodies: Vec::new(),
            big_g: 6.674e-11_f64,
            base,
        }
    }
}

#[godot_api]
impl GravitySim {
    #[func]
    fn add_body(&mut self, position: Vector3, velocity: Vector3, mass: f64, radius: f64) -> i64 {
        self.bodies.push(Body { id: self.bodies.len(), position, velocity, mass, radius });
        (self.bodies.len() - 1) as i64
    }

    #[func]
    fn set_big_g(&mut self, g: f64) {
        self.big_g = g;
    }

    #[func]
    fn step(&mut self, dt: f32) {
        let mut accelerations = vec![Vector3::ZERO; self.bodies.len()];

        for i in 0..self.bodies.len() {
            let mut resultant_force = Vector3::ZERO;

            for j in 0..self.bodies.len() {
                if i == j { continue; }
                resultant_force += g_force(&self.bodies[i], &self.bodies[j], self.big_g);
            }

            accelerations[i] = resultant_force / self.bodies[i].mass as f32;
        }

        for (body, accel) in self.bodies.iter_mut().zip(accelerations) {
            body.velocity += accel * dt;
            body.position += body.velocity * dt;
        }
    }

    #[func]
    fn get_body_position(&self, id: i64) -> Vector3 {
        self.bodies[id as usize].position
    }

    #[func]
    fn get_body_velocity(&self, id: i64) -> Vector3 {
        self.bodies[id as usize].velocity
    }

    #[func]
    fn get_body_mass(&self, id: i64) -> f64 {
        self.bodies[id as usize].mass
    }

    #[func]
    fn set_body_position(&mut self, id: i64, position: Vector3) {
        self.bodies[id as usize].position = position;
    }

    #[func]
    fn set_body_velocity(&mut self, id: i64, velocity: Vector3) {
        self.bodies[id as usize].velocity = velocity;
    }

    #[func]
    fn set_body_mass(&mut self, id: i64, mass: f64) {
        self.bodies[id as usize].mass = mass;
    }
}

fn get_two_mut<T>(slice: &mut [T], i: usize, j: usize) -> (&mut T, &mut T) {
    assert!(i != j);

    if i < j {
        let (left, right) = slice.split_at_mut(j);
        (&mut left[i], &mut right[0])
    } else {
        let (left, right) = slice.split_at_mut(i);
        (&mut right[0], &mut left[j])
    }
}
