const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const constants = @import("constants.zig");
const paddle = @import("paddle.zig");
const ball = @import("ball.zig");
const brick = @import("brick.zig");

pub const State = struct {
    game_over: bool,
    ball: ball.Ball,
    paddle: paddle.Paddle,
    bricks: std.AutoHashMap(brick.BrickKey, brick.Brick),

    pub fn init(allocator: std.mem.Allocator) State {
        return State{
            .game_over = false,
            .ball = ball.Ball.init(),
            .paddle = paddle.Paddle.init(),
            .bricks = std.AutoHashMap(brick.BrickKey, brick.Brick).init(allocator),
        };
    }

    pub fn deinit(self: *State) void {
        self.bricks.deinit();
    }

    pub fn reset_state(self: *State) !void {
        self.game_over = false;
        self.ball = ball.Ball.init();
        self.paddle = paddle.Paddle.init();
        try brick.fill_bricks(self);
    }
};

fn game_over(state: *State) !void {
    const text = "Game Over";
    const font_size = 30;
    const text_width: f32 = @floatFromInt(rl.measureText(text, font_size));
    const gap: f32 = 40.0;

    rl.clearBackground(rl.Color.black);
    rl.drawText(text, @intFromFloat(constants.width / 2 - text_width / 2), @intFromFloat(constants.height / 2 - font_size / 2 - gap), font_size, rl.Color.red);

    const pressed = rg.button(rl.Rectangle{ .x = constants.width / 2 - 100 / 2, .y = constants.height / 2 - 50 / 2 + gap, .width = 100, .height = 50 }, "Retry");
    if (pressed) {
        try state.reset_state();
    }
}

pub fn run() !void {
    rl.initWindow(constants.width, constants.height, "Break Out");
    defer rl.closeWindow();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var state = State.init(allocator);
    defer state.deinit();

    try brick.fill_bricks(&state);

    rl.setTargetFPS(constants.target_fps);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        if (state.game_over) {
            try game_over(&state);
            continue;
        }

        brick.render_bricks(&state);

        paddle.render_paddle(state.paddle);
        paddle.update_paddle(&state.paddle);

        ball.render_ball(state.ball);
        ball.update_ball(&state.ball);
        ball.check_ball_collision(&state);

        rl.clearBackground(rl.Color.black);
    }
}
