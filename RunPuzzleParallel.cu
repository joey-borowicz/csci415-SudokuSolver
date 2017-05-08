//  RunPuzzleParallel.cu
//
//
//  Created by Joey Borowicz on 5/7/17.
//
//
#include <stdio.h>
#include <math.h>
#include <iomanip>
#include <iostream>
#include <string>
#include <sys/time.h>
#include "Puzzles.h"
using namespace std;



// problem size (vector length) N
static const int N = 12345678;


//Note: the first part of this program is essentially copied from the serial version

__device__ bool square(int row, int column, int* puzzle, int counter, int startValue)
{
 if(counter == 81) //went through whole puzzle
    {
        return true;
    }

    //loop of column and rows
    if(++column == 9)
    {
        column = 0;
        if(++row == 9)
        {
            row = 0;
        }
    }

    //skip solved squares
    if(puzzle[column + row * 9] != 0)
    {
        return square(row, column, puzzle, counter+1, startValue);
    }

    for(int i = 1; i <= 9; i++)
    {
        if(++startValue == 10)//This should work to for setting start value at one if cell is 0
        {
            startValue = 1;
        }

        //check if the value is valid using our function
        if(valid(row, column, startValue, puzzle))
        {
            puzzle[column + row * 9] = startValue;

            if(square(row, column, puzzle, counter+1, startValue))
            {
                return true;
            }
        }
    }
    puzzle[column + row * 9] = 0; //set to zero
    //will require backtracking
	
	
	
	
	
	
    return false;
}

__device__ bool valid(int row, int column, int value, int* puzzle)
{
    int i;

    for(i = 0; i < 9; i++)
    {
        if(puzzle[row * 9 + i] == value) //rows
        {
            return false;
        }
        else if(puzzle[column + i * 9] == value) //columns
        {
            return false;
        }
        else if(puzzle[(row/3*3+i%3) * 9 + (column/3*3+i/3) ] == value) //check the subsection 
        {
            return false;
        }
    }
      return true; //valid value
}

//Implementing the parallel solve method
__global__ void solve_parallel(int* puzzle)
{
   	int r = threadIdx.x  //row id
	int c = threadIdx.y  //column id 
 	int s = blockIdx.x * blockDum.x + threadIdx.x  //setting the start value
		
	if(square(r,c,puzzle,0, s)) 
     	{
        	cout << "Puzzle Solved\n";
    	}
    	else 
    	{
       	 	cout << "Puzzle Not Solved\n";
    	}
		
}



/*__global__ bool valid_parallel(int *puzzle,int value, int *output)
{
	int r = threadIdx.x  //row id
	int c = threadIdx.y  //column id 
	int s = blockIdx.x * blockDum.x + threadIdx.x  //setting the start value using the idea from assignment1
	

	
	if(puzzle[r * 9 + s] == value) //rows
        {
            	return false;
        }
        else if(puzzle[c + s * 9] == value) //columns
        {
            	return false;
        }
        else if(puzzle[(r/3*3+s%3) * 9 + (c/3*3+s/3) ] == value) //check the subsection 
        {
            	return false;
        }
	return true;

}*/


__device__ void display(int* puzzle)
{
for (int h = 0; h < 81; h++)
{
 if (h % 27 == 0)
	{
		cout << "\n-------------------------";
  	}
 if (h % 9 == 0)
  	{
  		cout << "\n";
		cout << "| "; 
	}
 cout << puzzle[h];
 cout << " "; 
 if (h % 3 == 2)
	{
  		cout << "| ";
	}
}
cout << "\n";
cout << "-------------------------";
cout << "\n";
}


//this was used in both of the 2 CUDA assignments
// Returns the current time in microseconds
long long start_timer() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000000 + tv.tv_usec;
}


// Prints the time elapsed since the specified time
long long stop_timer(long long start_time, std::string name) {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	long long end_time = tv.tv_sec * 1000000 + tv.tv_usec;
    std::cout << std::setprecision(5) << std::fixed;
	std::cout << name << ": " << ((float) (end_time - start_time)) / (1000) << " Msec\n";
	return end_time - start_time;
}


//TODO: Memory allocation and the other cuda specific memory operations. Need to look closer at some other resources.

int main()
{
	
	//CPU Implementation
	Puzzles p;
	int* h_puzzle = (int*)malloc(81*sizeof(int));
	
	//Initializing data on CPU
	int i;
	for(i = 0; i < 81; i++)
	{
		h_puzzle[i] = p.puzzleOne[i];
	}
	
	//Execute and time: CPU version
	std::clock_t CPU_start;
	double CPU_totalTime;
	CPU_start = clock();
	solve(h_puzzle);
	display(h_puzzle);
	CPU_totalTime = (clock() - CPU_start) / (double) CLOCKS_PER_SEC;
	cout << "\nTime: " << CPU_totalTime << " seconds\n";
	
	
	//GPU Implementation
	
	//not sure if this is required
	const int sizeOfBlock = 1024;
  	const int sizeOfGrid = N/1024 + 1; 
  	const float bytes = 81*sizeof(int);
	long long GPU_startTotal = start_timer(); //GPU start time
	
	//Allocating memory to GPU and timing it
	long long GPU_allocateStart = start_timer();
	int* d_puzzle = (int*)malloc(81*sizeof(int)); 
	cudaMalloc((void**) &d_input, bytes); 
	long long GPU_allocateTime = stop_timer(GPU_allocateStart, "\nGPU Memory Allocation");
	
	
	long long GPU_dcopyStart = start_timer();
	cudaMemcpy(d_puzzle, h_puzzle, 81*sizeof(int), cudaMemcpyHostToDevice);
	long long GPU_dcopyTime = stop_timer(GPU_dcopyStart, "Copying GPU Memory to Device"); 
	
	
	long long GPU_kernelStart = start_timer();
	solve_parallel<<<sizeOfGrid, sizeOfBlock>>>(d_puzzle);
	display<<<sizeOfGrid, sizeOfBlock>>>(h_puzzle);
	long long GPU_kernelTime = stop_timer(GPU_kernelStart, "GPU Kernel Run Time");
	
	
	//Copying the output to the host
  	long long GPU_hcopyStart = start_timer();
  	cudaMemcpy(h_gpu_result, d_output, bytes, cudaMemcpyDeviceToHost);
  	long long GPU_hcopyTime = stop_timer(GPU_hcopyStart, "Copying GPU Memory to Host");
	
	//Free GPU memory
 	cudaFree(d_puzzle);
	
	// End GPU timer
  	long long GPU_totalTime = stop_timer(GPU_startTotal, "Total GPU Run Time");
	
	/*
	// Checking to make sure the CPU and GPU results match - Do not modify
  	int errorCount = 0;
  	for (i=0; i<N; i++)
  	{
   		 if (abs(h_cpu_result[i]-h_gpu_result[i]) > 1e-6)
      		 errorCount = errorCount + 1;
  	}
  	if (errorCount > 0)
   	printf("Result comparison failed.\n");
  	else
    	printf("Result comparison passed.\n");
	*/
	
	
	 // Cleaning up memory
  	free(h_puzzle);
  	//free(h_cpu_result);
  	//free(h_gpu_result);
  	return 0;
	
	
	/*//calculating time taken 
	std::clock_t GPU_start;
	double GPU_totalTime;
	GPU_start = clock();
	parallel_solve(puzzle);
	display(puzzle);
	GPU_totalTime = (clock() - GPU_start) / (double) CLOCKS_PER_SEC;
	cout << "\nTime: " << GPU_totalTime << " seconds\n";*/
	

  	
	
}














