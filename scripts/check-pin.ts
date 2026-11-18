// Fails when the Zig version pin disagrees between build.zig.zon, deps.yaml, CI and the README.
import { readFileSync } from 'node:fs'

const read = (path: string) => readFileSync(new URL(`../${path}`, import.meta.url), 'utf8')
const found: Record<string, string | undefined> = {
  'build.zig.zon': read('build.zig.zon').match(/minimum_zig_version = "([^"]+)"/)?.[1],
  'deps.yaml': read('deps.yaml').match(/^\s*zig:\s*(\S+)/m)?.[1]?.split('+')[0],
  '.github/workflows/ci.yml': read('.github/workflows/ci.yml').match(/ZIG_VERSION:\s*'?([^'\s]+)/)?.[1]?.split('+')[0],
  'README.md': read('README.md').match(/Zig `?(0\.\d+\.\d+-dev\.\d+)/)?.[1],
}
const versions = new Set(Object.values(found))
if (versions.size !== 1 || versions.has(undefined)) {
  console.error('Zig pin mismatch:')
  for (const [file, version] of Object.entries(found)) console.error(`  ${file}: ${version ?? 'not found'}`)
  process.exit(1)
}
console.log(`Zig pin ${[...versions][0]} agrees across ${Object.keys(found).length} files`)
