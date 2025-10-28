# Zig Libraries Quick Reference

Fast lookup guide for the four key libraries in zig-starter.

## Library Overview

### zig-test-framework
**Testing & Quality Assurance**
```zig
// Basic test
try ztf.describe(allocator, "Suite", struct {
    fn tests(alloc: std.mem.Allocator) !void {
        try ztf.it(alloc, "should work", testFn);
    }
}.tests);

// Run tests
const registry = ztf.getRegistry(allocator);
try ztf.runTests(allocator, registry);
ztf.cleanupRegistry();
```

**Key APIs:**
- `describe()`, `it()` - Test organization
- `expect().toBe()`, `expect().toContain()` - Assertions
- `createMock()`, `createSpy()` - Mocking
- `itAsync()`, `itTimeout()` - Async/timeouts
- `itSkip()`, `itOnly()` - Test control

**Installation:**
```zig
// build.zig
const zig_test = b.dependency("zig-test-framework", .{...});
exe.root_module.addImport("zig-test-framework", zig_test.module("zig-test-framework"));
```

---

### zig-cli
**CLI Framework & Interactive Prompts**
```zig
// Type-safe CLI
const Options = struct {
    name: []const u8 = "default",
    port: u16 = 8080,
};

fn action(ctx: *cli.Context(Options)) !void {
    const name = ctx.get(.name);     // Compile-time safe!
    const port = ctx.get(.port);
}

var cmd = try cli.command(Options).init(allocator, "mycmd", "Description");
_ = cmd.setAction(action);
```

**Interactive Prompts:**
```zig
// Text input
var text = prompt.TextPrompt.init(allocator, "Your name?");
const name = try text.prompt();

// Confirmation
var confirm = prompt.ConfirmPrompt.init(allocator, "Continue?");
const yes = try confirm.prompt();

// Select
const choices = [_]prompt.SelectPrompt.Choice{
    .{ .label = "Option 1", .value = "opt1" },
};
var select = prompt.SelectPrompt.init(allocator, "Choose:", &choices);
const selected = try select.prompt();

// Progress
var progress = prompt.ProgressBar.init(allocator, 100, "Working...");
try progress.start();
// ... work ...
try progress.finish();
```

**Configuration Loading:**
```zig
const Config = struct {
    database: struct { host: []const u8, port: u16 },
    debug: bool = false,
};

var config = try cli.config.loadTyped(Config, allocator, "config.toml");
```

**Installation:**
```zig
// build.zig
const zig_cli = b.dependency("zig-cli", .{...});
exe.root_module.addImport("zig-cli", zig_cli.module("zig-cli"));
```

---

### zig-config
**Configuration Management**
```zig
// Define config struct
const AppConfig = struct {
    port: u16 = 8080,
    debug: bool = false,
    database: struct {
        host: []const u8 = "localhost",
        port: u16 = 5432,
    } = .{},
};

// Load from multiple sources
var config = try zig_config.loadConfig(AppConfig, allocator, .{
    .name = "myapp",
    .env_prefix = "MYAPP",  // MYAPP_PORT, MYAPP_DEBUG, etc.
    .merge_strategy = .smart,
});
defer config.deinit(allocator);

// Type-safe access
const port: u16 = config.value.port;
const db_host = config.value.database.host;
```

**Config Source Priority:**
1. Environment variables: `MYAPP_PORT=8080`
2. Local project: `./myapp.json`, `./config/myapp.json`
3. Home directory: `~/.config/myapp.json`
4. Code defaults: struct field initializers

**Installation:**
```zig
// build.zig
const zig_config = b.dependency("zig-config", .{...});
exe.root_module.addImport("zig-config", zig_config.module("zig-config"));
```

---

### zig-error-handling (Result type)
**Functional Error Handling**
```zig
// Define result-returning function
fn divide(a: i32, b: i32) Result(i32, []const u8) {
    if (b == 0) return Result(i32, []const u8).err("Division by zero");
    return Result(i32, []const u8).ok(@divTrunc(a, b));
}

// Use result
const result = divide(10, 2);
if (result.isOk()) {
    const value = result.unwrap();
}

// Chain operations
fn parseNumber(str: []const u8) Result(i32, []const u8) { ... }
fn validate(n: i32) Result(i32, []const u8) { ... }

const result = parseNumber("42").andThen(i32, validate);
```

**Common Operations:**
```zig
result.isOk()                    // bool
result.isErr()                   // bool
result.unwrap()                  // T (panics on Err)
result.unwrapOr(default)         // T
result.unwrapOrElse(fn)          // T
result.map(U, transform_fn)      // Result(U, E)
result.mapErr(F, transform_fn)   // Result(T, F)
result.andThen(U, chain_fn)      // Result(U, E)
result.orElse(fallback_fn)       // Self
result.match(U, {.ok, .err})     // U (pattern matching)
```

**Installation (simple copy):**
```bash
cp ~/Code/zig-error-handling/src/result.zig ./src/result.zig
```

Or as dependency:
```zig
// build.zig
const result = b.dependency("result", .{...});
exe.root_module.addImport("result", result.module("result"));
```

---

## Quick Recipes

### Running Tests
```bash
# Auto-discover tests
zig-test --test-dir tests

# With coverage
zig-test --test-dir tests --coverage

# Specific reporter
zig-test --test-dir tests --reporter json

# Watch mode
zig-test --test-dir tests --watch
```

