
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <string.h>

#include "rvvi.h"

#define MEM_BASE 0x0
#define MEM_SIZE 0x8000
#define ENTRYPOINT 0x0
#define TOSTR(x) #x

struct DutState {
	// TODO: If this is ever multi core, need to extend this state.
	uint32_t pc;
	uint32_t insn;
	uint32_t gpr[32];
	bool gpr_written[32];
} dutState;

pid_t spike_pid;
int host_to_spike[2];
int spike_to_host[2];

int spikeStep()
{
	const char STEP_CMD[] = "r 1\n";
	char buffer[256];

	if (write(host_to_spike[1], STEP_CMD, strlen(STEP_CMD))) {
		perror("write");
		return -1;
	}
}

uint32_t spikeGetGpr(int regId)
{
	char buf[256];
	sprintf(buf, "reg 0 %d\n", regId);
}

extern "C" {

bool_t rvviVersionCheck(uint32_t version)
{
	return RVVI_API_VERSION == version ? RVVI_TRUE : RVVI_FALSE;
}

bool_t rvviRefInit(const char *programPath)
{
	bool_t result = RVVI_TRUE;

	// TODO: Figure out where this should go.
	for (int i = 0; i < 32; i++)
		dutState.gpr_written[i] = false;

	// Create pipes to communicate with the spike simulator
	if (pipe(host_to_spike)) {
		perror("pipe");
		result = RVVI_FALSE;
		goto out;
	}

	if (pipe(spike_to_host)) {
		perror("pipe");
		result = RVVI_FALSE;
		goto out;
	}

	// Fork and exec the spike simulator
	if ((spike_pid = fork()) == -1) {
		perror("fork");
		result = RVVI_FALSE;
		goto err_close;
	}

	if (spike_pid == 0) {
		// Close the unneded ends of the pipe
		close(host_to_spike[1]);
		close(spike_to_host[0]);

		// Move the pipe to STDIN and STDOUT
		if (dup2(host_to_spike[0], STDIN_FILENO) != 0) {
			perror("dup2");
			result = RVVI_FALSE;
			_exit(1);
		}

		if (dup2(spike_to_host[1], STDOUT_FILENO) != 0) {
			perror("dup2");
			result = RVVI_FALSE;
			_exit(1);
		}

		// Close the remaining ends of the pipe
		close(host_to_spike[1]);
		close(spike_to_host[0]);

		// Run the spike simulator
		execlp("spike", "spike", "-m" TOSTR(MEM_BASE) ":" TOSTR(MEM_SIZE) "0x4000", "--isa=rv32i",
		       "--disable-dtb", "-d", "--pc=" TOSTR(MEM_BASE), programPath, NULL);
		perror("execlp");
		_exit(1);
	}

	close(host_to_spike[0]);
	host_to_spike[0] = 0;
	close(spike_to_host[1]);
	spike_to_host[1] = 1;

err_kill:
	kill(spike_pid, SIGKILL);
	waitpid(spike_pid, NULL, 0);

err_close:
	if (host_to_spike[0] != 0)
		close(host_to_spike[0]);
	if (host_to_spike[1] != 0)
		close(host_to_spike[1]);
	if (spike_to_host[0] != 0)
		close(spike_to_host[0]);
	if (spike_to_host[1] != 0)
		close(spike_to_host[1]);

out:
	return result;
}

bool_t rvviRefShutdown()
{
	// Is there really any reason to be nice?
	kill(spike_pid, SIGKILL);
	waitpid(spike_pid, NULL, 0);
	return RVVI_TRUE;
}

void rvviDutGprSet(uint32_t hartId, uint32_t gprIndex, uint64_t value)
{
	dutState.gpr[gprIndex] = value;
	dutState.gpr_written[gprIndex] = true;
}

void rvviDutRetire(uint32_t hartId, uint64_t dutPc, uint64_t dutInsBin, bool_t debugMode)
{
	// Do nothing
}

bool_t rvviRefEventStep(uint32_t hartId)
{
	return spikeStep() == 0 ? RVVI_FALSE : RVVI_TRUE;
}

bool_t rvviRefGprsCompare(uint32_t hartId)
{
	for (int i = 0; i < 32; i++) {
	}
}

}
