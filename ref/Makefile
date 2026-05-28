
SPIKE_SRC_DIR = $(CURDIR)/riscv-isa-sim
SPIKE_BUILD_DIR = $(CURDIR)/riscv-isa-sim/build
INSTALL_DIR = $(CURDIR)/install
BUILD_DIR = $(CIRDIR)/build

.PHONY: build_spike
build_spike:
	mkdir -p $(SPIKE_BUILD_DIR)
	mkdir -p $(INSTALL_DIR)

	pushd $(SPIKE_BUILD_DIR)
	$(SPIKE_SRC_DIR)/configure \
		--prefix=$(INSTALL_DIR) \
		--enable-static \
		--disable-shared
	popd

	make -C $(SPIKE_BUILD_DIR) -j$(shell nproc)
	make -C $(SPIKE_BUILD_DIR) install


CXX      := g++
CXXFLAGS := -O3 -fPIC -std=c++17 \
            -fvisibility=hidden \
            -I$(INSTALL_DIR)/include \
            -I$(CURDIR)/include
LDFLAGS  := -L$(INSTALL_DIR)/lib \
            -lriscv -lfesvr -lpthread


.PHONY: spike_rvvi
spike_rvvi:
	$(CXX) $(CXXFLAGS) spike-rvvi/spike-rvvi.cc -shared $(LDFLAGS) -o $(BUILD_DIR)/spike_rvvi.so

.PHONY: spike_test
spike_test: 
	$(CXX) $(CXXFLAGS) spike-rvvi/spike-rvvi-test.cc -L$(BUILD_DIR) -lspike_rvvi -$(LDFLAGS) -o spike_test

.PHONY: clean
clean:
	rm -rf $(SPIKE_BUILD_DIR) $(INSTALL_DIR)
