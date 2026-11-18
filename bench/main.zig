//! `zig build bench [-- <results.json>]`: benchmarks with zig-bench, writing a JSON result file
//! (default `zig-out/bench.json`) that CI can compare against a stored baseline.
const std = @import("std");
const bench = @import("bench");
const starter = @import("starter");

var input_1k: [1024]u8 = undefined;
var input_1m: [1024 * 1024]u8 = undefined;
var sink: u64 = 0;

fn checksum1k() void {
    sink +%= starter.checksum(&input_1k) catch unreachable;
}

fn checksum1m() void {
    sink +%= starter.checksum(&input_1m) catch unreachable;
}

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const out_path = if (args.len > 1) args[1] else "zig-out/bench.json";

    if (std.fs.path.dirname(out_path)) |dir| try std.Io.Dir.cwd().createDirPath(init.io, dir);

    var prng = std.Random.DefaultPrng.init(42);
    prng.random().bytes(&input_1k);
    prng.random().bytes(&input_1m);

    var suite = bench.BenchmarkSuite.init(init.gpa, init.io);
    defer suite.deinit();
    try suite.add("checksum 1 KiB", checksum1k);
    try suite.add("checksum 1 MiB", checksum1m);
    suite.setBaseline(out_path);
    try suite.run();
    std.mem.doNotOptimizeAway(sink);
}
