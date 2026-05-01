# Zig Library Integration Guide for Starter Project

A comprehensive guide to four essential Zig libraries and their integration into a starter project.

## Quick Reference Table

| Library | Purpose | Type | Key Features | Dependencies |
|---------|---------|------|--------------|--------------|
| **zig-test-framework** | Testing & Quality Assurance | Testing Framework | Async tests, Coverage, Reporters, Mocking | Zero - stdlib only |
| **zig-cli** | CLI & User Interaction | CLI Framework | Type-safe commands, Interactive prompts, Config files | Zero - stdlib only |
| **zig-config** | Configuration Management | Config Loader | Multi-source loading, Type-safe access, Deep merge | Zero - stdlib only |
| **zig-error-handling** | Error Handling | Error Handling Pattern | Result type, Functional composition, Pattern matching | Zero - stdlib only |

---

## 1. Zig Test Framework

### Overview

A comprehensive, Jest-inspired testing framework providing test discovery, rich assertions, async support, and multiple reporters. Ideal for production-grade test suites.

**GitHub**: zig-utils/zig-test-framework

### Functionality

#### Core Testing

- **Test Discovery**: Automatic `*.test.zig` file detection
- **Test Organization**: `describe()` and `it()` style test suites
- **Test Hooks**: `beforeEach`, `afterEach`, `beforeAll`, `afterAll`
- **Test Control**: Skip tests with `.skip()` or focus with `.only()`

#### Assertions & Matchers

- **Basic Assertions**: `toBe()`, `toEqual()`, `toBeTruthy()`, `toBeFalsy()`
- **Comparisons**: `toBeGreaterThan()`, `toBeLessThan()`, `toBeGreaterThanOrEqual()`, `toBeLessThanOrEqual()`
- **String Matchers**: `toContain()`, `toStartWith()`, `toEndWith()`, `toHaveLength()`
- **Array Matchers**: `toContain()`, `toContainAll()`, `toHaveLength()`
- **Optional Checks**: `toBeNull()`, `toBeDefined()`
- **Error Testing**: `toThrow()`, `toThrowError()`
- **Floating-point**: `toBeCloseTo()`, `toBeNaN()`, `toBeInfinite()`
- **Struct Matching**: Field-level assertions with `expectStruct()`

#### Advanced Features

- **Mocking & Spying**: `createMock()` and `createSpy()` with call tracking
- **Async Tests**: Full async/await support with concurrent & sequential execution
- **Timeout Handling**: Per-test, per-suite, and global timeout configurations
- **Multiple Reporters**: Spec (default), Dot, JSON, TAP, JUnit
- **Code Coverage**: Integration with kcov/grindcov for line/branch/function coverage
- **Snapshot Testing**: Compare outputs against saved snapshots with diff generation
- **Watch Mode**: Auto-rerun tests on file changes
- **Memory Profiling**: Track and detect memory leaks
- **Parallel Execution**: Run tests concurrently for faster execution
- **Configuration Files**: YAML/JSON/TOML config support

### API Patterns

#### Basic Test Suite

```zig
const std = @import("std");
const ztf = @import("zig-test-framework");

try ztf.describe(allocator, "Math operations", struct {
    fn testSuite(alloc: std.mem.Allocator) !void {
        try ztf.it(alloc, "should add two numbers", testAddition);
        try ztf.it(alloc, "should subtract two numbers", testSubtraction);
    }

    fn testAddition(alloc: std.mem.Allocator) !void {
        const result = 2 + 2;
        try ztf.expect(alloc, result).toBe(4);
    }

    fn testSubtraction(alloc: std.mem.Allocator) !void {
        const result = 10 - 5;
        try ztf.expect(alloc, result).toBe(5);
    }
}.testSuite);

// Run tests
const registry = ztf.getRegistry(allocator);
const success = try ztf.runTests(allocator, registry);
ztf.cleanupRegistry();  // IMPORTANT!
```

#### Test Discovery Mode (Recommended)

```bash
# Automatically discover and run *.test.zig files
zig-test --test-dir tests
zig-test --test-dir tests --coverage --reporter json
```

#### Async Tests

```zig
try ztf.itAsync(allocator, "async operation", struct {
    fn run(alloc: std.mem.Allocator) !void {
        std.Thread.sleep(100 * std.time.ns*per*ms);
        // Async test implementation
    }
}.run);
```

#### Mocking

```zig
var mock*fn = ztf.createMock(alloc, i32);
defer mock*fn.deinit();

try mock*fn.recordCall("arg1");
try mock*fn.toHaveBeenCalledWith("arg1");
try mock*fn.mockReturnValue(42);
```

