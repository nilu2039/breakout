const rl = @import("raylib");
const constants = @import("constants.zig");
const root = @import("root.zig");

pub const Brick = struct {
    x: f32,
    y: f32,
    color: rl.Color,

    pub fn init() Brick {
        return Brick{ .x = 0, .y = 0, .color = rl.Color.black };
    }
};

pub fn append_brick(state: *root.State, brick: Brick) !void {
    try state.bricks.append(state.brick_allocator, brick);
}

pub fn render_bricks(state: *root.State) void {
    for (state.bricks.items) |brick| {
        const rect = rl.Rectangle{ .x = brick.x, .y = brick.y, .width = constants.brick_width, .height = constants.brick_height };
        rl.drawRectangleRec(rect, brick.color);
    }
}
