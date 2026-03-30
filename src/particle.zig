const std = @import("std");
const rl = @import("raylib");
const game = @import("game.zig");
const constants = @import("constants.zig");

pub const Particle = struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    life: f32,
    max_life: f32,
    color: rl.Color,

    pub fn init() Particle {
        return Particle{
            .pos = rl.Vector2{ .x = 0, .y = 0 },
            .vel = rl.Vector2{ .x = 0, .y = 0 },
            .life = 1.0,
            .max_life = 1.0,
            .color = rl.Color.red,
        };
    }
};

pub fn spawn_particles(state: *game.State, pos: rl.Vector2) !void {
    const count = constants.brick_shatter_particle_number;

    for (0..count) |_| {
        const angle = @as(f32, @floatFromInt(rl.getRandomValue(0, 360))) * std.math.pi / 180;
        const speed: f32 = @floatFromInt(rl.getRandomValue(50, 200));

        const vel = rl.Vector2{
            .x = @cos(angle) * speed,
            .y = @sin(angle) * speed,
        };

        try state.particles.append(state.allocator, Particle{
            .vel = vel,
            .life = 1.0,
            .max_life = 1.0,
            .pos = pos,
            .color = rl.Color{
                .r = 255,
                .g = @intCast(rl.getRandomValue(100, 200)),
                .b = 0,
                .a = 255,
            },
        });
    }
}

pub fn update_particles(state: *game.State) void {
    for (0..state.particles.items.len) |i| {
        if (i >= state.particles.items.len) return;

        const dt = rl.getFrameTime();

        var p = &state.particles.items[i];

        p.life -= dt;

        if (p.life <= 0) {
            _ = state.particles.swapRemove(i);
        }

        p.pos.x += p.vel.x * dt;
        p.pos.y += p.vel.y * dt;

        p.vel.y += 300 * dt;
    }
}

pub fn render_particles(state: *game.State) void {
    for (state.particles.items) |p| {
        const alpha = p.life / p.max_life;
        rl.drawCircleV(p.pos, constants.particle_size, rl.fade(p.color, alpha));
    }
}
