//! Runtime CPU-variant dispatch, the pattern libraries use to ship one binary that runs the fastest
//! kernels the machine supports. Zig only uses instruction-set extensions the target enables at
//! compile time (std.crypto picks SHA-NI or ARMv8 SHA2 that way), so a portable baseline build gets
//! software paths. The fix: compile the hot code once per variant and pick one at startup.
const std = @import("std");
const builtin = @import("builtin");

pub const Variant = enum {
    baseline,
    x86_64_v2,
    x86_64_v3,
    x86_64_v3_sha,
    aarch64_crypto,
};

/// The best variant the running CPU supports.
pub fn detect() Variant {
    return switch (builtin.cpu.arch) {
        .x86_64 => detectX86(),
        .aarch64 => if (aarch64HasSha2()) .aarch64_crypto else .baseline,
        else => .baseline,
    };
}

fn cpuid(leaf: u32, subleaf: u32) [4]u32 {
    var eax: u32 = undefined;
    var ebx: u32 = undefined;
    var ecx: u32 = undefined;
    var edx: u32 = undefined;
    asm volatile ("cpuid"
        : [eax] "={eax}" (eax),
          [ebx] "={ebx}" (ebx),
          [ecx] "={ecx}" (ecx),
          [edx] "={edx}" (edx),
        : [leaf] "{eax}" (leaf),
          [subleaf] "{ecx}" (subleaf),
    );
    return .{ eax, ebx, ecx, edx };
}

fn detectX86() Variant {
    if (builtin.cpu.arch != .x86_64) return .baseline;
    const leaf1 = cpuid(1, 0);
    const ecx1 = leaf1[2];
    const has_v2 = (ecx1 >> 0) & 1 == 1 and // sse3
        (ecx1 >> 9) & 1 == 1 and // ssse3
        (ecx1 >> 19) & 1 == 1 and // sse4.1
        (ecx1 >> 20) & 1 == 1 and // sse4.2
        (ecx1 >> 23) & 1 == 1; // popcnt
    if (!has_v2) return .baseline;
    const leaf7 = cpuid(7, 0);
    const ebx7 = leaf7[1];
    const has_avx = (ecx1 >> 28) & 1 == 1;
    const has_v3 = has_avx and (ebx7 >> 5) & 1 == 1 and (ebx7 >> 3) & 1 == 1 and (ebx7 >> 8) & 1 == 1; // avx2, bmi1, bmi2
    if (!has_v3) return .x86_64_v2;
    const has_sha = (ebx7 >> 29) & 1 == 1;
    return if (has_sha) .x86_64_v3_sha else .x86_64_v3;
}

fn aarch64HasSha2() bool {
    if (builtin.cpu.arch != .aarch64) return false;
    switch (builtin.os.tag) {
        // Every Apple silicon CPU implements the ARMv8 crypto extensions.
        .macos, .ios, .tvos, .watchos, .visionos => return true,
        .linux => {
            const HWCAP_SHA2: usize = 1 << 6;
            return std.os.linux.getauxval(std.elf.AT_HWCAP) & HWCAP_SHA2 != 0;
        },
        else => return std.Target.aarch64.featureSetHas(builtin.cpu.features, .sha2),
    }
}

test detect {
    const variant = detect();
    // A variant must never claim more than the compile-time target guarantees is false; it can
    // only claim at least the baseline.
    _ = @tagName(variant);
    if (builtin.cpu.arch == .x86_64 and std.Target.x86.featureSetHas(builtin.cpu.features, .avx2)) {
        try std.testing.expect(variant == .x86_64_v3 or variant == .x86_64_v3_sha);
    }
}
