
#include <cassert>
#include <iostream>
#include "lockstep.h"

int main(int argc, char **argv)
{
	assert(argc == 2);
	spikeInit(argv[1]);
	std::cout << "stepping" << std::endl;
	spikeStep();
	return 0;
}
