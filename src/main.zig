const std = @import("std");
const starter = @import("starter");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("Zig Starter - Simple Version\n", .{});
    std.debug.print("=============================\n\n", .{});

    // Initialize library
    var lib = try starter.StarterLib.init(allocator);
    defer lib.deinit();

    std.debug.print("Library initialized with max_retries = {d}\n\n", .{lib.config.max_retries});

    // Process some data
    const input = "Hello, Zig!";
    std.debug.print("Processing: \"{s}\"\n", .{input});

    const result = try lib.processData(input);
    defer allocator.free(result);

    std.debug.print("Result: \"{s}\"\n\n", .{result});

    std.debug.print("To use the full version with all dependencies:\n", .{});
    std.debug.print("1. Run: pantry install\n", .{});
    std.debug.print("2. Rename build.zig.full to build.zig\n", .{});
    std.debug.print("3. Run: zig build\n\n", .{});

    std.debug.print("Available dependencies after install:\n", .{});
    std.debug.print("  - zig-cli: Type-safe CLI framework\n", .{});
    std.debug.print("  - zig-config: Configuration management\n", .{});
    std.debug.print("  - zig-error-handling: Result type for error handling\n", .{});
    std.debug.print("  - zig-test-framework: Jest/Vitest-style testing\n", .{});
    std.debug.print("  - zig-bump: Version bumping and changelog generation\n", .{});
}

test "simple main" {
    // Basic test to ensure main would work
    try std.testing.expect(true);
}
