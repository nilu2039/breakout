const std = @import("std");
const breakout = @import("breakout");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    try breakout.run();
}
