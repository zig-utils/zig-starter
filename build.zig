const std = @import("std");

/// The package name used for the libraries, the executable and the C header.
const name = "zig-starter";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // The library module other Zig packages import as `starter`.
    const lib_mod = b.addModule("starter", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Executable.
    const exe = b.addExecutable(.{
        .name = name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "starter", .module = lib_mod }},
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();
    b.step("run", "Run the executable").dependOn(&run_cmd.step);

    // C ABI: a static and a shared library built from src/capi.zig, plus the header.
    const static_lib = b.addLibrary(.{
        .linkage = .static,
        .name = name,
        .root_module = capiModule(b, target, optimize, lib_mod),
    });
    const shared_lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = name,
        .root_module = capiModule(b, target, optimize, lib_mod),
    });
    const lib_step = b.step("lib", "Build the static and shared C ABI libraries and install the header");
    lib_step.dependOn(&b.addInstallArtifact(static_lib, .{}).step);
    lib_step.dependOn(&b.addInstallArtifact(shared_lib, .{}).step);
    lib_step.dependOn(&b.addInstallHeaderFile(b.path("include/zig_starter.h"), "zig_starter.h").step);

    // Tests: every Zig module, plus a C program that links the static library through the header.
    const test_step = b.step("test", "Run all tests");
    for ([_][]const u8{ "src/lib.zig", "src/capi.zig", "src/cpu.zig", "src/main.zig" }) |path| {
        const mod = b.createModule(.{
            .root_source_file = b.path(path),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "starter", .module = lib_mod }},
        });
        test_step.dependOn(&b.addRunArtifact(b.addTest(.{ .root_module = mod })).step);
    }

    const c_smoke = b.addExecutable(.{
        .name = "c-smoke",
        .root_module = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = true }),
    });
    c_smoke.root_module.addCSourceFile(.{ .file = b.path("tests/c/smoke.c"), .flags = &.{ "-std=c99", "-Wall", "-Wextra", "-Werror" } });
    c_smoke.root_module.addIncludePath(b.path("include"));
    c_smoke.root_module.linkLibrary(static_lib);
    test_step.dependOn(&b.addRunArtifact(c_smoke).step);

    // Deterministic fuzzing: `zig build fuzz -Dfuzz-iterations=100000 -Dfuzz-seed=1`.
    // The same target also runs under Zig's coverage-guided fuzzer: `zig build test --fuzz`.
    const fuzz_exe = b.addExecutable(.{
        .name = "fuzz",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/fuzz.zig"),
            .target = target,
            .optimize = if (optimize == .debug) .safe else optimize,
            .imports = &.{.{ .name = "starter", .module = lib_mod }},
        }),
    });
    const run_fuzz = b.addRunArtifact(fuzz_exe);
    const fuzz_iterations = b.option(usize, "fuzz-iterations", "Deterministic fuzz case count") orelse 10_000;
    const fuzz_seed = b.option(u64, "fuzz-seed", "Deterministic fuzz seed") orelse 0x5eed_5eed;
    run_fuzz.addArgs(&.{ b.fmt("{d}", .{fuzz_iterations}), b.fmt("{d}", .{fuzz_seed}) });
    b.step("fuzz", "Run deterministic fuzz cases").dependOn(&run_fuzz.step);

    // Benchmarks with zig-bench: `zig build bench -- zig-out/bench.json`. The dependency is lazy,
    // so it is only fetched when this step runs.
    const bench_step = b.step("bench", "Run benchmarks and write a JSON result file");
    if (b.lazyDependency("bench", .{ .target = target, .optimize = .fast })) |bench_dep| {
        const bench_exe = b.addExecutable(.{
            .name = "bench",
            .root_module = b.createModule(.{
                .root_source_file = b.path("bench/main.zig"),
                .target = target,
                .optimize = .fast,
                .imports = &.{
                    .{ .name = "starter", .module = lib_mod },
                    .{ .name = "bench", .module = bench_dep.module("bench") },
                },
            }),
        });
        const run_bench = b.addRunArtifact(bench_exe);
        run_bench.addPassthruArgs();
        bench_step.dependOn(&run_bench.step);
    }
}

fn capiModule(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.lang.Optimize, lib_mod: *std.Build.Module) *std.Build.Module {
    return b.createModule(.{
        .root_source_file = b.path("src/capi.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "starter", .module = lib_mod }},
    });
}
