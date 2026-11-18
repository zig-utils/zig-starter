import { describe, expect, it } from 'bun:test'
import { checksum, StarterError, version } from './index'

describe('zig-starter binding', () => {
  it('reports the library version', () => {
    expect(version()).toBe(200)
  })

  it('computes the checksum without copying', () => {
    expect(checksum('a')).toBe(0xAF63DC4C8601EC8Cn)
    expect(checksum(new Uint8Array([0x61]))).toBe(0xAF63DC4C8601EC8Cn)
  })

  it('applies the seed option', () => {
    expect(checksum('a', 1n)).toBe(0xAF63DC4C8601EC8Cn ^ 1n)
  })

  it('maps status codes to errors', () => {
    expect(() => checksum('')).toThrow(StarterError)
  })
})
