const rl = @import("raylib");

pub const target_fps = 60;

pub const width = brick_num_col * brick_width + (brick_num_col - 1) * brick_gap;
pub const height = brick_num_row * brick_height + 600;

pub const brick_num_col = 14;
pub const brick_num_row = 8;
pub const brick_width = 60;
pub const brick_height = 10;
pub const brick_gap = 10;
pub const brick_shatter_particle_number = 20;

pub const paddle_width = 100;
pub const paddle_height = 10;
pub const paddle_color = rl.Color.sky_blue;
pub const paddle_speed = 600;

pub const ball_radius = 15;
pub const ball_color = rl.Color.red;
pub const ball_speed = 300;

pub const particle_size = 3;
