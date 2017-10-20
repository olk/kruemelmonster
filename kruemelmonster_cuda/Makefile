CUDA_PATH ?= /opt/cuda

HOST_ARCH := $(shell uname -m)
TARGET_ARCH ?= $(HOST_ARCH)
TARGET_SIZE := 64

HOST_COMPILER ?= g++
NVCC := $(CUDA_PATH)/bin/nvcc -ccbin $(HOST_COMPILER) 

NVCCFLAGS := -m${TARGET_SIZE} -std=c++11 --expt-relaxed-constexpr
CCFLAGS := -O2 -W -Wall
LDFLAGS :=

ALL_CCFLAGS := $(NVCCFLAGS)
ALL_CCFLAGS += $(addprefix -Xcompiler ,$(CCFLAGS))

ALL_LDFLAGS := $(ALL_CCFLAGS)
ALL_LDFLAGS += $(addprefix -Xlinker ,$(LDFLAGS))

INCLUDES := -I$(CUDA_PATH)/include
LIBRARIES :=  -lGL -lglut

SM ?= 61
GENCODE_FLAGS += -gencode arch=compute_$(SM),code=compute_$(SM)

all: build

build: kruemelmonster_cuda

kruemelmonster_cuda.o:kruemelmonster_cuda.cu
	$(EXEC) $(NVCC) $(INCLUDES) $(ALL_CCFLAGS) $(GENCODE_FLAGS) -o $@ -c $<

kruemelmonster_cuda: kruemelmonster_cuda.o
	$(EXEC) $(NVCC) $(ALL_LDFLAGS) $(GENCODE_FLAGS) -o $@ $+ $(LIBRARIES)

clean:
	rm -f kruemelmonster_cuda kruemelmonster_cuda.o

clobber: clean
