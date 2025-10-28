const std = @import("std");

/// Core library functionality (simple version without external dependencies)
pub const StarterLib = struct {
    allocator: std.mem.Allocator,
    config: Config,

    pub const Config = struct {
        name: []const u8 = "default",
        debug: bool = false,
        max_retries: u32 = 3,
    };

    pub fn init(allocator: std.mem.Allocator) !StarterLib {
        return StarterLib{
            .allocator = allocator,
            .config = .{},
        };
    }

    pub fn deinit(self: *StarterLib) void {
        _ = self;
    }

    /// Process data and return a copy
    pub fn processData(self: *StarterLib, data: []const u8) ![]u8 {
        if (data.len == 0) {
            return ProcessError.EmptyData;
        }

        const result = try self.allocator.alloc(u8, data.len);
        @memcpy(result, data);
        return result;
    }

    /// Example function with validation
    pub fn validateInput(input: []const u8) !void {
        if (input.len == 0) {
            return ProcessError.EmptyData;
        }
        if (input.len > 1024) {
            return ProcessError.DataTooLarge;
        }
    }
};

pub const ProcessError = error{
    EmptyData,
    DataTooLarge,
    AllocationFailed,
    InvalidFormat,
};

test "StarterLib initialization" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lib = try StarterLib.init(allocator);
    defer lib.deinit();

    try std.testing.expect(lib.config.max_retries == 3);
    try std.testing.expect(!lib.config.debug);
}

test "processData with valid input" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lib = try StarterLib.init(allocator);
    defer lib.deinit();

    const input = "test data";
    const data = try lib.processData(input);
    defer allocator.free(data);

    try std.testing.expectEqualStrings(input, data);
}

test "processData with empty input" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lib = try StarterLib.init(allocator);
    defer lib.deinit();

    const result = lib.processData("");
    try std.testing.expectError(ProcessError.EmptyData, result);
}

test "validateInput" {
    try StarterLib.validateInput("valid");
    try std.testing.expectError(ProcessError.EmptyData, StarterLib.validateInput(""));

    const large = "x" ** 2000;
    try std.testing.expectError(ProcessError.DataTooLarge, StarterLib.validateInput(large));
}
