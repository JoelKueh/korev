
#include "rvvi.h"
#include "riscv/sim.h"

struct DutState {
	uint32_t pc;
	uint32_t insn;
	uint32_t gpr[32];
	uint32_t gpr_written[32];
} dutState;

sim_t *sipke_sim = nullptr;

bool_t rvviVersionCheck(uint32_t version)
{
	return RVVI_API_VERSION == version;
}

bool_t rvviRefInit(const char *programPath)
{
	
}
