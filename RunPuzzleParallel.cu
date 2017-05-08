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

__global__ void sudoku_parallel(int *puzzle, int *output)
{
	int r = threadIdx.x  //row id
	int c = threadIdx.y  //column id 
	int s = blockIdx.x * blockDum.x + threadIdx.x  //setting the start value using the idea from assignment1
	

	//TODO: finish parallel function - will be similar(ish) to serial




}


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