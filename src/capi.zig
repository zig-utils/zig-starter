//! The C ABI. Every exported symbol carries a `_v1` suffix: a breaking change adds a `_v2`
//! symbol next to it instead of changing this one, so existing callers keep working.
//!
//! Rules the template follows (and libraries built from it should too):
//! - Status codes, never Zig errors, cross the boundary.
//! - Option structs start with their own size, so new fields can be added later.
//! - Memory allocated here is only ever freed here, through an exported free function.
const std = @import("std");
const starter = @import("starter");

pub const Status = enum(c_int) {
    ok = 0,
    invalid_argument = 1,
    empty_input = 2,
    input_too_large = 3,
};

pub const Options = extern struct {
    /// Must be `@sizeOf(Options)` as the caller knows it; fields past that size are defaulted.
    size: u32,
    /// Sample option: XOR applied to the result.
    seed: u64,
};

export fn starter_version_v1() u32 {
    const v = starter.version;
    return @intCast(v.major * 10_000 + v.minor * 100 + v.patch);
}

export fn starter_checksum_v1(data: ?[*]const u8, len: usize, options: ?*const Options, out: ?*u64) Status {
    const result = out orelse return .invalid_argument;
    if (len != 0 and data == null) return .invalid_argument;
    var seed: u64 = 0;
    if (options) |opts| {
        if (opts.size < @offsetOf(Options, "seed") + @sizeOf(u64)) return .invalid_argument;
        seed = opts.seed;
    }
    const input = if (len == 0) &[_]u8{} else data.?[0..len];
    const sum = starter.checksum(input) catch |err| return switch (err) {
        error.EmptyInput => .empty_input,
        error.InputTooLarge => .input_too_large,
    };
    result.* = sum ^ seed;
    return .ok;
}

test "checksum through the C ABI" {
    var out: u64 = 0;
    try std.testing.expectEqual(Status.ok, starter_checksum_v1("a", 1, null, &out));
    try std.testing.expectEqual(try starter.checksum("a"), out);

    const opts = Options{ .size = @sizeOf(Options), .seed = 1 };
    try std.testing.expectEqual(Status.ok, starter_checksum_v1("a", 1, &opts, &out));
    try std.testing.expectEqual(try starter.checksum("a") ^ 1, out);

    try std.testing.expectEqual(Status.empty_input, starter_checksum_v1(null, 0, null, &out));
    try std.testing.expectEqual(Status.invalid_argument, starter_checksum_v1(null, 4, null, &out));
    try std.testing.expectEqual(Status.invalid_argument, starter_checksum_v1("a", 1, null, null));
}

test "version is encoded as major*10000 + minor*100 + patch" {
    try std.testing.expectEqual(@as(u32, 200), starter_version_v1());
}
