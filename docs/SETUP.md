# Starting a library from zig-starter

## 1. Create the repository

```sh
git clone --depth 1 https://github.com/zig-utils/zig-starter.git zig-mylib
cd zig-mylib
rm -rf .git && git init -b main
pantry install            # the pinned Zig and Bun from deps.yaml
```

## 2. Rename

| Where | Change |
|---|---|
| `build.zig` | `name` (`zig-starter`) becomes the library and executable name; the module name `starter` is what Zig importers write |
| `build.zig.zon` | `.name`, `.version`, and run `zig build` once: it prints the new `.fingerprint` to paste in |
| `include/zig_starter.h` | file name, include guard and the `starter_` symbol prefix |
| `src/capi.zig` | the `starter_*_v1` export names |
| `ts/index.ts` | `NAME` and the `symbols` table |
| `package.json` | `name`, `description`, `repository` |
| `.github/workflows/release.yml` | the library file names in the build list and the release asset names |

## 3. Write the library

- Put the Zig API in `src/lib.zig` (and the files it imports). Keep it free of global state.
- Bound every input that can come from outside, as `max_input_len` does in the sample.
- Add tests next to the code. `zig build test` runs every module listed in `build.zig`, so add new root files there.

## 4. Expose the C ABI

Each function in `src/capi.zig`:
- takes pointers and lengths
- returns a status enum
- writes results through out-pointers
- carries a `_vN` suffix

When a signature has to change, add `_v2` beside `_v1` and keep the old one working. Option structs begin with `size` so fields can be appended. Anything allocated here must be freed through a function exported from here.

Mirror every export in the header, then extend `tests/c/smoke.c`.

## 5. Bind it for Bun

Add each export to `symbols` in `ts/index.ts`, with a typed wrapper:
- pass input `Uint8Array`s with `ptr()`, which copies nothing
- reuse out-parameter buffers
- turn non-zero statuses into errors

Keep JavaScript callbacks out of hot paths. `bun test ts` runs against `zig build lib` output.

## 6. Fuzz and benchmark

- Add a block per parser or entry point to `tools/fuzz.zig`. Run it with `zig build fuzz -Dfuzz-iterations=100000 -Dfuzz-seed=1`. The same seed always produces the same cases.
- For coverage-guided fuzzing, add a `std.testing.fuzz` test and run `zig build test --fuzz`.

## 7. CPU variants (only for hot kernels)

`src/cpu.zig` detects the best variant at runtime. Compile the hot code once per variant (for example with `-Dcpu=x86_64_v3+sha`), dispatch on `cpu.detect()` at startup, and keep the CI variant matrix building each one.

## 8. Release

1. Bump with `bun run release` (or `release:minor`, `release:major`). This tags `vX.Y.Z`.
2. The release workflow then:
   - builds the shared library for linux x64 and arm64 (glibc 2.17), darwin x64 and arm64, windows x64 and freebsd x64
   - copies each into `prebuilt/<slug>/`
   - checks that the binding loads the Linux build
   - creates the GitHub release with checksums
   - publishes to the pantry registry and to npm

npm publishing uses trusted publishing (OIDC). An E404 on publish means authentication, not a missing package.
