# Zig Starter

A production-ready Zig starter template for building libraries and CLI applications. This template integrates essential Zig utilities and follows best practices for project structure, dependency management, testing, and version control.

## Features

- **Modern Dependency Management** - Uses [Pantry](https://github.com/stacksjs/pantry) for managing local and remote dependencies
- **CLI Framework** - [zig-cli](../zig-cli) with type-safe argument parsing and interactive prompts
- **Configuration Management** - [zig-config](../zig-config) with multi-source loading and type safety
- **Error Handling** - [zig-error-handling](../zig-error-handling) with Rust-inspired Result types
- **Testing Framework** - [zig-test-framework](../zig-test-framework) with Jest/Vitest-style syntax
- **Version Management** - [zig-bump](../zig-bump) for automatic version bumping and changelog generation
- **Production Ready** - Optimized build configuration for multiple platforms

## Requirements

- Zig 0.15.1 or later
- Pantry package manager
- Git

## Quick Start

### 1. Clone or Copy This Template

```bash
# Copy to a new project
cp -r zig-starter my-new-project
cd my-new-project
```

### 2. Install Dependencies

```bash
# Using Pantry package manager
pantry install

# This will install
# - zig-cli
# - zig-config
# - zig-error-handling
# - zig-test-framework
# - zig-bump
```

### 3. Build the Project

```bash
# Build the project
zig build

# Or using package.jsonc scripts
pantry run build
```

### 4. Run Tests

```bash
# Run all tests
zig build test

# Or using package.jsonc scripts
pantry run test
```

### 5. Run the Application

```bash
# Run with default command
zig build run

# Run with arguments
zig build run -- --help
zig build run -- config --show
zig build run -- process input.txt -o output.txt
```

## Project Structure

```
zig-starter/
├── build.zig              # Build configuration
├── build.zig.zon          # Zig package manifest
├── package.jsonc          # Pantry dependency configuration
├── README.md              # This file
├── CHANGELOG.md           # Auto-generated changelog (via zig-bump)
├── src/
│   ├── main.zig          # CLI entry point
│   └── lib.zig           # Core library functionality
└── zig-out/              # Build output (generated)
    ├── bin/
    └── lib/
```

## Configuration

### package.jsonc

The `package.jsonc` file manages your dependencies and build configuration:

```jsonc
{
  "name": "zig-starter",
  "version": "0.1.0",

  "dependencies": {
    // Local development paths (fast iteration)
    "zig-cli": "~/Code/zig-cli",
    "zig-config": "~/Code/zig-config",
    // ... etc
  },

  "scripts": {
    "build": "zig build",
    "test": "zig build test",
    "run": "zig build run"
  }
}
```

### Switching to Production Dependencies

For production releases, update `package.jsonc` to use GitHub repositories:

```jsonc
{
  "dependencies": {
    // Production (GitHub releases)
    "stacksjs/zig-cli": "latest",
    "stacksjs/zig-config": "latest",
    "stacksjs/zig-error-handling": "latest",
    "stacksjs/zig-test-framework": "latest",
    "stacksjs/zig-bump": "latest"
  }
}
```

## Usage Examples

### Basic Library Usage

```zig
const std = @import("std");
const starter = @import("starter");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lib = try starter.StarterLib.init(allocator);
    defer lib.deinit();

    const result = lib.processData("Hello, Zig!");
    if (result.isOk()) {
        const data = result.unwrap();
        defer allocator.free(data);
        std.debug.print("Processed: {s}\n", .{data});
    }
}
```

### CLI Command Usage

```bash
# Show version
./zig-out/bin/zig-starter --version

# Show configuration
./zig-out/bin/zig-starter config --show

# Process a file
./zig-out/bin/zig-starter process input.txt -o output.txt

# Enable verbose output
./zig-out/bin/zig-starter --verbose process data.txt
```

### Error Handling with Result Type

```zig
const errors = @import("zig-error-handling");

fn riskyOperation() errors.Result(i32, error{Failed}) {
    if (some_condition) {
        return errors.Result(i32, error{Failed}).ok(42);
    } else {
        return errors.Result(i32, error{Failed}).err(error.Failed);
    }
}

// Usage
const result = riskyOperation();
if (result.isOk()) {
    std.debug.print("Success: {}\n", .{result.unwrap()});
} else {
    std.debug.print("Error: {}\n", .{result.unwrapErr()});
}
```

### Writing Tests

```zig
const testing = @import("zig-test-framework");

test "example test" {
    const value = 42;
    try testing.expect(value == 42);
    try testing.expectEqual(42, value);
}

test "string comparison" {
    const str = "hello";
    try testing.expectEqualStrings("hello", str);
}

test "error handling" {
    try testing.expectError(error.EmptyData, someFunction());
}
```

## Development Workflow

### Adding New Features

1. **Create feature branch**

   ```bash
   git checkout -b feature/my-feature
   ```

2. **Implement and test**

   ```bash
# Edit source files
   vim src/lib.zig

# Run tests continuously
   zig build test
   ```

3. **Commit changes**

   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

### Version Management

This template uses [zig-bump](../zig-bump) for version management:

```bash
# Bump patch version (0.1.0 → 0.1.1)
pantry run bump:patch

# Bump minor version (0.1.0 → 0.2.0)
pantry run bump:minor

# Bump major version (0.1.0 → 1.0.0)
pantry run bump:major

# These commands will
# 1. Update version in build.zig.zon
# 2. Generate CHANGELOG.md entry
# 3. Create git commit
# 4. Create git tag
# 5. Push to remote (if configured)
```

### Manual Version Bump

```bash
# Without pantry scripts
bump patch --changelog
bump minor --changelog --no-push
bump major --dry-run
```

## Build Options

### Optimize for Release

```bash
# Build with optimizations
zig build -Doptimize=ReleaseFast

# Build for multiple targets
zig build -Dtarget=x86_64-linux
zig build -Dtarget=aarch64-macos
zig build -Dtarget=x86_64-windows
```

### Build Library Only

```bash
zig build install
# Output: zig-out/lib/libzig-starter.a
```

### Build Executable Only

```bash
zig build install
# Output: zig-out/bin/zig-starter
```

## Testing

### Run All Tests

```bash
zig build test
```

### Run Specific Test

```bash
# Filter by test name
zig build test --test-filter "processData"
```

### Test with Coverage (if enabled)

```bash
zig build test -- --coverage
```

## Customization

### 1. Update Project Name

Edit `build.zig.zon`:

```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    // ...
}
```

Edit `package.jsonc`:

```jsonc
{
  "name": "my-project",
  // ...
}
```

### 2. Add Dependencies

Edit `package.jsonc`:

```jsonc
{
  "dependencies": {
    "my-new-dep": "~/Code/my-new-dep"
  }
}
```

Then run:

```bash
pantry install
```

Update `build.zig` to add the module:

```zig
const my_dep_mod = b.addModule("my-dep", .{
    .root_source_file = b.path("../my-new-dep/src/root.zig"),
    .target = target,
});

// Add to imports
lib_mod.addImport("my-dep", my_dep_mod);
```

### 3. Add CLI Commands

Edit `src/main.zig`:

```zig
var new_cmd = try app.addCommand("mycommand", .{
    .description = "My new command",
    .handler = myCommandHandler,
});

try new_cmd.addArgument("arg", .{
    .description = "Command argument",
    .required = true,
});
```

## Deployment

### Building for Production

```bash
# Update dependencies to use GitHub releases
# Edit package.jsonc to reference GitHub repos

# Install production dependencies
pantry install --frozen-lockfile

# Build optimized binary
zig build -Doptimize=ReleaseFast

# Binary is in: zig-out/bin/zig-starter
```

### Cross-Compilation

```bash
# Linux
zig build -Dtarget=x86_64-linux -Doptimize=ReleaseFast

# macOS (Intel)
zig build -Dtarget=x86_64-macos -Doptimize=ReleaseFast

# macOS (Apple Silicon)
zig build -Dtarget=aarch64-macos -Doptimize=ReleaseFast

# Windows
zig build -Dtarget=x86_64-windows -Doptimize=ReleaseFast
```

## Troubleshooting

### Build Errors

```bash
# Clean build cache
rm -rf zig-cache zig-out

# Rebuild
zig build
```

### Dependency Issues

```bash
# Reinstall dependencies
rm -rf .pantry node_modules
pantry install

# Check dependency status
pantry list
```

### Module Not Found

Ensure `build.zig` has the correct relative paths to dependencies:

```zig
.root_source_file = b.path("../zig-cli/src/root.zig"),
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes (follow conventional commits)
4. Push to the branch
5. Create a Pull Request

## License

MIT License - feel free to use this template for any project.

## Resources

- [Zig Documentation](https://ziglang.org/documentation/master/)
- [Pantry Package Manager](https://github.com/stacksjs/pantry)
- [zig-cli Documentation](../zig-cli)
- [zig-config Documentation](../zig-config)
- [zig-error-handling Documentation](../zig-error-handling)
- [zig-test-framework Documentation](../zig-test-framework)
- [zig-bump Documentation](../zig-bump)

## Support

For issues, questions, or contributions, please open an issue in the repository.

---

**Happy Coding with Zig!** 🚀
