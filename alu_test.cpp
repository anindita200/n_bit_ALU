

#include <iostream>
using namespace std;

int main() {    
    int result,mode,op,din1,din2; //inputs

    cout << "Enter mode: ";		// choose between logical and arithmetic mode
    cin >> mode;

    cout << "Enter op: ";		// decide the type of operation
    cin >> op;

    cout << "Enter operand 1: "; // Enter operand 1
    cin >> din1;

    cout << "Enter operand 2: "; // Enter operand 2
    cin >> din2;

    result = mode ? (op==0  ? din1 + din2			//addition
						 	: op==1 ? din1 - din2 	// subtraction
						 	: op==2 ? din1 * din2 	// multiplication
						 	: op==3 ? din1 / din2 	// division
						 	: op==4 ? din1 > din2  	// comparison
						 	: 		  0)
				   : (op==0 ? din1 & din2 			// bitwise AND
				   			: op==1 ? din1 | din2 
						 	: op==2 ? din1 ^ din2  
						 	: op==3 ? !din1
						 	: op==4 ? din2 ? din1 << 1 : din1 >> 1
						 	: op==5 ? din2 ? din1 << 1 : din1 >> 1 
						 	:   	  0 );

    cout << "Result =  " << result;    
    return 0;
}