### Installation & Integration

**As a dependency in `build.zig`:**

```zig
const zig*test = b.dependency("zig-test-framework", .{
    .target = target,
    .optimize = optimize,
});

exe.root*module.addImport("zig-test-framework", zig*test.module("zig-test-framework"));
```

**In `build.zig.zon`:**

```zig
.dependencies = .{
    .@"zig-test-framework" = .{
        .url = "https://github.com/zig-utils/zig-test-framework/archive/refs/tags/v0.1.0.tar.gz",
        .hash = "...",
    },
}
```

### Usage in Starter Project

**Project Structure:**

```
my-project/
├── src/
│   ├── main.zig
│   ├── math.zig
│   └── utils.zig
├── tests/
│   ├── math.test.zig
│   └── utils.test.zig
├── build.zig
└── build.zig.zon
```

**Key Integration Points:**

1. **Pre-commit hooks**: Run tests before each commit
2. **CI/CD pipelines**: Coverage reporting with HTML output
3. **Memory profiling**: Detect leaks in long-running processes
4. **Test organization**: Group related tests with nested `describe()` blocks
5. **Watch mode**: Live test runner during development

### Dependencies & Requirements

- **Zig**: 0.13.0 or later
- **External tools**: kcov (optional, for coverage)
- **No library dependencies**: Uses only Zig stdlib

### Strengths

✅ Comprehensive assertion library  
✅ Async test support with timeouts  
✅ Multiple reporter formats  
✅ Code coverage integration  
✅ Memory profiling built-in  
✅ Zero dependencies  

### Considerations

- Memory cleanup required: `cleanupRegistry()` after tests
- Async tests need explicit timeout configuration
- Coverage requires external tool (kcov/grindcov)

---

## 2. Zig CLI

### Overview

A powerful, type-safe CLI framework with compile-time validation, interactive prompts, and configuration file support. Inspired by TypeScript's clapp library.

**GitHub**: zig-utils/zig-cli

### Functionality

#### CLI Framework

- **Type-Safe Commands**: Define CLI with structs, compile-time field validation
- **Auto-generated Help**: Automatic help text from struct definitions
- **Subcommands**: Nested command support with aliases
- **Options & Arguments**: Full command-line parsing
- **Middleware System**: Pre/post command hooks with type safety

#### Interactive Prompts (13+ Types!)

- **Text Input**: With validation and placeholders
- **Confirmation Prompts**: Yes/no questions
- **Select**: Single-choice selection
- **MultiSelect**: Multiple choice selection
- **Password**: Masked input for sensitive data
- **Number**: Integer/float input with range validation
- **Path**: File/directory selection with Tab autocomplete
- **Group**: Multi-step workflows bundled together
- **Spinner**: Loading/activity indicators
- **Progress Bars**: Customizable progress visualization (4 styles)
- **Messages**: Intro, outro, note, log, cancel messages
- **Box/Panel**: Organized output rendering
- **Table**: Column-based data display with multiple styles

#### Terminal Features

- **ANSI Colors**: Full color support with auto-detection
- **Style Chaining**: `.red().bold().underline()` API
- **Raw Mode**: Cross-platform terminal handling
- **Cursor Control**: Hide/show/save cursor position
- **Unicode Support**: Graceful ASCII fallback
- **Keyboard Input**: Full keyboard event handling
- **Terminal Detection**: Automatic width/height detection
- **Multiple Box Styles**: Single, double, rounded, ASCII
- **Table Rendering**: Column alignment and multiple border styles

#### Configuration Support

- **Multiple Formats**: TOML, JSONC (JSON with Comments), JSON5
- **Auto-discovery**: Search in standard locations
- **Type-safe Loading**: Compile-time schema validation
- **Nested Structures**: Full support for complex configs
- **Default Values**: Define defaults in struct fields
- **Optional Fields**: Use `?T` for optional config values

### API Patterns

#### Type-Safe CLI Command

```zig
const std = @import("std");
const cli = @import("zig-cli");

const GreetOptions = struct {
    name: []const u8 = "World",
    enthusiastic: bool = false,
};

fn greet(ctx: *cli.Context(GreetOptions)) !void {
    const stdout = std.io.getStdOut().writer();
    const name = ctx.get(.name);           // Compile-time validated!
    const punct = if (ctx.get(.enthusiastic)) "!" else ".";
    try stdout.print("Hello, {s}{s}\n", .{name, punct});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer * = gpa.deinit();
    const allocator = gpa.allocator();

    var cmd = try cli.command(GreetOptions).init(allocator, "greet", "Greet someone");
    defer cmd.deinit();

    * = cmd.setAction(greet);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    try cli.Parser.init(allocator).parse(cmd.getCommand(), args[1..]);
}
```

