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
    bricks: std.ArrayList(brick.Brick),
    brick_allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !State {
        return State{
            .game_over = false,
            .ball = ball.Ball.init(),
            .paddle = paddle.Paddle.init(),
            .bricks = try std.ArrayList(brick.Brick).initCapacity(allocator, 20),
            .brick_allocator = allocator,
        };
    }

    pub fn deinit(self: *State) void {
        self.bricks.deinit(self.brick_allocator);
    }
};

pub fn run() !void {
    rl.initWindow(constants.width, constants.height, "Break Out");
    defer rl.closeWindow();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var state = try State.init(allocator);
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
            const _brick = brick.Brick{ .x = @floatFromInt(x * constants.brick_width), .y = @floatFromInt(y * constants.brick_height), .color = color };
            try brick.append_brick(&state, _brick);
        }
    }

    rl.setTargetFPS(constants.target_fps);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        if (state.game_over) {
            // rl.clearBackground(rl.Color.sky_blue);
            // continue;
        }

        brick.render_bricks(&state);

        for (0..constants.brick_num_col) |x| {
            if (x != 0) {
                const fx = @as(f32, @floatFromInt(x)) * constants.brick_width;
                const px = @as(i32, @intFromFloat(fx));

                rl.drawLine(px, 0, px, constants.height, rl.Color.black);
            }
        }

        paddle.render_paddle(state.paddle);
        paddle.update_paddle(&state.paddle);

        ball.render_ball(state.ball);
        ball.update_ball(&state.ball);
        ball.check_ball_collision(&state);

        rl.clearBackground(rl.Color.black);
    }
}
