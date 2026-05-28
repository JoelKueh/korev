
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <iostream>

#include "lockstep.h"

#define STR(x) #x
#define TOSTR(x) STR(x)
#define MEM_BASE 0x80000000
#define MEM_SIZE 0x8000
#define ENTRYPOINT 0x0

struct DutState {
	uint32_t pc;
	uint32_t insn;
	uint32_t gpr[32];
	bool gpr_written[32];
} dutState;

pid_t spike_pid;
int spike_cmd;
int spike_log;

ls_bool_t spikeStep()
{
	const char STEP_CMD[] = "r 1\n";
	char buffer[256];

	if (write(spike_cmd, STEP_CMD, strlen(STEP_CMD))) {
		perror("write");
		return LS_FALSE;
	}

	return LS_TRUE;
}

uint64_t spikeGetGpr(int regId)
{
	char buf[256];
	sprintf(buf, "reg 0 %d\n", regId);
	return 0;
}

ls_bool_t spikeInit(const char *programPath)
{
	ls_bool_t result = LS_TRUE;
	char cmd_file[] = "/tmp/spike_cmd.fifo";
	char log_file[] = "/tmp/spike_log.fifo";
	char cmd_arg[] = "--debug-cmd=/tmp/spike_cmd.fifo";
	char log_arg[] = "--log=/tmp/spike_log.fifo";

	// TODO: Figure out where this should go.
	for (int i = 0; i < 32; i++)
		dutState.gpr_written[i] = false;

	// Create pipes to communicate with the spike simulator
	mkfifo(cmd_file, 0666);
	mkfifo(log_file, 0666);

	// Fork and exec the spike simulator
	if ((spike_pid = fork()) == -1) {
		perror("fork");
		result = LS_FALSE;
		goto out;
	}

	if (spike_pid == 0) {
		char *const spike_args[] = {
			(char *const)"spike",
			(char *const)cmd_arg,
			(char *const)log_arg,
			(char *const)"-d",
			(char *const)"-m" TOSTR(MEM_BASE) ":" TOSTR(MEM_SIZE),
			(char *const)"--isa=rv32i",
			(char *const)"--disable-dtb",
			(char *const)"--pc=" TOSTR(MEM_BASE),
			(char *const)programPath,
			nullptr
		};

		for (int i = 0; i < 8; i++) {
			std::cout << spike_args[i] << " ";
		}
		std::cout << std::endl;

		// TODO: Figure this out
		int fd = open("/dev/null", O_WRONLY);
		dup2(fd, STDOUT_FILENO);
		dup2(fd, STDERR_FILENO);
		close(fd);

		// Run the spike simulator

		execvp(spike_args[0], spike_args);
		perror("execlp");
		_exit(1);
	}

	// Open the FIFOS
	std::cout << "Test 1" << std::endl;
	spike_cmd = open(cmd_file, O_RDWR);
	std::cout << "Test 2" << std::endl;
	spike_log = open(log_file, O_RDONLY);

	// TODO: Figure out
	char buf[256];
	read(spike_log, buf, 256);
	perror("read");
	std::cout << "Test 3" << std::endl;

	goto out;

err_close:
	close(spike_cmd);
	close(spike_log);

err_kill:
	kill(spike_pid, SIGKILL);
	waitpid(spike_pid, NULL, 0);

out:
	return result;
}

