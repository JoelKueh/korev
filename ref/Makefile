
SPIKE_SRC_DIR = $(CURDIR)/riscv-isa-sim
SPIKE_BUILD_DIR = $(CURDIR)/riscv-isa-sim/build
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


CXX      := g++
CXXFLAGS := -O3 -fPIC -std=c++17 \
            -fvisibility=hidden \
            -I$(SPIKE_INSTALL_DIR)/include \
            -I$(CURDIR)/include
LDFLAGS  := -shared \
            -L$(SPIKE_INSTALL_DIR)/lib \
            -lriscv -lfesvr -lpthread

.PHONY: spike_rvvi
spike_rvvi:
	$(CXX) $(CXXFLAGS) spike-rvvi.cc $(LDFLAGS) -o libvi_reference_spike.so

.PHONY: clean
clean:
	rm -rf $(SPIKE_BUILD_DIR) $(SPIKE_INSTALL_DIR) *.so
