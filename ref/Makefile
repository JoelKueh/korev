
SPIKE_SRC_DIR = $(CURDIR)/riscv-isa-sim
SPIKE_BUILD_DIR = $(CURDIR)/spike-build
SPIKE_INSTALL_DIR = $(CURDIR)/spike-install


.PHONY: build_spike
build_spike:
	mkdir -p $(SPIKE_BUILD_DIR)
	mkdir -p $(SPIKE_INSTALL_DIR)

	cd $(SPIKE_BUILD_DIR) && \
		CFLAGS="-fPIC" CXXFLAGS="-fPIC" $(SPIKE_SRC_DIR)/configure \
		--prefix=$(SPIKE_INSTALL_DIR)

	make -C $(SPIKE_BUILD_DIR) -j$(shell nproc)
	make -C $(SPIKE_BUILD_DIR) install



