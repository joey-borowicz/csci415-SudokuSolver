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
using namespace std;



static bool done;




bool square(int row, int column, int* puzzle, int counter, int startValue);

bool valid(int row, int column, int value, int* puzzle);

void solve(int* puzzle);




bool square(int row, int column, int* puzzle, int counter, int startValue)

{
    
    if(counter == 81) //went through whole puzzle
        
    {
        
        return true;
        
    }
    
    if(done)
        
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
    
    if(puzzle[row + column * 9] != 0)
        
    {
        
        return square(row, column, puzzle, counter+1, startValue);
        
    }
    
    
    
    
    //if the cell is empty
    
    for(int val = 1; val <= 9; val++)
        
    {
        

        
        if(++startValue == 10)
            
        {
            
            startValue = 1;
            
        }
        
        
        
        
        //check if the value is valid
        
        if(valid(row, column, startValue, puzzle))
            
        {
            
            puzzle[row + column * 9] = startValue; 
            
            
            
            
            if(square(row, column, puzzle, counter+1, startValue)) 
                
            {
                
                return true;
                
            }
            
        }
        
    }
    
    puzzle[row + column * 9] = 0; //set to zero 
    
    return false;
    
}

bool valid(int row, int column, int value, int* puzzle)

{
    
    int i; //loop vairable
    
    
    
    
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
        
        else if(puzzle[(row/3*3+i%3) * 9 + (column/3*3+i/3) ] == value) //check the section
            
        {
            
            return false;
            
        }
        
    }
    
    
      return true; //valid value
    
}



void solve (int* puzzle) {
    
    int r = rand() % 8; //random row
    
    int c = rand() % 8; //random column
    
    int startValue = rand() % 9 +1; //Starting value

    if(square(r,c,puzzle,0,startValue)) {
        
        
        cout << "Puzzle Solved\n";
        
    }
    
    else {
        
        cout << "Not Solved\n";
        
    }

    if(!done) {
        
        done = true;
        
    }
    

}

