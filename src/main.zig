const std = @import("std");
const starter = @import("starter");
const cpu = @import("cpu.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buffer: [4096]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(io, &buffer);
    const out = &stdout.interface;

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const input: []const u8 = if (args.len > 1) args[1] else "hello, zig";

    try out.print("zig-starter {f}\n", .{starter.version});
    try out.print("checksum(\"{s}\") = 0x{x:0>16}\n", .{ input, try starter.checksum(input) });
    try out.print("cpu: {s}\n", .{@tagName(cpu.detect())});
    try out.flush();
}
