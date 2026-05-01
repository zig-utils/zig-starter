# Contributing to zig-starter

Thank you for your interest in contributing to zig-starter! This document provides guidelines and instructions for contributing.

## Getting Started

1. **Fork the repository**

   ```bash
# Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/zig-starter.git
   cd zig-starter
   ```

2. **Install dependencies**

   ```bash
   pantry install
   ```

3. **Create a feature branch**

   ```bash
   git checkout -b feature/my-feature
# or
   git checkout -b fix/my-bugfix
   ```

## Development Guidelines

### Code Style

- Follow Zig's official style guide
- Use 4 spaces for indentation
- Maximum line length: 100 characters
- Use meaningful variable and function names
- Add documentation comments for public APIs

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

**Examples:**

```bash
git commit -m "feat: add JSON parsing support"
git commit -m "fix: resolve memory leak in processData"
git commit -m "docs: update README with new examples"
git commit -m "test: add tests for error handling"
```

### Testing

- Write tests for all new features
- Ensure all tests pass before submitting PR
- Aim for high test coverage

```bash
# Run tests
zig build test

# Run specific test
zig build test --test-filter "my_test_name"
```

### Pull Request Process

1. **Update your branch**

   ```bash
   git fetch origin
   git rebase origin/main
   ```

2. **Run tests and formatting**

   ```bash
   zig build test
   zig fmt src/
   ```

3. **Push your changes**

   ```bash
   git push origin feature/my-feature
   ```

4. **Create Pull Request**
   - Provide clear description of changes
   - Reference any related issues
   - Include screenshots for UI changes
   - Ensure CI checks pass

5. **Address review feedback**
   - Make requested changes
   - Push updates to the same branch
   - Re-request review when ready

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe how you tested the changes

## Checklist

- [ ] Tests pass locally
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Commit messages follow convention

```

## Building and Testing

### Build Commands

```bash
# Development build
zig build

# Release build
zig build -Doptimize=ReleaseFast

# Clean build
rm -rf zig-cache zig-out && zig build
```

### Test Commands

```bash
# All tests
zig build test

# Verbose output
zig build test --verbose

# Filter tests
zig build test --test-filter "StarterLib"
```

## Adding Dependencies

1. **Update package.jsonc**

   ```jsonc
   {
     "dependencies": {
       "new-dep": "~/Code/new-dep"
     }
   }
   ```

2. **Install dependencies**

   ```bash
   pantry install
   ```

3. **Update build.zig**

   ```zig
   const new_dep_mod = b.addModule("new-dep", .{
       .root_source_file = b.path("../new-dep/src/root.zig"),
       .target = target,
   });
   ```

## Documentation

- Update README.md for user-facing changes
- Add inline documentation for public APIs
- Include code examples where helpful
- Keep CONTRIBUTING.md up to date

### Documentation Style

```zig
/// Brief description of the function
///
/// Longer description with usage examples:
///
/// ```zig
/// const result = processData("input");
/// if (result.isOk()) {
///     std.debug.print("{s}\n", .{result.unwrap()});
/// }
/// ```
///
/// @param data Input data to process
/// @return Result containing processed data or error
pub fn processData(data: []const u8) Result([]u8, ProcessError) {
    // ...
}
```

## Release Process

1. **Update version**

   ```bash
   bump minor --changelog
   ```

2. **Review CHANGELOG.md**
   - Ensure all changes are documented
   - Edit if needed for clarity

3. **Create release**
   - Tag is created automatically by zig-bump
   - Push to trigger CI/CD

   ```bash
   git push --follow-tags
   ```

## Getting Help

- **Issues**: Check existing issues or create a new one
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Refer to README.md and inline docs

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on the code, not the person

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to zig-starter! 🎉
