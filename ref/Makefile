
ROOT_DIR      := $(CURDIR)
SPIKE_SRC     := $(ROOT_DIR)/riscv-isa-sim
BUILD_DIR     := $(ROOT_DIR)/build
INSTALL_DIR   := $(ROOT_DIR)/install

INCLUDES      := -I$(INSTALL_DIR)/include
SPIKE_LIBS    := -L$(INSTALL_DIR)/lib -lriscv -lfesvr -ldisasm -lsoftfloat

WRAPPER_SRC     := $(ROOT_DIR)/src/rvvi.cc
WRAPPER_SO      := $(INSTALL_DIR)/lib/librvvi_spike.so
WRAPPER_LDFLAGS := $(SPIKE_LIBS) -shared -Wl,-rpath,'$$ORIGIN'

TRACE_SRC       := $(ROOT_DIR)/src/rvvi-trace.cc
TRACE_BIN       := $(INSTALL_DIR)/bin/rvvi-trace
TRACE_LDFLAGS   := -L$(INSTALL_DIR)/lib -lrvvi_spike -Wl,-rpath,'$$ORIGIN/../lib'

CXX           := g++
CXXFLAGS      := -O2 -fPIC -std=c++17

.PHONY: all spike clean clean_all
all: spike rvvi trace

spike:
	mkdir -p $(BUILD_DIR)
	cd $(SPIKE_SRC)/build && \
	../configure --prefix=$(INSTALL_DIR) CFLAGS="-fPIC" CXXFLAGS="-fPIC" && \
	make -j$(nproc) && \
	make install

$(WRAPPER_SO): $(WRAPPER_SRC)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(WRAPPER_SRC) -o $(WRAPPER_SO) $(WRAPPER_LDFLAGS) -lpthread

trace: $(TRACE_SRC) $(WRAPPER_SO)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(TRACE_SRC) -o $(TRACE_BIN) $(TRACE_LDFLAGS)

clean:
	rm -f $(WRAPPER_SO)

clean_all: clean
	rm -rf $(INSTALL_DIR)
	rm -rf $(BUILD_DIR)
