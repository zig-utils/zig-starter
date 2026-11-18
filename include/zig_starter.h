/*
 * zig-starter C ABI.
 *
 * Every symbol carries a version suffix. A breaking change adds a new suffix next to the old
 * symbol rather than changing it. Option structs begin with their own size so fields can be
 * appended without breaking older callers.
 */
#ifndef ZIG_STARTER_H
#define ZIG_STARTER_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum zig_starter_status {
  ZIG_STARTER_OK = 0,
  ZIG_STARTER_INVALID_ARGUMENT = 1,
  ZIG_STARTER_EMPTY_INPUT = 2,
  ZIG_STARTER_INPUT_TOO_LARGE = 3
} zig_starter_status;

typedef struct zig_starter_options {
  /* Set to sizeof(zig_starter_options). */
  uint32_t size;
  /* XOR applied to the checksum. */
  uint64_t seed;
} zig_starter_options;

/* Library version encoded as major * 10000 + minor * 100 + patch. */
uint32_t starter_version_v1(void);

/* FNV-1a checksum of data[0..len). options may be NULL. Writes the result to *out. */
zig_starter_status starter_checksum_v1(const uint8_t *data, size_t len, const zig_starter_options *options, uint64_t *out);

#ifdef __cplusplus
}
#endif

#endif /* ZIG_STARTER_H */
