//g++ -o PeriodicInvestmentForExpenseRatio PeriodicInvestmentForExpenseRatio.cpp

/*
This program is just a simple simulator to see what ind of parasitic effects expense ratios have on returns. 
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
  //I think the best way to do this is to not have redundant constructors with just one or two add'l parameters, but have the minimal no argument case, and the maximal all argument case. The cases in between just use the maximal case with unwanted/unset variables 'zeroed out' so to speak.
  Investment( double periodicContribution, double annualReturn, double expenseRatio, int years, int periodsPerYear);
  Investment( double periodicContribution, double annualReturn, double expenseRatio, int years, int periodsPerYear, bool details);
  void calculation();
  void calculation2();
  void totalContribution();
private:
  double periodicContribution,  annualReturn,  expenseRatio;
  int years, periodsPerYear,details;
};

Investment::Investment()
{
  periodicContribution = 100;
  annualReturn=10;
  expenseRatio = 1;
  years=20;
  periodsPerYear = 26;
  details=0;
}

Investment::Investment(double pC,double aR,double eR,int y,int pPY)
{
  periodicContribution = pC;
  annualReturn=aR;
  expenseRatio = eR;
  years=y;
  periodsPerYear = pPY;
}

Investment::Investment(double pC,double aR,double eR,int y,int pPY,bool d)
{
  periodicContribution = pC;
  annualReturn=aR;
  expenseRatio = eR;
  years=y;
  periodsPerYear = pPY;
  details = d;
}
 
void Investment::totalContribution()
{
  std::cout<<"Your total contribution is:$"<<periodicContribution*years*periodsPerYear<<".\n";
}
void Investment::calculation()
{
  //This DOES NOT perform a valid calculation
  int totalPeriods = periodsPerYear*years;
  double returnRate = (annualReturn - expenseRatio)/100;
  double finalAmount = 0.0;
  for (int i = 0; i< totalPeriods; i++)
    {
      //I was trying to do the math for this calculation a different way.
      //I was thinking of it more as a sum 
      finalAmount += periodicContribution*(i)*(1+returnRate);//pow(1+returnRate,years-i/periodsPerYear);
    }
  std::cout<<"Your final invested amount is:"<<finalAmount<<".\n";
}
void Investment::calculation2()
{
  int totalPeriods = periodsPerYear*years;
  double returnRate = (annualReturn - expenseRatio)/100;
  double annualReturn0 = annualReturn/100;
  double finalAmount = 0.0;
  double finalAmountWithNoExpenseRatio = 0.0;
  double  tmp;
  //  for (int i = 0; i < totalPeriods; i++)
  for (int i = totalPeriods; i>0; i--)
    {
      if (details){
	tmp = periodicContribution*pow(1+returnRate,i/periodsPerYear);
	finalAmount += tmp;//periodicContribution*pow(1+returnRate,i/periodsPerYear);
	std::cout<<"Amount from period "<<i<<": $"<<tmp<<".\n";
      }else
	{
	  finalAmount += periodicContribution*pow(1+returnRate,i/periodsPerYear);
	  finalAmountWithNoExpenseRatio += periodicContribution*pow(1+annualReturn0,i/periodsPerYear);
	}
    }
  std::cout<<"Your final invested amount is:"<<finalAmount<<".\n";
  std::cout<<"Your final invested amount would've been :"<<finalAmountWithNoExpenseRatio<<" if there was no expense ratio.\n";
  std::cout<<"For a net difference of :"<<finalAmountWithNoExpenseRatio-finalAmount<<".\n";
}
//-------------------------------------------------------------------------------------

void usage()
{
  std::cout<<"Please define the periodContribution (p), years of investing (y), annual return (r), expense ratio (e), and periods per year (n).\n ./a.out -p 120.50 -y 20 -r 12.5 -e 1.2 -n 26 ";
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
  double periodicContribution=50.0;
  int years=15;
  double annualReturn=9.75;
  double expenseRatio=0.85;
  int periodsPerYear=26;
  bool details=false; //default to off


  //http://www.gnu.org/software/libc/manual/html_node/Getopt-Long-Option-Example.html
  static struct option long_options[] = {
    {"?", 0, 0, 0},
    {"periodicContribution", required_argument, 0, 'p'},
    {"periodsPerYear", required_argument, 0, 'n'},
    {"annualReturn", required_argument, 0, 'r'},
    {"expenseRatio", required_argument, 0, 'e'},
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
  if (argc >= 11)
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
	  periodicContribution= atof(optarg);
	  printf("periodic contribution is %f\n", periodicContribution);
	  break;
	case 'n':
	  periodsPerYear = atoi(optarg);
	  printf("periods per year is %d\n", periodsPerYear);
	  break;
	case 'e':
	  expenseRatio= atof(optarg);
	  printf("expense ratio is %f\n", expenseRatio);
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

  Investment inv(periodicContribution,annualReturn,expenseRatio,years,periodsPerYear,details);
  inv.totalContribution();
  //  inv.calculation();
  inv.calculation2();

}

