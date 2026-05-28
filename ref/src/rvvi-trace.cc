
#include <cassert>
#include <iostream>
#include "rvvi.h"

int main(int argc, char **argv)
{
	assert(argc == 2);
	std::cout << "Test -1" << std::endl;
	assert(rvviVersionCheck(RVVI_API_VERSION) == RVVI_TRUE);
	assert(rvviRefInit(argv[1]));
	std::cout << "Test Final" << std::endl;
	return 0;
}