#### Interactive Prompts

```zig
// Text prompt
var text = prompt.TextPrompt.init(allocator, "What is your name?");
defer text.deinit();
const name = try text.prompt();
defer allocator.free(name);

// Select prompt
const choices = [*]prompt.SelectPrompt.Choice{
    .{ .label = "Option 1", .value = "opt1" },
    .{ .label = "Option 2", .value = "opt2" },
};
var select = prompt.SelectPrompt.init(allocator, "Choose:", &choices);
defer select.deinit();
const selected = try select.prompt();
```

#### Configuration Loading

```zig
const AppConfig = struct {
    database: struct {
        host: []const u8,
        port: u16,
        max*connections: u32 = 100,
    },
    log*level: enum { debug, info, warn, @"error" } = .info,
    debug: bool = false,
};

var config = try cli.config.loadTyped(AppConfig, allocator, "config.toml");
defer config.deinit();

std.debug.print("DB: {s}:{d}\n", .{
    config.value.database.host,
    config.value.database.port,
});
```

#### Middleware

```zig
var chain = cli.Middleware.MiddlewareChain.init(allocator);
defer chain.deinit();

try chain.use(cli.Middleware.Middleware.init("logging", cli.Middleware.loggingMiddleware));
try chain.use(cli.Middleware.Middleware.init("timing", cli.Middleware.timingMiddleware));

fn authMiddleware(ctx: *cli.Middleware.MiddlewareContext) !bool {
    const is*authenticated = checkAuth();
    return is*authenticated;  // true = continue, false = stop
}
```

### Installation & Integration

**In `build.zig`:**

```zig
const zig*cli = b.dependency("zig-cli", .{
    .target = target,
    .optimize = optimize,
});

exe.root*module.addImport("zig-cli", zig*cli.module("zig-cli"));
```

### Usage in Starter Project

**Multi-command CLI Application:**

```zig
// Define subcommand options as structs
const ServerOptions = struct {
    host: []const u8 = "0.0.0.0",
    port: u16 = 8080,
    workers: u8 = 4,
};

const ClientOptions = struct {
    target: []const u8,
    timeout: u32 = 30000,
};

// Implement actions for each command
fn serverAction(ctx: *cli.Context(ServerOptions)) !void { }
fn clientAction(ctx: *cli.Context(ClientOptions)) !void { }

// Main app with subcommands...
```

**Interactive Configuration Setup:**

```zig
var name = prompt.TextPrompt.init(allocator, "Project name?");
const project*name = try name.prompt();
defer allocator.free(project*name);

var port = prompt.NumberPrompt.init(allocator, "Port?", .integer);

* = port.withRange(1, 65535).withDefault(8080);

const port*num = @as(u16, @intFromFloat(try port.prompt()));

// Save configuration...
```

### Dependencies & Requirements

- **No external dependencies**: Uses only Zig stdlib
- **Cross-platform**: macOS, Linux, Windows
- **Terminal support**: Auto-detection of color/unicode support

### Strengths

✅ Compile-time type validation  
✅ Rich interactive prompts  
✅ Type-safe configuration loading  
✅ Chainable styling API  
✅ Middleware system  
✅ 500KB binary size vs 50MB for Node.js alternatives  
✅ <1ms startup time  

### Considerations

- Prompts require terminal I/O
- Windows terminal support may need improvement
- Configuration auto-discovery searches multiple standard locations

---

## 3. Zig Config

### Overview

A lightweight, zero-dependency configuration loader inspired by Bun's bunfig. Supports JSON, environment variables, and multi-source merging with deep structure support.

**GitHub**: zig-utils/zig-config

### Functionality

#### Configuration Sources (Priority Order)

1. **Environment Variables** (highest priority)
2. **Local Project File** (`./myapp.json`, `./config/myapp.json`, `./.config/myapp.json`)
3. **Home Directory** (`~/.config/myapp.json`)
4. **Defaults** (provided in code - lowest priority)

#### Type-Safe Configuration

- **Compile-time Type Checking**: No runtime type errors
- **Default Values**: Define in struct fields
- **Optional Fields**: Use `?T` for optional config
- **Nested Structures**: Arbitrary depth support
- **Arrays**: Fixed-size arrays supported
- **Environment Variable Parsing**: Auto-parse booleans, numbers, arrays, JSON

#### Advanced Features

- **Deep Merging**: Three strategies: replace, concat, smart
- **Circular Reference Detection**: Prevents infinite loops
- **Multiple Format Support**: JSON and Zig files (extensible)
- **File Discovery**: Searches standard locations automatically
- **Caching**: Optional caching with TTL

