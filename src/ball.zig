const rl = @import("raylib");
const std = @import("std");
const constants = @import("constants.zig");
const root = @import("root.zig");
const brick = @import("brick.zig");
const particles = @import("particle.zig");

pub const Ball = struct {
    x: f32,
    y: f32,
    dx: f32,
    dy: f32,

    pub fn init() Ball {
        return Ball{ .x = constants.width / 2, .y = constants.height / 2, .dx = 1, .dy = 1 };
    }
};

pub fn render_ball(ball: Ball) void {
    const center = rl.Vector2{ .x = ball.x, .y = ball.y };
    rl.drawCircleV(center, constants.ball_radius, constants.ball_color);
}

pub fn update_ball(ball: *Ball) void {
    const dt = rl.getFrameTime();

    ball.x += ball.dx * constants.ball_speed * dt;
    ball.y += ball.dy * constants.ball_speed * dt;

    // Left / Right walls
    if (ball.x < constants.ball_radius) {
        ball.x = constants.ball_radius;
        ball.dx *= -1;
    } else if (ball.x > constants.width - constants.ball_radius) {
        ball.x = constants.width - constants.ball_radius;
        ball.dx *= -1;
    }

    // Top / Bottom walls
    if (ball.y < constants.ball_radius) {
        ball.y = constants.ball_radius;
        ball.dy *= -1;
    } else if (ball.y > constants.height - constants.ball_radius) {
        ball.y = constants.height - constants.ball_radius;
        ball.dy *= -1;
    }
}

pub fn check_ball_collision(state: *root.State) !void {
    const ball = &state.ball;
    const ball_center = rl.Vector2{ .x = ball.x, .y = ball.y };

    const _paddle = state.paddle;

    var bricks_it = state.bricks.iterator();
    var remove_key: ?brick.BrickKey = null;

    while (bricks_it.next()) |brick_entry| {
        const brick_val = brick_entry.value_ptr;
        const collision = rl.checkCollisionCircleRec(ball_center, constants.ball_radius, rl.Rectangle{ .x = brick_val.x, .y = brick_val.y, .width = constants.brick_width, .height = constants.brick_height });

        if (collision) {
            const closest_x = std.math.clamp(ball_center.x, brick_val.x, brick_val.x + constants.brick_width);
            const closest_y = std.math.clamp(ball_center.y, brick_val.y, brick_val.y + constants.brick_height);

            const dx = ball_center.x - closest_x;
            const dy = ball_center.y - closest_y;

            if (@abs(dx) > @abs(dy)) {
                ball.*.dx *= -1;
            } else {
                ball.*.dy *= -1;
            }

            remove_key = brick.BrickKey{ .x = @intFromFloat(brick_val.x), .y = @intFromFloat(brick_val.y) };
            try particles.spawn_particles(state, rl.Vector2{ .x = brick_val.x, .y = brick_val.y });

            break;
        }
    }

    if (remove_key) |key| {
        _ = state.bricks.remove(key);
    }

    if (rl.checkCollisionCircleRec(ball_center, constants.ball_radius, rl.Rectangle{ .x = _paddle.x, .y = _paddle.y, .width = constants.paddle_width, .height = constants.paddle_height })) {
        ball.*.y = constants.height - constants.ball_radius - constants.paddle_height;
        ball.*.dy *= -1;
    }

    if (ball.y == constants.height - constants.ball_radius) {
        state.game_over = true;
    }
}
