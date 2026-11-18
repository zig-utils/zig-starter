//! The library's Zig API. Replace this with your own; keep it free of global state so it can be
//! wrapped by the C ABI in capi.zig and used from several threads.
const std = @import("std");

pub const version = std.SemanticVersion{ .major = 0, .minor = 2, .patch = 0 };

pub const Error = error{ EmptyInput, InputTooLarge };

/// Largest input `checksum` accepts. Libraries that parse untrusted input should always bound it.
pub const max_input_len: usize = 64 * 1024 * 1024;

/// A sample pure function: FNV-1a over the input. It allocates nothing, which is the shape a
/// function exported across a C ABI should have.
pub fn checksum(input: []const u8) Error!u64 {
    if (input.len == 0) return error.EmptyInput;
    if (input.len > max_input_len) return error.InputTooLarge;
    var hash: u64 = 0xcbf29ce484222325;
    for (input) |byte| {
        hash ^= byte;
        hash *%= 0x100000001b3;
    }
    return hash;
}

test checksum {
    try std.testing.expectEqual(@as(u64, 0xaf63dc4c8601ec8c), try checksum("a"));
    try std.testing.expectError(error.EmptyInput, checksum(""));
}

test "checksum differs for different inputs" {
    try std.testing.expect(try checksum("hello") != try checksum("hellp"));
}
