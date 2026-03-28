const std = @import("std");
const breakout = @import("breakout");

pub fn main() !void {
    try breakout.run();
}
