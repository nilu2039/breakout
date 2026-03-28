const std = @import("std");
const rl = @import("raylib");
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
};

pub fn run() !void {
    rl.initWindow(constants.width, constants.height, "Break Out");
    defer rl.closeWindow();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var state = State.init(allocator);
    defer state.deinit();

    for (0..constants.brick_num_row) |y| {
        for (0..constants.brick_num_col) |x| {
            var color: rl.Color = undefined;
            switch (y) {
                0, 1 => {
                    color = rl.Color.red;
                },
                2, 3 => {
                    color = rl.Color.brown;
                },
                4, 5 => {
                    color = rl.Color.green;
                },
                6, 7 => {
                    color = rl.Color.yellow;
                },
                else => {
                    color = rl.Color.black;
                },
            }

            var _x: f32 = undefined;
            var _y: f32 = undefined;

            _x = @floatFromInt(x * constants.brick_width);
            _y = @floatFromInt(y * constants.brick_height);

            if (x != 0) {
                _x = @floatFromInt(x * constants.brick_width + constants.brick_gap * x);
            }

            if (y != 0) {
                _y = @floatFromInt(y * constants.brick_height + constants.brick_gap * y);
            }

            const _brick = brick.Brick{ .x = _x, .y = _y, .color = color };
            try brick.append_brick(&state, _brick);
        }
    }

    rl.setTargetFPS(constants.target_fps);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        if (state.game_over) {
            rl.clearBackground(rl.Color.sky_blue);
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