### CLI with All Features
```zig
const std = @import("std");
const cli = @import("zig-cli");
const prompt = cli.prompt;

const Options = struct {
    name: []const u8,
    interactive: bool = false,
};

fn action(ctx: *cli.Context(Options)) !void {
    var name = ctx.get(.name);
    
    if (ctx.get(.interactive)) {
        var input = prompt.TextPrompt.init(allocator, "Custom name?");
        name = try input.prompt();
    }
    
    std.debug.print("Hello, {s}!\n", .{name});
}
```

### Configuration + Environment Variables
```bash
# Via config file
cat > myapp.json << 'JSON'
{
  "port": 8080,
  "debug": false
}
JSON

# Override with env var
export MYAPP_PORT=3000

# Code loads both (env takes priority)
var config = try zig_config.loadConfig(AppConfig, allocator, .{
    .name = "myapp",
});
// config.value.port = 3000 (from env var)
```

### Error Handling Pattern
```zig
const AppError = union(enum) {
    NotFound: []const u8,
    InvalidInput: []const u8,
    DatabaseError: std.fs.File.OpenError,
};

fn loadUser(id: u32) Result(User, AppError) {
    // Return errors explicitly
    if (id == 0) return Result(User, AppError).err(.{ .InvalidInput = "ID cannot be 0" });
    
    // Chain operations
    return fetchFromDB(id)
        .mapErr(AppError, |db_err| AppError{ .DatabaseError = db_err })
        .andThen(User, parseUser);
}

// Usage
const result = loadUser(123);
const user = result.unwrapOr(User{ .id = 0, .name = "Guest" });
```

### Multi-Command CLI
```zig
const ServerOpts = struct { host: []const u8 = "localhost", port: u16 = 8080 };
const ClientOpts = struct { target: []const u8 };

fn serverCmd(ctx: *cli.Context(ServerOpts)) !void { ... }
fn clientCmd(ctx: *cli.Context(ClientOpts)) !void { ... }

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var server = try cli.command(ServerOpts).init(allocator, "server", "Start server");
    _ = server.setAction(serverCmd);
    
    var client = try cli.command(ClientOpts).init(allocator, "client", "Connect to server");
    _ = client.setAction(clientCmd);
    
    // Register subcommands and parse...
}
```

### Testing with Mocks
```zig
// Mock a function
var mock_db = ztf.createMock(allocator, User);
defer mock_db.deinit();

try mock_db.mockReturnValue(User{ .id = 1, .name = "Test" });

// Use in code
const user = mock_db.getReturnValue();

// Verify calls
try mock_db.recordCall("getUser");
try mock_db.toHaveBeenCalled();
try mock_db.toHaveBeenCalledTimes(1);
```

---

## Common Patterns

### Centralized Configuration
```zig
// config.zig
pub const Config = struct {
    port: u16,
    debug: bool,
    database: struct { url: []const u8 },
};

// main.zig
var config = try zig_config.loadConfig(Config, allocator, .{ .name = "app" });
// Use config throughout app
```

### Result-Based CLI Actions
```zig
const CliResult = Result(u8, CliError);  // u8 = exit code

fn handleCommand(args: [][]const u8) CliResult {
    // Return Result instead of throwing
    if (args.len == 0) {
        return CliResult.err(CliError.NoArgs);
    }
    return CliResult.ok(0);
}

pub fn main() !void {
    const result = handleCommand(...);
    std.process.exit(result.unwrapOr(1));
}
```

### Test Fixtures
```zig
// tests/fixtures.zig
pub const sample_config = @embedFile("fixtures/config.json");
pub const sample_data = @embedFile("fixtures/data.json");

// tests/app.test.zig
try ztf.it(allocator, "should load config", struct {
    fn test(alloc: std.mem.Allocator) !void {
        var config = try zig_config.loadFromString(
            Config,
            alloc,
            fixtures.sample_config,
            .json
        );
        defer config.deinit(alloc);
        try ztf.expect(alloc, config.value.port).toBe(8080);
    }
}.test);
```

---

## Dependency Graph

```
Your App
├── zig-cli
│   └── prompt module
├── zig-config
│   └── json parser
├── zig-test-framework
│   └── assertions + reporters
└── zig-error-handling (Result type)
    └── stdlib only

All libraries are ZERO-DEPENDENCY (stdlib only)
```

---

## File Organization

```
project/
├── src/
│   ├── main.zig           # Entry point
│   ├── app.zig            # App logic
│   ├── config.zig         # Config struct
│   ├── errors.zig         # Error types
│   ├── cli/
│   │   ├── root.zig
│   │   └── commands/
│   ├── result.zig         # Copy from zig-error-handling
│   └── models/
├── tests/
│   ├── unit/
│   │   ├── app.test.zig
│   │   ├── cli.test.zig
│   │   └── config.test.zig
│   ├── integration/
│   │   └── end_to_end.test.zig
│   └── fixtures/
│       ├── config.json
│       └── test_data.json
├── config/
│   ├── default.json
│   ├── development.json
│   └── production.json
├── build.zig
├── build.zig.zon
└── README.md
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Test memory leaks | Call `ztf.cleanupRegistry()` |
| Config not loading | Check file path and permissions; verify naming |
| CLI not parsing | Verify struct field names match command options |
| Prompt hangs | Requires TTY; skip in CI or use env vars |
| Type mismatch in Result | Ensure E type is consistent across chain |
| Unicode not working | Terminal may need color/unicode detection |

---

## Key Takeaways

1. **zig-test-framework**: Use for comprehensive testing with coverage
2. **zig-cli**: Use for user-friendly command-line tools
3. **zig-config**: Use for environment-aware configuration
4. **zig-error-handling**: Use for functional error handling

All four work together seamlessly with **zero external dependencies**.

Perfect for production Zig applications!

