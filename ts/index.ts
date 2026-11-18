/**
 * Bun binding for the zig-starter C ABI.
 *
 * The library is looked up in the local build first (`zig build lib` writes zig-out/), then in the
 * prebuilt/<platform>/ directory a release ships, so repository tests exercise the current Zig
 * source while published packages need no Zig toolchain.
 */
import { existsSync } from 'node:fs'
import { arch, platform } from 'node:os'
import { join } from 'node:path'
import { dlopen, FFIType, ptr, suffix } from 'bun:ffi'

const NAME = 'zig-starter'
const FILE = suffix === 'dll' ? `${NAME}.dll` : `lib${NAME}.${suffix}`

export function platformSlug(): string | null {
  const key = `${platform()}-${arch()}`
  const slugs: Record<string, string> = {
    'darwin-arm64': 'darwin-arm64',
    'darwin-x64': 'darwin-x64',
    'linux-arm64': 'linux-arm64',
    'linux-x64': 'linux-x64',
    'win32-x64': 'windows-x64',
    'freebsd-x64': 'freebsd-x64',
  }
  return slugs[key] ?? null
}

export function candidatePaths(root = join(import.meta.dir, '..')): string[] {
  const slug = platformSlug()
  const paths = [join(root, 'zig-out', 'lib', FILE), join(root, 'zig-out', 'bin', FILE)]
  if (slug) paths.push(join(root, 'prebuilt', slug, FILE))
  return paths
}

const symbols = {
  starter_version_v1: { args: [], returns: FFIType.u32 },
  starter_checksum_v1: { args: [FFIType.ptr, FFIType.u64, FFIType.ptr, FFIType.ptr], returns: FFIType.i32 },
} as const

function load() {
  const paths = candidatePaths()
  const found = paths.find(path => existsSync(path))
  if (!found) {
    throw new Error(`zig-starter: no native library for ${platform()}-${arch()}. Looked in:\n${paths.map(path => `  ${path}`).join('\n')}\nRun \`zig build lib\` or install a release that ships prebuilt/${platformSlug() ?? '<unsupported>'}.`)
  }
  return dlopen(found, symbols)
}

const lib = load()

export const Status = { ok: 0, invalidArgument: 1, emptyInput: 2, inputTooLarge: 3 } as const

export class StarterError extends Error {
  constructor(public readonly status: number) {
    super(`zig-starter call failed with status ${status}`)
  }
}

/** Library version as major * 10000 + minor * 100 + patch. */
export function version(): number {
  return lib.symbols.starter_version_v1()
}

// Reused out-parameter: calls are synchronous, so one buffer per module is safe.
const out = new BigUint64Array(1)
const options = new DataView(new ArrayBuffer(16))
options.setUint32(0, 16, true)

/** FNV-1a checksum. The input is passed to Zig without copying. */
export function checksum(input: Uint8Array | string, seed = 0n): bigint {
  const bytes = typeof input === 'string' ? new TextEncoder().encode(input) : input
  if (bytes.length === 0) throw new StarterError(Status.emptyInput)
  options.setBigUint64(8, seed, true)
  const status = lib.symbols.starter_checksum_v1(ptr(bytes), bytes.length, ptr(options), ptr(out))
  if (status !== Status.ok) throw new StarterError(status)
  return out[0]!
}
