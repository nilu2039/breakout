const std = @import("std");
const game = @import("game.zig");

pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var state = try game.State.init(allocator);
    defer state.deinit();

    try game.run(&state);
}
