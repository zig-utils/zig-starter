//! Deterministic fuzzing: `zig build fuzz -Dfuzz-iterations=N -Dfuzz-seed=S`. Same seed, same
//! cases, so a failure in CI reproduces locally. Add one block per parser or entry point.
const std = @import("std");
const starter = @import("starter");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const iterations = if (args.len > 1) try std.fmt.parseInt(usize, args[1], 10) else 10_000;
    const seed = if (args.len > 2) try std.fmt.parseInt(u64, args[2], 10) else 0x5eed_5eed;

    var prng = std.Random.DefaultPrng.init(seed);
    const random = prng.random();
    var buf: [4096]u8 = undefined;

    for (0..iterations) |_| {
        const len = random.uintLessThan(usize, buf.len + 1);
        random.bytes(buf[0..len]);
        const result = starter.checksum(buf[0..len]);
        if (len == 0) {
            if (result != error.EmptyInput) return error.FuzzMismatch;
        } else {
            _ = try result;
        }
    }
    std.debug.print("fuzz: {d} cases, seed {d}, ok\n", .{ iterations, seed });
}
