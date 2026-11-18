# Changelog

## v0.2.0 - 2026-11-17

- ci: make npm publishing opt-in per repository (92c62a3)
- fix: create the benchmark result directory before writing to it (c27d60a)
- feat: add a zig-bench benchmark step that writes JSON results (219784a)
- docs: rewrite the README and setup guide for the library template (0b3ddfc)
- ci: publish prebuilt libraries for six platforms on release (7537d2c)
- ci: test on Linux, macOS and Windows and build every CPU variant (a5c5a23)
- feat: add a bun:ffi binding template with prebuilt lookup (0866611)
- feat: build static and shared C ABI libraries and test every module (37233ba)
- chore: pin Zig 0.17.0-dev.1857 and declare dependencies through the pantry registry (bfa1809)
- fix: stop tracking the compiled test binary (3e8a681)
- docs: update Discord community links (b1951f0)
- docs: add Community section to README (f80341b)
- chore(deps): declare bun ^1.3.14 in deps.yaml (cbb6c0c)
- chore: ignore pantry directory (7368582)
- chore(ci): bump actions/checkout to v6, actions/cache to v5 (7b4fa12)
- chore: refresh bun.lock and apply pickier --fix (fb67afc)
- ci: add CI workflow mirroring the other zig-utils repos (f9d8300)
- refactor: migrate to zig 0.17-dev APIs (12980b3)

