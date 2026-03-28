const rl = @import("raylib");
const constants = @import("constants.zig");
const root = @import("root.zig");

pub const BrickKey = struct {
    x: i32,
    y: i32,
};

pub const Brick = struct {
    x: f32,
    y: f32,
    color: rl.Color,

    pub fn init() Brick {
        return Brick{ .x = 0, .y = 0, .color = rl.Color.black };
    }
};

pub fn append_brick(state: *root.State, brick: Brick) !void {
    try state.bricks.put(BrickKey{ .x = @intFromFloat(brick.x), .y = @intFromFloat(brick.y) }, brick);
}

pub fn render_bricks(state: *root.State) void {
    var it = state.bricks.iterator();

    while (it.next()) |brick| {
        const brick_val = brick.value_ptr;
        const rect = rl.Rectangle{ .x = brick_val.x, .y = brick_val.y, .width = constants.brick_width, .height = constants.brick_height };
        rl.drawRectangleRec(rect, brick_val.color);
    }
}
