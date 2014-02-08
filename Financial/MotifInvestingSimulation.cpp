//g++ -o MotifInvestingSimulation MotifInvestingSimulation.cpp

/*
This program is just a simple simulator to see what ind of parasitic effects the rebalancing fees have on returns of your investment when looking at MotifInvesting.com
*/

/*
 fprintf: 
  http://en.cppreference.com/w/cpp/io/c/fprintf
 getopt: 
   http://pubs.opengroup.org/onlinepubs/000095399/functions/getopt.html 
   http://stackoverflow.com/questions/2219562/using-getopt-to-parse-program-arguments-in-c
 getopt long:
   http://www.gnu.org/software/libc/manual/html_node/Getopt-Long-Option-Example.html
*/

/* Resources I believe I was using to come up with these calculations. I think I decided to simplify things and mirror the last vanguard simulation : check out my work muddle from May 10th.
https://personal.vanguard.com/us/insights/retirement/cost-affect-retirement-spending-tool
http://www.sec.gov/investor/tools/mfcc/mfcc-int.htm
http://www.fool.com/school/mutualfunds/costs/ratios.htm
https://personal.vanguard.com/us/insights/investingtruths/investing-truth-about-cost
https://www.google.com/search?q=vanguard+expense+ratio+calculation&oq=vanguard+expense+ratio+calculation&aqs=chrome.0.69i57.5601j0&sourceid=chrome&ie=UTF-8
*/

/*
1)show what amount that final amount comes from each contribution, color a band showing the power of compounding. show a graph and when you hover over the graph, show a color band across the graph showing what amount that contribution grew to.
2)this doesn't take into acct any reinvestment of dividends
3)tax consequences/impact of LT cap gains. 
4)show the percentage of the final amount contributed by a particular contribution when you hover. 
 */

#define DEBUG 0
//#include <locale.h> //for currency formatting
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
  Investment();
  double ValidateARR(double);
  //I think the best way to do this is to not have redundant constructors with just one or two add'l parameters, but have the minimal no argument case, and the maximal all argument case. The cases in between just use the maximal case with unwanted/unset variables 'zeroed out' so to speak.
  Investment( double investmentAmount, double annualReturn, double expenseRatio, int years, int periodsPerYear);
  Investment( double investmentAmount, double annualReturn, double rebalanceFee, int years, int periodsPerYear, bool details);
  void calculateRebalanceFeeEffect();
  void calculatePeriodicRateOfReturn();
private:
  double investmentAmount, annualReturn,  rebalanceFee,periodicReturnRate;
  int years, periodsPerYear,details;
};

Investment::Investment()
{
  investmentAmount=4000;
  annualReturn=10;
  rebalanceFee = 1;
  years=20;
  periodsPerYear = 26;
  details=0;
 calculatePeriodicRateOfReturn();
}

Investment::Investment(double iA, double aR,double eR,int y,int pPY)
{
  investmentAmount=iA;
  annualReturn=ValidateARR(aR);
  rebalanceFee = eR;
  years=y;
  periodsPerYear = pPY;
  calculatePeriodicRateOfReturn();
}

Investment::Investment(double iA,double aR,double eR,int y,int pPY,bool d)
{
  investmentAmount=iA;
  annualReturn=ValidateARR(aR);
  rebalanceFee = eR;
  years=y;
  periodsPerYear = pPY;
  details = d;
  calculatePeriodicRateOfReturn();
}
void Investment::calculatePeriodicRateOfReturn()
{
   periodicReturnRate=pow(1+annualReturn,1/float(periodsPerYear));

}

double Investment::ValidateARR(double aR)
{
  if (aR > 1)
    { return aR / 100; }
  else 
    return aR;
}

