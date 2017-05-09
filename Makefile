
NVCC = /usr/local/cuda/bin/nvcc

NVCC_FLAGS = -I/usr/local/cuda/include -lineinfo

# make emu=1 compiles the CUDA kernels for emulation
ifeq ($(emu),1)
	NVCC_FLAGS += -deviceemu
endif

all: RunPuzzleParallel

RunPuzzleParallel: RunPuzzleParallel.cu
	$(NVCC) $(NVCC_FLAGS) RunPuzzleParallel.cu -o RunPuzzleParallel -lcuda

clean:
	rm -f *.o *~ RunPuzzleParallel
