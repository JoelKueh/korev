#pragma once

#include <cstdint>

#define LS_TRUE true;
#define LS_FALSE false;

typedef uint8_t ls_bool_t;

ls_bool_t spikeStep();
uint64_t spikeGetGpr(int regId);
ls_bool_t spikeInit(const char *programPath);
