/* Links the static library through the public header and checks the ABI end to end. */
#include <stdio.h>
#include <string.h>

#include "zig_starter.h"

int main(void) {
  const uint8_t *input = (const uint8_t *)"a";
  uint64_t out = 0;
  zig_starter_options options;
  memset(&options, 0, sizeof options);
  options.size = sizeof options;
  options.seed = 1;

  if (starter_version_v1() == 0) return 1;
  if (starter_checksum_v1(input, 1, NULL, &out) != ZIG_STARTER_OK) return 2;
  if (out != 0xaf63dc4c8601ec8cULL) return 3;
  if (starter_checksum_v1(input, 1, &options, &out) != ZIG_STARTER_OK) return 4;
  if (out != (0xaf63dc4c8601ec8cULL ^ 1)) return 5;
  if (starter_checksum_v1(NULL, 0, NULL, &out) != ZIG_STARTER_EMPTY_INPUT) return 6;
  if (starter_checksum_v1(input, 1, NULL, NULL) != ZIG_STARTER_INVALID_ARGUMENT) return 7;
  return 0;
}
