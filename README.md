# zig-starter

A template for Zig libraries that need to be usable from every other language. A library started from it begins with:

- **A library module** other Zig packages import, plus an executable.
- **A versioned C ABI:** `src/capi.zig` and `include/zig_starter.h`, with `_v1` symbols, size-prefixed option structs and status codes. It builds as a static and a shared library (`zig build lib`) and is checked by a C smoke test.
- **A Bun binding** (`ts/index.ts`) over bun:ffi. It loads the local build first and a shipped prebuilt library second.
- **Releases** with prebuilt shared libraries for six platforms, published to the pantry registry and npm, so consumers never need Zig installed.
- **Tests:**
  - every module tested
  - deterministic fuzzing (`zig build fuzz`) plus Zig's coverage-guided fuzzer (`zig build test --fuzz`)
  - a ReleaseSafe test run
- **CPU-variant dispatch** (`src/cpu.zig`), so hot kernels can use SHA-NI, AVX2 or ARMv8 crypto on machines that have them while still shipping one binary.
- **CI** on Linux, macOS and Windows, a CPU-variant build matrix, a format check, a check that the toolchain pin agrees everywhere, and a check that no binary is ever committed.

## Requirements

- Zig `0.17.0-dev.1857+3c46da14d`. `pantry install` provides it from `deps.yaml`; pantry mirrors Zig dev builds, so the pin keeps working after ziglang.org rotates them out.
- Bun 1.3.14 or newer, for the binding and its tests.

## Commands

```sh
zig build                       # library module and executable
zig build run -- "some input"   # run the executable
zig build test                  # every Zig module plus the C smoke test
zig build test -Doptimize=safe  # the same with ReleaseSafe
zig build lib -Doptimize=fast   # zig-out/lib: static + shared library, zig-out/include: header
zig build fuzz -Dfuzz-iterations=100000 -Dfuzz-seed=1
zig build bench -- zig-out/bench.json   # zig-bench benchmarks, JSON results
bun test ts                     # the Bun binding against zig-out
bun scripts/check-pin.ts        # the Zig pin agrees across zon, deps.yaml, CI and this README
```

## Starting a library from the template

See [docs/SETUP.md](docs/SETUP.md).

## Dependencies

Declare Zig dependencies in `build.zig.zon` as pantry registry tarballs with a hash, never as relative paths. A fresh clone then builds without sibling checkouts:

```sh
zig fetch --save https://registry.pantry.dev/zig/packages/zig-regex/0.2.1/tarball
```

If a library you need is not in the registry yet, publish it there rather than adding a path dependency.

## License

MIT