#### Environment Variable Format

```bash
# Boolean values
MYAPP*DEBUG=true        # → bool
MYAPP*VERBOSE=1         # → bool (true)

# Numbers
MYAPP*PORT=3000         # → integer
MYAPP*TIMEOUT=30.5      # → float

# Arrays (comma-separated)
MYAPP*HOSTS=localhost,api.example.com

# JSON objects/arrays
MYAPP*DATABASE='{"host":"localhost","port":5432}'
MYAPP*TAGS='["production","web"]'

# Naming: UPPERCASE*PREFIX + NESTED*KEY
# Example: database.host → MYAPP*DATABASE*HOST
```

### API Patterns

#### Basic Configuration

```zig
const std = @import("std");
const zig*config = @import("zig-config");

const AppConfig = struct {
    port: u16 = 8080,
    debug: bool = false,
    database: struct {
        host: []const u8 = "localhost",
        port: u16 = 5432,
    } = .{},
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer * = gpa.deinit();
    const allocator = gpa.allocator();

    // Load with compile-time type checking
    var config = try zig*config.loadConfig(AppConfig, allocator, .{
        .name = "myapp",
    });
    defer config.deinit(allocator);

    // Type-safe access!
    const port: u16 = config.value.port;
    const db*host = config.value.database.host;
}
```

#### Advanced Configuration with Options

```zig
var config = try zig*config.loadConfig(AppConfig, allocator, .{
    .name = "myapp",
    .cwd = "/path/to/project",              // Custom working directory
    .env*prefix = "CUSTOM",                 // Use CUSTOM** instead of MYAPP**
    .merge*strategy = .smart,               // .replace, .concat, .smart
});
defer config.deinit(allocator);
```

#### Deep Merging

```zig
var target = std.json.ObjectMap.init(allocator);
defer target.deinit();
try target.put("a", .{ .integer = 1 });

var source = std.json.ObjectMap.init(allocator);
defer source.deinit();
try source.put("b", .{ .integer = 2 });

const merged = try zig*config.deepMerge(
    allocator,
    .{ .object = target },
    .{ .object = source },
    .{ .strategy = .smart },
);
// Result: { "a": 1, "b": 2 }
```

#### Error Handling

```zig
const config = zig*config.loadConfig(AppConfig, allocator, options) catch |err| switch (err) {
    error.ConfigFileNotFound => {
        // Use defaults or create new config
        std.debug.print("No config found, using defaults\n", .{});
        return;
    },
    error.ConfigFileSyntaxError => {
        std.debug.print("Invalid JSON in config file\n", .{});
        return error.InvalidConfig;
    },
    else => return err,
};
defer config.deinit(allocator);
```

### Configuration Result Structure

```zig
pub const ConfigResult = struct {
    value: T,                           // The actual typed config
    source: ConfigSource,               // Primary source (.file*local, .env*vars, etc)
    sources: []SourceInfo,              // All sources that contributed
    loaded*at: i64,                     // Timestamp
};
```

### Installation & Integration

**In `build.zig`:**

```zig
const zig*config = b.dependency("zig-config", .{
    .target = target,
    .optimize = optimize,
});

exe.root*module.addImport("zig-config", zig*config.module("zig-config"));
```

### Merge Strategies

**Replace** (default for primitives):

```zig
.{ .strategy = .replace }
// [1, 2] + [3, 4] = [3, 4]
```

**Concat** (for arrays):

```zig
.{ .strategy = .concat }
// [1, 2] + [2, 3] = [1, 2, 3]  (with deduplication)
```

**Smart** (for object arrays):

```zig
.{ .strategy = .smart }
// [{"id": 1, "name": "a"}] + [{"id": 1, "name": "b"}]
// = [{"id": 1, "name": "b"}]  (merged by id)
```

### Usage in Starter Project

**Project-wide Configuration:**

```
my-project/
├── config/
│   ├── app.json          (dev defaults)
│   ├── app.prod.json     (production overrides)
│   └── app.test.json     (test config)
├── .config/
│   └── app.json          (user-local config)
├── ~/.config/
│   └── app.json          (home directory config)
└── src/
    └── main.zig
```

**Load Configuration in Main:**

```zig
const Config = struct {
    app*name: []const u8,
    environment: enum { dev, prod, test } = .dev,
    database: struct {
        url: []const u8,
        pool*size: u32 = 10,
    },
};

var config = try zig*config.loadConfig(Config, allocator, .{
    .name = "myapp",
});
defer config.deinit(allocator);
```

