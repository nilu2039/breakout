const std = @import("std");
const rl = @import("raylib");

const target_fps = 60;
const width = 1280;
const height = 720;

const paddle_width = 150;
const paddle_height = 20;
const paddle_color = rl.Color.sky_blue;
const paddle_speed = 400;

const ball_radius = 20;
const ball_color = rl.Color.red;
const ball_speed = 400;

const Ball = struct {
    x: f32,
    y: f32,
    dx: f32,
    dy: f32,
};

const Paddle = struct {
    x: f32,
    dx: f32,
};

const State = struct {
    game_over: bool,
    ball: Ball,
    paddle: Paddle,
};

fn render_paddle(paddle: Paddle) void {
    const rect = rl.Rectangle{ .width = paddle_width, .height = paddle_height, .x = paddle.x, .y = height - paddle_height };
    rl.drawRectangleRec(rect, paddle_color);
}

fn update_paddle(paddle: *Paddle) void {
    const delta = rl.getFrameTime();

    paddle.dx = 0;

    if (rl.isKeyDown(rl.KeyboardKey.left)) {
        paddle.dx = -1;
    }

    if (rl.isKeyDown(rl.KeyboardKey.right)) {
        paddle.dx = 1;
    }

    paddle.x += paddle.dx * paddle_speed * delta;
    paddle.x = std.math.clamp(paddle.x, 0, width - paddle_width);
}

fn render_ball(ball: Ball) void {
    const center = rl.Vector2{ .x = ball.x, .y = ball.y };
    rl.drawCircleV(center, ball_radius, ball_color);
}

fn update_ball(ball: *Ball) void {
    const delta = rl.getFrameTime();

    ball.x += ball.dx * ball_speed * delta;
    ball.y += ball.dy * ball_speed * delta;

    // Left / Right walls
    if (ball.x < ball_radius) {
        ball.x = ball_radius;
        ball.dx *= -1;
    } else if (ball.x > width - ball_radius) {
        ball.x = width - ball_radius;
        ball.dx *= -1;
    }

    // Top / Bottom walls
    if (ball.y < ball_radius) {
        ball.y = ball_radius;
        ball.dy *= -1;
    } else if (ball.y > height - ball_radius) {
        ball.y = height - ball_radius;
        ball.dy *= -1;
    }
}

pub fn run() !void {
    rl.initWindow(width, height, "Break Out");
    defer rl.closeWindow();

    var state = State{
        .ball = Ball{ .x = width / 2, .y = height / 2, .dx = 1, .dy = 1 },
        .paddle = Paddle{ .x = width / 2 - paddle_width / 2, .dx = 1.0 },
        .game_over = false,
    };

    rl.setTargetFPS(target_fps);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        render_paddle(state.paddle);
        update_paddle(&state.paddle);

        render_ball(state.ball);
        update_ball(&state.ball);

        rl.clearBackground(rl.Color.black);
    }
}
