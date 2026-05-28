
#include "rvvi.h"
#include "minunit.h"

MU_TEST(test_add) {
	mu_check(rvviVersionCheck(RVVI_API_VERSION) == RVVI_TRUE);
	mu_check(rvviRefInit("../cases/obj/add.elf"));
}
MU_TEST_SUITE(test_suite) {
	MU_RUN_TEST(test_add);
}

int main(int argc, char *argv[]) {
	MU_RUN_SUITE(test_suite);
	MU_REPORT();
	return MU_EXIT_CODE;
}
