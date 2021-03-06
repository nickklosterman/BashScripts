/*http://www.chrisgountanis.com/programming/85-c-mortgage-payment-loan-calculator-project.html
http://www.chrisgountanis.com/custom/LoanCalculator.cpp
Chris Gountanis
Week 4 IA

Change Request #8 - 08/01/2008
Write the program as a procedural C++ program 
and using a loan amount of $200,000, a term of 
30 years, and an interest rate of 5.75%. Insert 
comments in the program to document the program.

Change Request #9 - 08/06/2008
Write the program as a procedural C++ program. 
Calculate and display the mortgage payment amount 
using the amount of the mortgage, the term of the 
mortgage, and the interest rate of the mortgage 
as input by the user. Allow the user to loop back 
and enter new data or quit. Insert comments in the 
program to document the program.

Change Request #10 - 08/12/2008
Write the program as a procedural C++ program. 
Calculate and display the mortgage payment amount 
using the amount of the mortgage, the term of the 
mortgage, and the interest rate of the mortgage as 
input by the user. Then, list the loan balance and 
interest paid for each payment over the term of the 
loan. On longer-term loans, the list will scroll off 
the screen. Do not allow the list to scroll off the 
screen, but rather display a partial list and then 
allow the user to continue the list. Allow the user 
to loop back and enter new data or quit. Insert 
comments in the program to document the program.
*/

#include <iostream>
#include <iomanip> 
//#include <string>
#include <cstring> //use this on linux instead of string
#include <cstdlib> //need to include this in linux for atof()
#include <math.h>
//#include <windows.h>

//set namespace to eliminate the need for std:: prefixes
using namespace std;

//public defines
int runloan();
bool isvalidnumber(string * puserinput);
void printheader(int iPrintYear);
//HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);  //get handle to standard output

int main()
{
	//set color of output to intense white text with standard black background
  //  SetConsoleTextAttribute(hConsole, 15 | 1);

	//set default first run to yes so loan procedure runs with out prompt
	string userinput = "Y";
	
	//loop while variable is Y allong user to input choices
	while (strcmp(userinput.c_str(),"Y") == 0)
	{
		runloan(); //run the main loan routine
		userinput = "";

		//loop till user enters Y or N
		while (strcmp(userinput.c_str(), "Y") != 0 && strcmp(userinput.c_str(), "N") != 0)
		{
			cout << "Do you want to restart the program? (Y or N): ";
			getline(cin, userinput);

			//convert first letter user input to upper case if single letter was entered only
			if (userinput.length() == 1)
			{
				userinput = toupper(userinput[0]); //convert first letter to upper case
			}
		}
	}
	return 0;
}


int runloan()
{
	string userinput;
	double amount, rate, term, payment, interest, principal;
	int iCounter=0, iYear=1, loanchecker;
	string * puserinput = &userinput; // pointer to user input variable

	//formatting output with a decimal place of 2
	cout << setiosflags(ios::fixed | ios::showpoint) << setprecision(2);

	//get loan amount routine
	userinput = "";
	while(!isvalidnumber(puserinput) || userinput.length() == 0) //loop till valid numeric number is found and is not empty
	{
		cout << "Enter the amount of loan: ";
		getline(cin, userinput);
	}
	amount = atof(userinput.c_str()); //convert string to double
	loanchecker = (int)amount;

	//get interest rate routine
	userinput = "";
	while(!isvalidnumber(puserinput) || userinput.length() == 0) //loop till valid numeric number is found and is not empty
	{
		cout << "Enter the interest rate: ";
		getline(cin, userinput);
	}
	rate = atof(userinput.c_str()); //convert string to double

	//if rate is a not a decimal convert value to decimal
	if(rate > 1)
		rate = (rate/100);

	//get term routine
	userinput = "";
	while(!isvalidnumber(puserinput) || userinput.length() == 0) //loop till valid numeric number is found and is not empty
	{
		cout << "Enter the total number of years: ";
		getline(cin, userinput);
	}
	term = atof(userinput.c_str()); //convert string to double
	
	//calculate the monthly payment
	payment = (amount * pow((rate / 12) + 1, (term * 12))* rate / 12)/(pow(rate / 12 + 1, (term * 12)) - 1); 
	
	//output loan specific data header information
	cout << "\nUser Specified Loan Details" << endl;
	cout << setfill('-') << setw(80) << "-" << endl;
	
	//output report hearder information
	printheader(iYear);

	//output the monthly payment
	while (loanchecker != 0)
	{
		//increment counters
		iCounter++;

		//calculate interset rate based on remaining loan amount
		interest = (amount * rate) / 12;

		//calculate new loan amount after payment plus interest
		amount = (amount - payment) + interest;

		//calculate principal by subtracting the interest from the payment to obtain the amount that goes toward paying down the principal
		principal = payment - interest;
		loanchecker = (int)amount;

		//prevent a negative number once loan is paid off
		if (loanchecker == 0) amount = 0;

		//output loan information for a specific month
		cout << iCounter << "\t" << payment << "\t\t" << interest << "\t\t" << principal << "\t\t" << amount << endl;

		if (iCounter == 12 && amount != 0) //allow screen data to be buffered if the loan amount is not 0 per year
		{
			iCounter = 0;
			iYear++;
			cout << "Press enter to continue...";
			getline(cin, userinput);

			//output report hearder information
			printheader(iYear);
		}

	}
	return 0;
}


bool isvalidnumber(string * puserinput)
{
    bool decimal = true;
	string checkstring = *puserinput; //convert memory location to string
    for(int count=0; count < (int)checkstring.length(); count++) //loop the char array for invalid numeric data
    {
		if(isdigit(checkstring[count]) || checkstring[count] == '.' && decimal == true)
        {
            if(checkstring[count]== '.') //only allows one decimal place
            {
                decimal = false;
            }
        }
        else 
        {
            return false; //numeric validation failed
        }
    }
    return true; //numeric validation success
}

void printheader(int iPrintYear)
{
	//clear screen
	//system("cls");
			
	//set color of output
	//    SetConsoleTextAttribute(hConsole, 12);

	//output current reporting year
	cout << "\nDetails for year: " << iPrintYear << endl;

	//set color of output
	//    SetConsoleTextAttribute(hConsole, 14);

    //output loan payment specific data header information
	cout << "Month\tPayment\t\tInterest\tPrincipal\tLoan Amount" << endl;
	cout << setfill('-') << setw(80) << "-" << endl;

	//reset color of output to initial color text
	//    SetConsoleTextAttribute(hConsole, 15);
}
