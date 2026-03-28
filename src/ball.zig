const rl = @import("raylib");
const constants = @import("constants.zig");
const root = @import("root.zig");

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

pub fn check_ball_collision(state: *root.State) void {
    const ball = &state.ball;
    const _paddle = state.paddle;

    if (rl.checkCollisionCircleRec(rl.Vector2{ .x = ball.x, .y = ball.y }, constants.ball_radius, rl.Rectangle{ .x = _paddle.x, .y = _paddle.y, .width = constants.paddle_width, .height = constants.paddle_height })) {
        ball.*.y = constants.height - constants.ball_radius - constants.paddle_height;
        ball.*.dy *= -1;
    }

    if (ball.y == constants.height - constants.ball_radius) {
        state.game_over = true;
    }
}
