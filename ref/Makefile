
ROOT_DIR      := $(CURDIR)
SPIKE_SRC     := $(ROOT_DIR)/riscv-isa-sim
BUILD_DIR     := $(ROOT_DIR)/build
INSTALL_DIR   := $(ROOT_DIR)/install

INCLUDES      := -I$(INSTALL_DIR)/include
SPIKE_LIBS    := -L$(INSTALL_DIR)/lib -lriscv -lfesvr -ldisasm -lsoftfloat

TRACE_SRC       := $(ROOT_DIR)/src/rvvi-trace.cc
TRACE_BIN       := $(INSTALL_DIR)/bin/rvvi-trace
TRACE_LDFLAGS   := -L$(INSTALL_DIR)/lib -lrvvi_spike -Wl,-rpath,'$$ORIGIN/../lib'

CXX           := g++
CXXFLAGS      := -O2 -fPIC -std=c++17

.PHONY: all spike clean clean_all
all: spike rvvi trace

trace: $(TRACE_SRC) $(WRAPPER_SO)
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(TRACE_SRC) -o $(TRACE_BIN) $(TRACE_LDFLAGS)

clean:
	rm -f $(WRAPPER_SO)

clean_all: clean
	rm -rf $(INSTALL_DIR)
	rm -rf $(BUILD_DIR)
