# Zig Starter - Setup Guide

This guide will help you set up and use the zig-starter template for your new projects.

## Project Status

✅ **Ready to Use!** - The starter template is fully configured and tested with Zig 0.15.1

## What's Included

### Core Files

- `build.zig` - Simple build configuration (no external dependencies required)
- `build.zig.full` - Full build configuration with all dependencies
- `build.zig.zon` - Zig package manifest
- `package.jsonc` - Pantry package manager configuration
- `src/main.zig` - Simple CLI entry point
- `src/lib.zig` - Core library with tests
- `src/main.full.zig` - Full-featured CLI (requires dependencies)
- `src/lib.full.zig` - Full-featured library (requires dependencies)

### Documentation

- `README.md` - Complete usage guide
- `CONTRIBUTING.md` - Contribution guidelines
- `SETUP.md` - This file
- `LICENSE` - MIT License

## Quick Start (Simple Version)

The template works out-of-the-box without any dependencies:

```bash
# Build the project
zig build

# Run the application
zig build run

# Run tests
zig build test
```

**Output:**

```
Zig Starter - Simple Version
=============================

Library initialized with max_retries = 3

Processing: "Hello, Zig!"
Result: "Hello, Zig!"
```

## Full Version Setup (With All Dependencies)

To use the full version with all the zig-utils libraries:

### Step 1: Install Pantry Package Manager

If you haven't already, install Pantry:

```bash
cd ~/Code/pantry
zig build -Doptimize=ReleaseFast
sudo cp zig-out/bin/pantry /usr/local/bin/
```

### Step 2: Install Dependencies

```bash
cd ~/Code/zig-starter
pantry install
```

This will install:

- `zig-cli` - Type-safe CLI framework
- `zig-config` - Configuration management
- `zig-error-handling` - Result type for functional error handling
- `zig-test-framework` - Jest/Vitest-style testing framework
- `zig-bump` - Version bumping and changelog generation

### Step 3: Switch to Full Build

```bash
# Backup simple version
mv build.zig build.zig.simple
mv src/main.zig src/main.simple.zig
mv src/lib.zig src/lib.simple.zig

# Activate full version
mv build.zig.full build.zig
mv src/main.full.zig src/main.zig
mv src/lib.full.zig src/lib.zig
```

### Step 4: Build and Run

```bash
# Build
zig build

# Run with help
zig build run -- --help

# Run config command
zig build run -- config --show

# Process a file (create a test file first)
echo "test data" > input.txt
zig build run -- process input.txt -o output.txt
```

## Project Structure

```
zig-starter/
├── build.zig              # Simple build (active)
├── build.zig.full         # Full build with dependencies
├── build.zig.zon          # Zig package manifest
├── package.jsonc          # Pantry dependencies
├── README.md              # Main documentation
├── SETUP.md               # This file
├── CONTRIBUTING.md        # Contribution guide
├── LICENSE                # MIT license
├── .gitignore             # Git ignore rules
├── src/
│   ├── main.zig          # Simple CLI (active)
│   ├── lib.zig           # Simple library (active)
│   ├── main.full.zig     # Full CLI with dependencies
│   └── lib.full.zig      # Full library with dependencies
└── zig-out/              # Build output (generated)
    └── bin/
        └── zig-starter   # Compiled executable
```

## Verification

### Check Build

```bash
$ zig build
# Should complete without errors
```

### Check Tests

```bash
$ zig build test
# All tests passing
```

### Check Executable

```bash
$ zig build run
Zig Starter - Simple Version
=============================
...
```

## Creating a New Project

To use this template for a new project:

```bash
# Copy the template
cp -r ~/Code/zig-starter ~/Code/my-new-project
cd ~/Code/my-new-project

# Clean build artifacts
rm -rf zig-out zig-cache

# Update package names
# Edit build.zig.zon and change .name
# Edit package.jsonc and change "name"

# Initialize git (if needed)
git init
git add .
git commit -m "Initial commit from zig-starter template"

# Build and test
zig build
zig build test
zig build run
```

## Customization Guide

### 1. Change Project Name

**build.zig.zon:**

```zig
.{
    .name = .myproject,  // Change this
    .version = "0.1.0",
    .fingerprint = 0xYOURFINGERPRINT,  // Generate new: zig build
    ...
}
```

**package.jsonc:**

```jsonc
{
  "name": "my-project",  // Change this
  ...
}
```

**build.zig:**

```zig
const exe = b.addExecutable(.{
    .name = "my-project",  // Change this
    ...
});
```

### 2. Add New Dependencies

**Edit package.jsonc:**

```jsonc
{
  "dependencies": {
    "existing-dep": "~/Code/existing-dep",
    "new-dep": "~/Code/new-dep"  // Add this
  }
}
```

**Install:**

```bash
pantry install
```

**Update build.zig:**

```zig
const new_dep_mod = b.addModule("new-dep", .{
    .root_source_file = b.path("../new-dep/src/root.zig"),
    .target = target,
});

// Add to imports
lib_mod.addImport("new-dep", new_dep_mod);
```

### 3. Add New Source Files

```bash
# Create new module
touch src/mymodule.zig

# Import in main.zig
# const mymodule = @import("mymodule.zig")
```

## Version Management

Using zig-bump (after installing dependencies):

```bash
# Bump patch version (0.1.0 → 0.1.1)
bump patch --changelog

# Bump minor version (0.1.0 → 0.2.0)
bump minor --changelog

# Bump major version (0.1.0 → 1.0.0)
bump major --changelog
```

## Troubleshooting

### Build Fails with "file not found"

**Problem:** Dependencies not installed

**Solution:**

```bash
pantry install
# Or use simple version (build.zig.simple)
```

### Wrong Zig Version

**Problem:** Requires Zig 0.15.1+

**Solution:**

```bash
# Update Zig using pantry
pantry install ziglang.org@0.15.1

# Or download manually
# https://ziglang.org/download/
```

### Module Not Found

**Problem:** Incorrect path in build.zig

**Solution:** Check relative paths match your dependency locations:

```zig
// Correct path to dependency
.root_source_file = b.path("../zig-cli/src/root.zig"),
```

## Next Steps

1. ✅ Verify the simple version works (`zig build run`)
2. ✅ Read the README.md for detailed usage
3. ⏭️ Install dependencies when ready (`pantry install`)
4. ⏭️ Switch to full version for advanced features
5. ⏭️ Customize for your project needs

## Resources

- [Zig Language Documentation](https://ziglang.org/documentation/master/)
- [Pantry Package Manager](~/Code/pantry)
- [zig-cli](~/Code/zig-cli)
- [zig-config](~/Code/zig-config)
- [zig-error-handling](~/Code/zig-error-handling)
- [zig-test-framework](~/Code/zig-test-framework)
- [zig-bump](~/Code/zig-bump)

## Support

If you encounter issues:

1. Check this SETUP.md file
2. Read README.md for usage examples
3. Review CONTRIBUTING.md for development guidelines
4. Check the source repositories for each dependency

---

**Happy coding with Zig!** 🚀
