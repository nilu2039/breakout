const std = @import("std");
const rl = @import("raylib");
const game = @import("game.zig");
const constants = @import("constants.zig");

pub const Paddle = struct {
    x: f32,
    y: f32,
    dx: f32,

    pub fn init() Paddle {
        return Paddle{
            .x = constants.width / 2 - constants.paddle_width / 2,
            .y = constants.height - constants.paddle_height,
            .dx = 1.0,
        };
    }
};

pub fn renderPaddle(state: *game.State) void {
    const paddle = state.paddle;
    const rect = rl.Rectangle{
        .width = constants.paddle_width,
        .height = constants.paddle_height,
        .x = paddle.x,
        .y = paddle.y,
    };
    rl.drawRectangleRec(rect, constants.paddle_color);
}

pub fn updatePaddle(state: *game.State) void {
    const paddle = &state.paddle;

    const dt = rl.getFrameTime();

    paddle.dx = 0;

    if (rl.isKeyDown(rl.KeyboardKey.left)) {
        paddle.dx = -1;
    }

    if (rl.isKeyDown(rl.KeyboardKey.right)) {
        paddle.dx = 1;
    }

    paddle.x += paddle.dx * constants.paddle_speed * dt;
    paddle.x = std.math.clamp(paddle.x, 0, constants.width - constants.paddle_width);
}
