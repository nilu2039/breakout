const rl = @import("raylib");
const constants = @import("constants.zig");
const root = @import("root.zig");
const brick = @import("brick.zig");

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

pub fn fill_bricks(state: *root.State) !void {
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
            try brick.append_brick(state, _brick);
        }
    }
}
pub fn append_brick(state: *root.State, _brick: Brick) !void {
    try state.bricks.put(BrickKey{ .x = @intFromFloat(_brick.x), .y = @intFromFloat(_brick.y) }, _brick);
}

pub fn render_bricks(state: *root.State) void {
    var it = state.bricks.iterator();

    while (it.next()) |brick_entry| {
        const brick_val = brick_entry.value_ptr;
        const rect = rl.Rectangle{ .x = brick_val.x, .y = brick_val.y, .width = constants.brick_width, .height = constants.brick_height };
        rl.drawRectangleRec(rect, brick_val.color);
    }
}
