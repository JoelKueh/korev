
#include <cassert>
#include "lockstep.h"

int main(int argc, char **argv)
{
	assert(argc == 2);
	spikeInit(argv[1]);
	return 0;
}
