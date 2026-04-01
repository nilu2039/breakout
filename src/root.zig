const std = @import("std");
const game = @import("game.zig");
const builtin = @import("builtin");

pub fn run() !void {
    const is_wasm = builtin.target.isWasiLibC() or builtin.target.os.tag == .emscripten;

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = undefined;

    const allocator = blk: {
        if (is_wasm) {
            break :blk std.heap.c_allocator;
        } else {
            gpa = std.heap.GeneralPurposeAllocator(.{}){};
            break :blk gpa.allocator();
        }
    };

    defer {
        if (!is_wasm) _ = gpa.deinit();
    }

    var state = try game.State.init(allocator);
    defer state.deinit();

    try game.run(&state);
}
