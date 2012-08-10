#include <cmath> //for pow
#include <cstdio> //for printf
#include <cstdlib> //for atoi etc
#include <unistd.h> //for getopt
//There was an item in a book that said that if a 20yo puts $2k away a year until 27 (8yrs) then will have $1M dollars when 65. 
//Based on this simulation this assumes a ~10.41% annual return


#define START_INTEREST_RATE 1040
#define STOP_INTEREST_RATE 1050

void CalcReturn(float yearly_investment,int startage,int stopage, int retirementage, float total_investment, float );
float CalcTotalInvestment(float, int, int);
void usage();

int main(int argc, char *argv[])
{
  float rate;
  float yearly_investment=2000;
  float total_investment=0;
  int startage,stopage,retirementage;
  startage=20;stopage=27;retirementage=65;
 
  int c;
  extern char *optarg;
  extern int optind, optopt, opterr;

  if (argc > 1 )
    {

      while ((c = getopt(argc, argv, ":i:r:t:s:")) != -1) 
	{
	  switch(c) 
	    {
	    case 's':
	      startage = atoi(optarg);
	      printf("startage is %d\n", startage);
	      break;
	    case 't':
	      stopage = atoi(optarg);
	      printf("stopage is %d\n", stopage);
	      break;
	    case 'i':
	      yearly_investment= atof(optarg);
	      printf("yearly_investment is %f\n", yearly_investment);
	      break;
	    case 'r':
	      retirementage = atoi(optarg);
	      printf("retirement age is %d\n", retirementage);
	      break;
	    case '?':
	      printf("unknown arg %c\n", optopt);
	      break;
	    }
	}

    }
      else
	usage();
  
  total_investment=CalcTotalInvestment(yearly_investment,startage,stopage);
  CalcReturn(yearly_investment,startage,stopage,retirementage,total_investment, rate);
  return 0;
    }

  //use getopt to specify yearly investment, startage, stop age, retirementage

  void usage()
  {
    printf("Please specify -s startage -t stopage -i yearly_investment -r retirementage\n./a.out -s 22 -t 30 -r 65 -i 2500");
  }

float CalcTotalInvestment(float yearly_investment,int startage,int stopage)
{
  return yearly_investment*(stopage-startage+1);
}

void CalcReturn(float yearly_investment,int startage,int stopage, int retirementage, float total_investment, float rate)
{
  float output;
  
  //  for (int i = 1; i < 12; i++)
  for (int i = START_INTEREST_RATE; i < STOP_INTEREST_RATE; i++) //<--this is the rate of return to loop over *100 ie. 1040=>10.4%; change the magnitude of this number as well as the divisor for computation of the "rate" variable to execute properly
    {
      //use /1000 etc for finer resolution
      rate=1+(i/10000.0); //100 vs 100.0 so we get result as float
      output=0;
      for (int k = startage; k<=stopage; k++)
	{
	  output+=yearly_investment*(pow(rate,retirementage-k));
	}
      
      //	  printf("Starting at age %d and continuing until age %d, investing $%f annualy with a annual interest rate of %f%%, you will have $%f at your retirement age of %d\n",startage,stopage,yearly_investment,rate,output,retirementage);
      printf("Starting at age %d\n and continuing until age %d,\n investing $%0.2f annualy\n with a annual interest rate of %0.5f%%,\n you will have $%0.2f at your retirement age of %d\n and you will have invested a total of $%.2f.\n\n",startage,stopage,yearly_investment,rate,output,retirementage,total_investment);
    }
  
}
