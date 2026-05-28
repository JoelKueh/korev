
#include "rvvi.h"
#include <riscv/sim.h>
#include <fesvr/elfloader.h>

#define EXPORT_API __attribute__((visibility("default")))

#define MEM_BASE 0x0
#define MEM_SIZE 0x8000
#define ENTRYPOINT 0x0

struct DutState {
	uint32_t pc;
	uint32_t insn;
	uint32_t gpr[32];
	uint32_t gpr_written[32];
} dutState;

cfg_t *spike_cfg = nullptr;
sim_t *spike_sim = nullptr;

static std::vector<std::pair<reg_t, abstract_mem_t*>> make_mems(const std::vector<mem_cfg_t> &layout)
{
  std::vector<std::pair<reg_t, abstract_mem_t*>> mems;
  mems.reserve(layout.size());
  for (const auto &cfg : layout) {
    mems.push_back(std::make_pair(cfg.get_base(), new mem_t(cfg.get_size())));
  }
  return mems;
}

extern "C" {

EXPORT_API bool_t rvviVersionCheck(uint32_t version)
{
	return RVVI_API_VERSION == version ? RVVI_TRUE : RVVI_FALSE;
}

EXPORT_API bool_t rvviRefInit(const char *programPath)
{
	// Initialize the configuration for the simulator
	cfg_t *cfg = new cfg_t();
    cfg->initrd_bounds      = std::make_pair(0, 0); // Do not load a filesystem
    cfg->bootargs           = nullptr;              // No bootargs
	cfg->isa                = "rv32i";              // Configure for rv32i
	cfg->priv               = "priv_spec_1p11";     // Specify grabage priv_spec
    cfg->endianness         = endianness_little;    // Little endian is risc-v default
    cfg->pmpregions         = 0;                    // No protected memory regions
    cfg->pmpgranularity     = 0;                    // No protected memory regions
    cfg->mem_layout         = std::vector<mem_cfg_t>({mem_cfg_t(MEM_BASE, MEM_SIZE)});
    cfg->start_pc.set_global(ENTRYPOINT);           // Start from addr 0x0
    cfg->hartids            = std::vector<size_t>({0});
    cfg->explicit_hartids   = true;                 // Use the specified hartids
    cfg->real_time_clint    = false;                // Use the simulation clock for interrupts
    cfg->trigger_count      = 0;                    // No software breakpoints
    cfg->cache_blocksz      = 64;                   // Default standard cache line sizing
    cfg->external_simulator = std::nullopt;         // No external simulator

    // Set up parameters for the simulator
    bool halted = false;                // CPU is not halted
    std::vector<std::pair<reg_t, abstract_mem_t*>> mems = make_mems(cfg->mem_layout);
    std::vector<device_factory_sargs_t> plugin_device_factories;
    bool dtb_discovery = false;         // No device tree binary
    std::vector<std::string> htif_args; // Do not automaticaly load an elf file
    debug_module_config_t dm_config;    // No debug module
    const char *log_path = nullptr;     // No loggin
    bool dtb_enabled = false;           // No device tree binary
    const char *dtb_file = nullptr;     // No device tree binary
    bool socket_enabled = false;        // No socket
    FILE *cmd_file = nullptr;           // No command file
    std::optional<unsigned long long> instruction_limit = std::nullopt;

    // Initialize the simulator itself
    spike_sim = new sim_t(
    	cfg, halted, mems, plugin_device_factories, dtb_discovery,
    	htif_args, dm_config, log_path, dtb_enabled, dtb_file,
    	socket_enabled, cmd_file, instruction_limit
    );

	// Load the elf file
	if (programPath != nullptr) {
		std::ifstream file(programPath, std::ios::binary | std::ios::ate);
		reg_t entry_point = 0;

		// Load the elf from the file
		try {
			load_elf(programPath, &(spike_sim->memif()), &entry_point, 0);
		} catch (const std::exception& e) {
			return RVVI_FALSE;
		}

		// Set the entrypoint for the core
		spike_sim->get_core(0)->get_state()->pc = entry_point;
		if (file.is_open()) {
			std::streamsize size = file.tellg();
		}
	}

	return RVVI_TRUE;
}

}