### Dependencies & Requirements

- **Zig**: 0.13.0 or later
- **Zero dependencies**: Uses only Zig stdlib
- **All tests passing**: 20/20 tests (4 known benign memory "leaks" from Zig's JSON parser)

### Strengths

✅ Multi-source configuration loading  
✅ Type-safe compile-time checking  
✅ Environment variable auto-parsing  
✅ Deep merging with circular reference detection  
✅ Zero dependencies  
✅ File discovery with sensible defaults  

### Considerations

- Config discovery searches multiple locations (be aware of precedence)
- JSON parser has internal arena allocator (expected behavior)
- Limited to JSON format for files (but extensible)

---

## 4. Zig Error Handling (Result Type)

### Overview

A functional error handling library inspired by Rust's `Result<T, E>` and TypeScript's neverthrow. Provides chainable operations, pattern matching, and type-safe error composition.

**GitHub**: zig-utils/zig-error-handling

### Functionality

#### Result Type

- **Ok/Err States**: Explicit success (Ok) and failure (Err) representation
- **Type Safety**: Both value type `T` and error type `E` are explicit
- **No Unwrapping Overhead**: Compiles to efficient Zig code

#### Transformations

- **map**: Transform Ok values
- **mapErr**: Transform Err values
- **mapBoth**: Transform both variants to common type
- **andThen** (flatMap): Chain fallible operations
- **orElse**: Provide fallback on error

#### Extraction

- **unwrap**: Get Ok value or panic
- **unwrapOr**: Get Ok value with default
- **unwrapOrElse**: Get Ok value or compute from error
- **expect**: Get Ok value or panic with message

#### Pattern Matching

- **match**: Elegant pattern matching on Ok/Err

#### Collection Operations

- **collect**: Transform slice of Results to Result of slice
- **partition**: Split Results into separate Ok and Err arrays
- **sequence**: Short-circuit on first error

#### Advanced Operations

- **inspect**: Side effects without transformation
- **flatten**: Unwrap nested Results
- **transpose**: Convert Result of Optional to Optional of Result
- **combine**: Combine two Results into tuple
- **combine3/combine4**: Combine multiple Results

#### Conversion

- **toErrorUnion**: Convert to Zig error union for safe unwrapping
- **okOrNull**: Convert to optional, discarding error
- **errOrNull**: Convert to optional error, discarding value

### API Patterns

#### Basic Result Usage

```zig
const std = @import("std");
const Result = @import("result").Result;

fn divide(a: i32, b: i32) Result(i32, []const u8) {
    if (b == 0) {
        return Result(i32, []const u8).err("Division by zero");
    }
    return Result(i32, []const u8).ok(@divTrunc(a, b));
}

pub fn main() !void {
    const result = divide(10, 2);

    if (result.isOk()) {
        std.debug.print("Result: {d}\n", .{result.unwrap()});
    } else {
        std.debug.print("Error: {s}\n", .{result.unwrapErr()});
    }
}
```

#### Chaining Operations

```zig
fn parseNumber(str: []const u8) Result(i32, []const u8) {
    const num = std.fmt.parseInt(i32, str, 10) catch {
        return Result(i32, []const u8).err("Invalid number");
    };
    return Result(i32, []const u8).ok(num);
}

fn validatePositive(n: i32) Result(i32, []const u8) {
    if (n <= 0) {
        return Result(i32, []const u8).err("Number must be positive");
    }
    return Result(i32, []const u8).ok(n);
}

// Chain operations: stops at first error
const result = parseNumber("42")
    .andThen(i32, validatePositive);
```

#### Transformations

```zig
const result = Result(i32, []const u8).ok(21);

// Transform Ok value
const doubled = result.map(i32, struct {
    fn double(x: i32) i32 { return x * 2; }
}.double);
// doubled is Result(i32, []const u8).ok(42)

// Transform error
const mapped*err = Result(i32, []const u8).err("failed")
    .mapErr([]const u8, struct {
        fn toUpper(s: []const u8) []const u8 { return "FAILED"; }
    }.toUpper);
```

#### Pattern Matching

```zig
const result = Result(i32, []const u8).ok(42);

const message = result.match([]const u8, .{
    .ok = struct {
        fn handleOk(x: i32) []const u8 { return "Success!"; }
    }.handleOk,
    .err = struct {
        fn handleErr(e: []const u8) []const u8 { return e; }
    }.handleErr,
});
```

#### Collection Operations

```zig
// Collect all Results into Result of slice
const results = [*]Result(i32, []const u8){
    Result(i32, []const u8).ok(1),
    Result(i32, []const u8).ok(2),
    Result(i32, []const u8).ok(3),
};

const collected = collect(i32, []const u8, allocator, &results);
// If all Ok: Result([]i32, []const u8).ok([1, 2, 3])
// If any Err: Returns first error
defer if (collected.isOk()) allocator.free(collected.unwrap());

// Partition into separate Ok and Err arrays
const results2 = [*]Result(i32, []const u8){
    Result(i32, []const u8).ok(1),
    Result(i32, []const u8).err("error1"),
    Result(i32, []const u8).ok(2),
};

const partitioned = try partition(i32, []const u8, allocator, &results2);
defer allocator.free(partitioned.oks);
defer allocator.free(partitioned.errs);
// partitioned.oks = [1, 2]
// partitioned.errs = ["error1"]
```

#### Conversion to Error Union

```zig
const fromErrorUnion = @import("result").fromErrorUnion;

// Convert error union to Result
const errorUnion: anyerror!i32 = 42;
const result = fromErrorUnion(errorUnion);
// result is Result(i32, anyerror).ok(42)

// Convert Result to error union for safe unwrapping
const result2 = Result(i32, anyerror).ok(42);
const error*union = result2.toErrorUnion();  // Returns anyerror!i32
```

### Installation & Integration

**In `build.zig.zon`:**

```zig
.dependencies = .{
    .result = .{
        .url = "https://github.com/yourusername/zig-result/archive/refs/tags/v0.1.0.tar.gz",
        .hash = "...",
    },
}
```

**In `build.zig`:**

```zig
const result = b.dependency("result", .{
    .target = target,
    .optimize = optimize,
});

exe.root*module.addImport("result", result.module("result"));
```

**Or simple copy:** Just copy `src/result.zig` into your project!

### Usage in Starter Project

**Application Result Type:**

```zig
const AppResult = Result(T, AppError);

const AppError = enum {
    ConfigNotFound,
    DatabaseError,
    ValidationError,
    NetworkError,
};

fn loadConfiguration() Result(Config, AppError) {
    // Implementation
}

fn connectToDatabase(config: Config) Result(Database, AppError) {
    // Implementation
}

// Chain operations
const db = loadConfiguration()
    .andThen(Config, connectToDatabase);
```

**Error Handling in CLI Applications:**

```zig
const CliResult = Result(u8, CliError);  // u8 is exit code

const CliError = union(enum) {
    file*not*found: []const u8,
    invalid*argument: []const u8,
    io*error: std.fs.File.OpenError,
};

fn handleCommand(cmd: []const u8) CliResult {
    // Return CliResult.ok(0) for success
    // Return CliResult.err(error*variant) for failure
}
```

### Dependencies & Requirements

- **Zig**: 0.13.0 or later
- **Zero dependencies**: Uses only Zig stdlib
- **Single file**: Can be copied directly into projects

### Comparison: Result vs Error Union

| Feature | Error Union (`!T`) | Result Type |
|---------|-------------------|------------|
| Type safety | Error set only | Any error type |
| Explicit errors | No | Yes |
| Chainable | Limited | Yes |
| Pattern matching | Via `catch` | Via `match` |
| Transform errors | Via `catch` | Via `mapErr` |
| Combine results | Manual | `combine` |

**Use Error Union when:**

- Simple error handling needed
- Using Zig's idiomatic error propagation
- Errors are truly exceptional

**Use Result when:**

- Errors are expected and frequent
- Need functional composition
- Want fine-grained error control
- Prefer explicit error handling

### Strengths

✅ Rust-inspired Result type  
✅ Chainable functional composition  
✅ Pattern matching support  
✅ Type-safe error handling  
✅ Works with Zig error unions  
✅ Zero runtime overhead  
✅ Single file library (copy-paste friendly)  

### Considerations

- Requires understanding of Result pattern
- Function type specifications can be verbose
- No automatic error propagation (explicit `andThen` calls needed)

---

## Integration Strategy for Zig Starter Project

### Recommended Project Structure

```
zig-starter/
├── src/
│   ├── main.zig
│   ├── app.zig              # Application logic
│   ├── config.zig           # Configuration types
│   ├── cli/
│   │   ├── root.zig         # CLI entry point
│   │   ├── commands/
│   │   │   ├── server.zig
│   │   │   └── client.zig
│   │   └── prompts.zig      # Interactive prompts
│   ├── result.zig           # Copy from zig-error-handling (or import)
│   └── errors.zig           # Custom error types
├── tests/
│   ├── unit/
│   │   ├── app.test.zig
│   │   ├── config.test.zig
│   │   └── cli.test.zig
│   ├── integration/
│   │   └── end*to*end.test.zig
│   └── fixtures/
│       ├── config.test.json
│       └── sample.data
├── config/
│   ├── default.json
│   ├── development.json
│   └── production.json
├── build.zig
├── build.zig.zon
└── README.md
```

### Integration Checklist

#### Phase 1: Core Setup

- [ ] Add all four libraries as dependencies in `build.zig.zon`
- [ ] Configure `build.zig` to import each library
- [ ] Create basic test structure with `*.test.zig` files
- [ ] Add result.zig to src/ directory
- [ ] Create configuration types in `src/config.zig`

#### Phase 2: Testing Infrastructure

- [ ] Configure test runner with `zig build test`
- [ ] Add pre-commit hook to run tests
- [ ] Set up coverage collection
- [ ] Create test utilities and fixtures
- [ ] Document testing patterns

#### Phase 3: CLI Foundation

- [ ] Design command structure using type-safe API
- [ ] Implement main CLI entry point
- [ ] Add interactive prompts for user input
- [ ] Create configuration loading
- [ ] Add middleware for logging/timing

#### Phase 4: Error Handling

- [ ] Define custom error types using Result pattern
- [ ] Replace error unions with Result where appropriate
- [ ] Create error translation layer for user-friendly messages
- [ ] Implement error recovery strategies

#### Phase 5: Documentation

- [ ] Document CLI commands and options
- [ ] Provide configuration examples
- [ ] Create testing guide
- [ ] Add error handling guidelines
- [ ] Document library versions and features

### Practical Integration Example

**Complete starter app utilizing all four libraries:**

```zig
// src/main.zig
const std = @import("std");
const cli = @import("zig-cli");
const zig*config = @import("zig-config");
const result = @import("result");
const ztf = @import("zig-test-framework");

// Define configuration
const AppConfig = struct {
    app*name: []const u8 = "MyApp",
    port: u16 = 8080,
    debug: bool = false,
    environment: enum { dev, prod } = .dev,
};

// Define custom result type
const AppResult = result.Result(void, AppError);

const AppError = union(enum) {
    config*error: []const u8,
    io*error: std.fs.File.OpenError,
    invalid*input: []const u8,
};

// CLI command options
const ServerOptions = struct {
    host: []const u8 = "127.0.0.1",
    port: u16 = 8080,
};

fn serverAction(ctx: *cli.Context(ServerOptions)) !void {
    const stdout = std.io.getStdOut().writer();

    // Load configuration
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer * = gpa.deinit();
    const allocator = gpa.allocator();

    var config = try zig*config.loadConfig(AppConfig, allocator, .{
        .name = "myapp",
    });
    defer config.deinit(allocator);

    const host = ctx.get(.host);
    const port = ctx.get(.port);

    try stdout.print("Starting server at {s}:{d}\n", .{host, port});
    try stdout.print("App: {s}\n", .{config.value.app*name});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer * = gpa.deinit();
    const allocator = gpa.allocator();

    var cmd = try cli.command(ServerOptions).init(
        allocator,
        "myapp",
        "My application",
    );
    defer cmd.deinit();

    * = cmd.setAction(serverAction);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    try cli.Parser.init(allocator).parse(cmd.getCommand(), args[1..]);
}
```

---

## Library Feature Compatibility

### Can Libraries Work Together

| Combination | Compatible | Use Case |
|-------------|-----------|----------|
| **CLI + Prompts** | ✅ Yes | Interactive CLI with user input |
| **CLI + Config** | ✅ Yes | Load config, then CLI args override |
| **Config + Result** | ✅ Yes | Wrap config loading in Result |
| **CLI + Result** | ✅ Yes | Return Result from CLI actions |
| **Testing + Config** | ✅ Yes | Load test configs, mock in tests |
| **Testing + Result** | ✅ Yes | Test Result-returning functions |
| **Testing + Prompts** | ⚠️ Partial | Can test prompt logic (not interactive input) |
| **All Four** | ✅ Yes | Complete production application |

### Recommended Combinations by Use Case

**CLI Tool:**

- zig-cli (main framework)
- zig-config (configuration)
- zig-error-handling (error handling)
- zig-test-framework (testing)

**Library/SDK:**

- zig-error-handling (primary)
- zig-config (optional)
- zig-test-framework (essential)
- zig-cli (optional)

**Web Service:**

- zig-cli (for server commands)
- zig-config (for app configuration)
- zig-error-handling (for request handling)
- zig-test-framework (for testing)

**Daemon/Background Process:**

- zig-config (configuration management)
- zig-error-handling (error recovery)
- zig-test-framework (functional testing)
- zig-cli (optional, for management commands)

---

## Performance Characteristics

### Binary Size

- **zig-test-framework**: ~500KB (executable)
- **zig-cli**: ~200KB (executable)
- **zig-config**: ~100KB (with app)
- **zig-error-handling**: <10KB (minimal overhead)

### Startup Time

- **zig-cli**: <1ms
- **zig-config**: <5ms (with file discovery)
- **zig-test-framework**: <10ms (test discovery)
- **zig-error-handling**: Zero overhead (compile-time)

### Memory Usage

- **Interactive Prompts**: ~50KB per prompt
- **Test Registry**: ~200KB for 100 tests
- **Config Loading**: ~100KB for typical configs
- **Result Type**: Zero overhead (union type)

---

## Best Practices

### Testing

1. Use test discovery mode for automatic test detection
2. Group related tests in `describe()` blocks
3. Use mocks for external dependencies
4. Run tests with coverage on each commit
5. Keep test fixtures in `tests/fixtures/`

### CLI Development

1. Use structs to define command options (compile-time safe)
2. Leverage middleware for cross-cutting concerns
3. Provide sensible defaults in struct fields
4. Use type-safe prompts for user input
5. Document commands in struct field comments

### Configuration

1. Provide sensible defaults in code
2. Support environment variable overrides
3. Use file discovery for standard locations
4. Merge strategies wisely (smart for object arrays)
5. Validate configuration early in startup

### Error Handling

1. Define custom Result types for domain-specific errors
2. Use pattern matching for complex error handling
3. Chain operations with `andThen()` where possible
4. Convert to error unions only at boundaries
5. Provide user-friendly error messages

---

## Troubleshooting & Common Issues

### Test Framework

**Issue**: Memory leaks when running tests

- **Solution**: Always call `cleanupRegistry()` after `runTests()`

**Issue**: Tests hanging (timeout)

- **Solution**: Set explicit timeout with `itTimeout()` or `itAsyncTimeout()`

**Issue**: Coverage not generating

- **Solution**: Install kcov: `brew install kcov` or `apt-get install kcov`

### CLI

**Issue**: Prompt not working in CI

- **Solution**: Prompts require TTY; skip in CI or use environment variables

**Issue**: Command not recognized

- **Solution**: Check command name matches struct definition; verify parser initialization

### Configuration

**Issue**: Config file not found

- **Solution**: Check file naming and location against discovery paths; verify file permissions

**Issue**: Type mismatch in configuration

- **Solution**: Use correct types in struct definition; check environment variable format

### Error Handling

**Issue**: Unwrap panic

- **Solution**: Use `unwrapOr()` or `unwrapOrElse()` instead of `unwrap()` for fallible operations

**Issue**: Result type mismatch

- **Solution**: Ensure error type `E` is consistent across chain operations

---

## Version Compatibility

All libraries require **Zig 0.13.0 or later**.

As of October 2025:

- **zig-test-framework**: v0.1.0+ (mature, production-ready)
- **zig-cli**: v0.1.0+ (stable, recommended)
- **zig-config**: v0.1.0+ (stable, 20/20 tests passing)
- **zig-error-handling**: v0.1.0+ (stable, minimal API)

---

## Additional Resources

### Official Documentation

- zig-test-framework: README.md, docs/api.md, examples/
- zig-cli: README.md, examples/
- zig-config: README.md, examples/
- zig-error-handling: README.md, examples/

### Key Example Files

- **Test Framework**: `/examples/basic*test.zig`, `/examples/advanced*test.zig`, `/examples/async*tests.zig`
- **CLI**: `/examples/typed.zig`, `/examples/config.zig`, `/examples/prompts.zig`
- **Config**: `/examples/basic.zig`
- **Error Handling**: `/examples/basic.zig`

### Testing Examples

```bash
cd /path/to/library
zig build test                    # Run all tests
zig build examples               # Run example programs (test-framework)
zig build run-example            # Run example (error-handling)
```

---

## Summary

These four libraries form a comprehensive foundation for professional Zig applications:

1. **zig-test-framework** - Ensures code quality with comprehensive testing
2. **zig-cli** - Provides user-friendly command-line interfaces
3. **zig-config** - Manages configuration across environments
4. **zig-error-handling** - Enables functional, chainable error handling

Together, they provide:

- ✅ Production-grade testing infrastructure
- ✅ Type-safe configuration management
- ✅ Rich, interactive CLI experiences
- ✅ Functional error handling patterns
- ✅ Zero external dependencies
- ✅ Minimal startup time and binary size

Perfect for building professional Zig applications that are testable, configurable, user-friendly, and maintainable.
