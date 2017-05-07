//  RunPuzzle.cpp
//
//
//  Created by Joey Borowicz on 4/18/17.
//
//

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <cstdio>
#include <math.h>
#include <time.h>
#include <iostream>
#include <cstdio>
#include <ctime>
#include "Puzzles.h"
using namespace std;


//'square' goes through each value in the square until each cell has a non-zero value
bool square(int row, int column, int* puzzle, int counter, int startValue);

bool valid(int row, int column, int value, int* puzzle);

void solve(int* puzzle);

void display(int* puzzle);


bool square(int row, int column, int* puzzle, int counter, int startValue)
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

bool valid(int row, int column, int value, int* puzzle)
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

void solve(int* puzzle)
{
    int r = rand() % 8; //random row
    int c = rand() % 8; //random column

    int startValue = rand() % 9 +1; //Starting value

    if(square(r,c,puzzle,0,startValue)) 
    {
        cout << "Puzzle Solved\n";
    }
    else 
    {
        cout << "Puzzle Not Solved\n";
    }
}

void display(int* puzzle)
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

int main()
{
	Puzzles p;
	int* puzzle = (int*)malloc(81*sizeof(int));
	int i;
	for(i = 0; i < 81; i++)
	{
		puzzle[i] = p.puzzleOne[i];
	}
	std::clock_t start;
	double totalTime;
	start = clock();
	solve(puzzle);
	display(puzzle);
	totalTime = (clock() - start) / (double) CLOCKS_PER_SEC;
	cout << "\nTime: " << totalTime << " seconds\n";
}