void Investment::calculateRebalanceFeeEffect()
{
  std::cout<<annualReturn<<" "<<periodsPerYear<<"\n";
  //  periodsPerYear=2; annualReturn=2.25;  // it was the damn denominator not being a float that was screwing it all up 
  //  double periodicReturnRate=pow(annualReturn,1/float(periodsPerYear));
  std::cout<<"\nperiodicRR:"<<periodicReturnRate<<"\n";  
  std::cout<<pow((periodicReturnRate),periodsPerYear)<<"\n";

  double taxes=0,rebalanceFees=0,yearEndValue=0;
  yearEndValue=investmentAmount*(periodicReturnRate);
  //  std::cout<<"-1:"<<yearEndValue<<"\n";
  for (int i=0; i<periodsPerYear*years-1; i++)
    {
      yearEndValue=yearEndValue*(periodicReturnRate) - rebalanceFee;
      //      std::cout<<i<<":"<<yearEndValue<<"\n";
    }
  rebalanceFees=periodsPerYear*rebalanceFee*years;
  taxes=0.25*(yearEndValue-investmentAmount); //You won't have all of your ST gains in that year since one period will overlap into the next year, but it is still a good approx
  yearEndValue=yearEndValue-taxes;
  std::cout<<"rebalanceFees:"<<rebalanceFees<<"\n";
  std::cout<<"taxes:"<<taxes<<"\n";
  std::cout<<"End Amount:"<<yearEndValue-taxes<<"\n";
  std::cout<<"no fee or taxes amount:"<<investmentAmount*pow((1+annualReturn),years)<<"\n";
} 

/*determine what percentage of returns you'll use to achieve the gains. take into account tax consequences of gains.
ie. your total gains without taxes and fees would've been:X
total fees:Y
taxes:Z assuming all ST gains.
compare to SP500 or some base rate of return without fees.
or just then calculate what your ARR is taking into acct the taxes and fees. 
*/
//-------------------------------------------------------------------------------------

void usage()
{
  std::cout<<"Please define the investmentAmount (i), years of investing (y), annual return (r), rebalance fee (f), and periods per year (n).\n ./a.out -p 120.50 -y 20 -r 12.5 -e 1.2 -n 26 ";
}

// getopt: http://pubs.opengroup.org/onlinepubs/000095399/functions/getopt.html 
//http://stackoverflow.com/questions/2219562/using-getopt-to-parse-program-arguments-in-c
    
int main(int argc, char *argv[])
{
 
  int c;
  char *filename;
  extern char *optarg;
  extern int optind, optopt, opterr;

  //setup defaults
  double investmentAmount=4000;
  int years=1;
  double annualReturn=40;
  double rebalanceFee=10;
  int periodsPerYear=52;
  bool details=false; //default to off


  //http://www.gnu.org/software/libc/manual/html_node/Getopt-Long-Option-Example.html
  static struct option long_options[] = {
    {"?", 0, 0, 0},
    {"investmentAmount", required_argument, 0, 'i'},
    {"periodsPerYear", required_argument, 0, 'n'},
    {"annualReturn", required_argument, 0, 'r'},
    {"rebalanceFee", required_argument, 0, 'f'},
    {"years", required_argument, 0,'y'},
    {"details", no_argument, 0,'d'},
    {NULL, 1, NULL, 0} //this MUST be last entry 
  };

  /*

    I totally forgot about using capital letters for optargs

  */
  int option_index=0;
  //  std::cout<<argc<<std::endl;
  //  if (argc == 11)
  if (argc >= 1)
    {
      while ((c = getopt_long(argc, argv, ":i:e:r:n:y:d",long_options,&option_index)) != -1) {
	switch(c) {
	case 0:
	  printf ("option %s", long_options[option_index].name);
	  if (optarg)
	    printf (" with arg %s", optarg);
	  printf ("\n");
	  break;
	case 'i':
	  investmentAmount= atof(optarg);
	  printf("investment amount is %f\n", investmentAmount);
	  break;
	case 'n':
	  periodsPerYear = atoi(optarg);
	  printf("periods per year is %d\n", periodsPerYear);
	  break;
	case 'f':
	  rebalanceFee= atof(optarg);
	  printf("expense ratio is %f\n", rebalanceFee);
	  break;
	case 'r':
	  annualReturn = atof(optarg);
	  printf("annual return is %f\n", annualReturn);
	  break;
	case 'y':
	  years = atoi(optarg);
	  printf("years is %d\n", years);
	  break;
	case 'd':
	  details = true; 
	  printf("details ON");
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

  Investment inv(investmentAmount,annualReturn,rebalanceFee,years,periodsPerYear,details);
  std::cout<<investmentAmount<<":"<<annualReturn<<":"<<rebalanceFee<<":"<<years<<":"<<periodsPerYear<<std::endl;
  inv.calculateRebalanceFeeEffect();
  //  inv.totalContribution();
  //  inv.calculation();
  //  inv.calculation2();
  //inv.calculation3();
  //inv.calculation4();
  //inv.calculation5();

}

