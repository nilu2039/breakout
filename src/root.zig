const std = @import("std");
const rl = @import("raylib");

const width = 1280;
const height = 720;

pub fn run() !void {
    rl.initWindow(width, height, "Break Out");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
    }
}
