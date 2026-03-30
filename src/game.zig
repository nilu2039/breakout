const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const constants = @import("constants.zig");
const paddle = @import("paddle.zig");
const ball = @import("ball.zig");
const brick = @import("brick.zig");
const particle = @import("particle.zig");

pub const State = struct {
    game_over: bool,
    ball: ball.Ball,
    paddle: paddle.Paddle,
    bricks: std.AutoHashMap(brick.BrickKey, brick.Brick),
    pause_game: bool,
    allocator: std.mem.Allocator,
    particles: std.ArrayList(particle.Particle),

    pub fn init(allocator: std.mem.Allocator) !State {
        return State{
            .game_over = false,
            .ball = ball.Ball.init(),
            .paddle = paddle.Paddle.init(),
            .bricks = std.AutoHashMap(brick.BrickKey, brick.Brick).init(allocator),
            .pause_game = false,
            .allocator = allocator,
            .particles = try std.ArrayList(particle.Particle).initCapacity(allocator, 20),
        };
    }

    pub fn deinit(self: *State) void {
        self.bricks.deinit();
        self.particles.deinit(self.allocator);
    }

    pub fn resetState(self: *State) !void {
        self.game_over = false;
        self.ball = ball.Ball.init();
        self.paddle = paddle.Paddle.init();
        self.pause_game = false;
        try brick.fillBricks(self);
    }

    pub fn displayGameOverScreen(self: *State) !void {
        const text = "Game Over";
        const font_size = 30;
        const text_width: f32 = @floatFromInt(rl.measureText(text, font_size));
        const gap: f32 = 40.0;

        rl.clearBackground(rl.Color.black);
        rl.drawText(
            text,
            @intFromFloat(constants.width / 2 - text_width / 2),
            @intFromFloat(constants.height / 2 - font_size / 2 - gap),
            font_size,
            rl.Color.red,
        );

        const pressed = rg.button(
            rl.Rectangle{
                .x = constants.width / 2 - 100 / 2,
                .y = constants.height / 2 - 50 / 2 + gap,
                .width = 100,
                .height = 50,
            },
            "Retry",
        );
        if (pressed) {
            try self.resetState();
        }
    }

    pub fn displayPauseGameScreen(_: *State) void {
        rl.clearBackground(rl.Color.black);
        const text = "Game paused";
        const font_size = 20;
        const text_width: f32 =
            @floatFromInt(rl.measureText(text, font_size));
        rl.drawText(
            text,
            @intFromFloat(constants.width / 2 - text_width / 2),
            @intFromFloat(constants.height / 2 - font_size / 2),
            font_size,
            rl.Color.red,
        );
    }

    pub fn handleKeyPress(self: *State) void {
        if (rl.isKeyPressed(rl.KeyboardKey.p)) {
            self.pause_game = !self.pause_game;
        }
    }
};

pub fn run(state: *State) !void {
    rl.initWindow(constants.width, constants.height, "Break Out");
    defer rl.closeWindow();

    rl.setTargetFPS(constants.target_fps);

    try brick.fillBricks(state);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        state.handleKeyPress();

        if (state.pause_game) {
            state.displayPauseGameScreen();
            continue;
        }

        if (state.game_over) {
            try state.displayGameOverScreen();
            continue;
        }

        brick.renderBricks(state);

        paddle.renderPaddle(state);
        paddle.updatePaddle(state);

        ball.renderBall(state);
        ball.updateBall(state);
        try ball.checkBallCollision(state);

        particle.renderParticles(state);
        particle.updateParticles(state);
    }
}
