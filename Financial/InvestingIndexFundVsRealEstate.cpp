//g++ -o PeriodicInvestmentForExpenseRatio PeriodicInvestmentForExpenseRatio.cpp

/*
  This program outputs returns of investing an initial amount in an index fund vs
  investing that money in real estate with some sort of rent (which increases periodically)
*/


#define DEBUG 0
#include <unistd.h>  //for getopt
#include <getopt.h> //for getopt_long
#include <math.h> //for pow 
#include <cstdio>
#include <cstdlib> //for atoi atof
#include <string.h>
#include <iostream>

//using namespace std;

class Investment
{
public:
  Investment( double periodicRentIncrease, double monthlyRentalIncome,double investedAmount, double annualReturn,int years,int yearsBetweenRentIncrease);
  void calculation();
private:
  double annualReturn, yearlyRentalIncome, monthlyRentalIncome, periodicRentIncrease,principal;
  int years, yearsBetweenRentIncrease;
};

Investment::Investment(double pRI,double mRI,double iA,double aR, int y,int yBRI)
{
  periodicRentIncrease=pRI;
  yearlyRentalIncome=12*mRI;
  monthlyRentalIncome=mRI;
  yearsBetweenRentIncrease=yBRI;
  annualReturn=aR;
  years=y;
  principal=iA;
}
 
void Investment::calculation()
{
  double returnRate = (annualReturn)/100;
  double finalAmount = 0.0;
  double investedAmount = principal;
  double rentalAmount = 0;
  double yearlyRent = yearlyRentalIncome;
  for (int i = 0; i <= years; i++)
    {
      if (i%yearsBetweenRentIncrease == 0)
	{
	  yearlyRent+=12*periodicRentIncrease;
	}
      investedAmount =principal * pow(1+returnRate,i);
      double annualRentalReturn=1;
      if ( i > 0) 
	{
	  annualRentalReturn =pow(rentalAmount/principal,1/float(i));
	}
      std::cout<<i<<","<<investedAmount<<","<<rentalAmount<<","<<yearlyRent<<","<<annualRentalReturn<<std::endl;
      rentalAmount+=yearlyRentalIncome;
    }

}

//-------------------------------------------------------------------------------------

void usage()
{
  std::cout<<"Please define the periodic Rent Increase (p), length in years between rent increase (x), years of investing (y), annual return of the index fund (r), monthly property income (e) and initial investment amount (i).\n ./a.out -p 50 -y 20 -r 12.5 -e 650 -x 5 -i 20000";
}
    
int main(int argc, char *argv[])
{
 
  int c;
  // char *filename;
  extern char *optarg;
  extern int optind, optopt, opterr;

  //setup defaults
  double monthlyRentalIncome=650.0;
  double periodicRentIncrease=50.0;
  double investedAmount=20000;
  double annualReturn=9.75;
  int years=15;
  int yearsBetweenRentIncrease=5;

  //http://www.gnu.org/software/libc/manual/html_node/Getopt-Long-Option-Example.html
  static struct option long_options[] = {
    {"?", 0, 0, 0},
    {"periodicRentIncrease", required_argument, 0, 'p'},
    {"annualReturn", required_argument, 0, 'r'},
    {"monthlyRentalIncome", required_argument, 0, 'e'},
    {"initialInvestment", required_argument, 0, 'i'},
    {"years", required_argument, 0,'y'},
    {"yearsBetweenIncrease", required_argument, 0,'x'},
    {NULL, 1, NULL, 0} //this MUST be last entry 
  };

  /*
    I totally forgot about using capital letters for optargs
  */
  int option_index=0;
  if (argc >= 1)
    {
      while ((c = getopt_long(argc, argv, ":p:e:r:n:y:d",long_options,&option_index)) != -1) {
	switch(c) {
	case 0:
	  printf ("option %s", long_options[option_index].name);
	  if (optarg)
	    printf (" with arg %s", optarg);
	  printf ("\n");
	  break;
	case 'p':
	  periodicRentIncrease= atof(optarg);
	  printf("periodic rent increase is %f\n", periodicRentIncrease);
	  break;
	case 'e':
	  monthlyRentalIncome= atof(optarg);
	  printf("monthly rental income is %f\n", monthlyRentalIncome);
	  break;
	case 'i':
	  investedAmount= atof(optarg);
	  printf("invested amount %f\n", investedAmount);
	  break;
	case 'r':
	  annualReturn = atof(optarg);
	  printf("annual return is %f\n", annualReturn);
	  break;
	case 'y':
	  years = atoi(optarg);
	  printf("years is %d\n", years);
	  break;
	case 'x':
	  yearsBetweenRentIncrease = atoi(optarg);
	  printf("years is %d\n", yearsBetweenRentIncrease);
	  break;
	case ':':
	  printf("-%c without filename\n", optopt);
	  break;
	case '?':
	  printf("unknown arg %c\n", optopt);
	  break;
	}
      }
    }
  else {
    usage();
  }

  Investment inv(periodicRentIncrease, monthlyRentalIncome,investedAmount, annualReturn,years,yearsBetweenRentIncrease);
  inv.calculation();
  std::cout<<"need to take into acct the 'gain' from taxes but also the loss due to insurance and taxes";
}

