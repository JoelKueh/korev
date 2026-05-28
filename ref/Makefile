
ROOT_DIR      := $(CURDIR)
SPIKE_SRC     := $(ROOT_DIR)/riscv-isa-sim
BUILD_DIR     := $(ROOT_DIR)/build
INSTALL_DIR   := $(ROOT_DIR)/install

WRAPPER_SRC   := $(ROOT_DIR)/src/spike-rvvi.cpp
WRAPPER_SO    := $(INSTALL_DIR)/lib/librvvi_spike.so

INCLUDES      := -I$(INSTALL_DIR)/include -I$(ROOT_DIR)/include
SPIKE_LIBS    := -L$(INSTALL_DIR)/lib -lriscv -lfesvr -ldisasm -lsoftfloat

CXX           := g++
CXXFLAGS      := -O2 -fPIC -std=c++14
LDFLAGS       := -shared -Wl,-rpath,'$$ORIGIN/third_party/spike_install/lib'

.PHONY: all spike rvvi clean clean_all
all: wrapper

spike:
	mkdir -p $(BUILD_DIR)
	cd $(SPIKE_SRC)/build && \
	../configure --prefix=$(INSTALL_DIR) CFLAGS="-fPIC" CXXFLAGS="-fPIC" && \
	make -j$(nproc) && \
	make install

rvvi: $(WRAPPER_SRC)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(WRAPPER_SRC) -o $(WRAPPER_SO) $(SPIKE_LIBS) $(LDFLAGS) -lpthread

clean:
	rm -f $(WRAPPER_SO)

clean_all: clean
	rm -rf $(INSTALL_DIR)
	rm -rf $(BUILD_DIR)
