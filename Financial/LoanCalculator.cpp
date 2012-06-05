/*
 http://en.cppreference.com/w/cpp/io/c/fprintf
TODO: allow reading of a matrix/list of extra payments from a file that correspond to months when applied. ie. 3rd line = apply extra payment to 3rd month

*/

//#include <locale.h> //for currency formatting
#include <unistd.h>  //for getopt
#include <math.h> //for pow 
#include <cstdio>
#include <cstdlib> //for atoi atof
#include <string.h>
#include <iostream>
//#include <iterator> // 

//using namespace std;

//The *only* way to decrease the amount of interest paid for a set of variables is to pay extra towards the principal. Increaseing the frequency of payment (but making a smaller payment) doesn't do anything towards reducing the amount of interest paid. The whole basis of the biweekly payment plan is that each year you pay an additional monthly mortgage payment that is applied towards principal. For a given amount of principal and interest rate, the only other way to decrease the amount paid towards interest besides add'l payments towards principal is to increase the frequency of payments. However, I'm not sure that banks would make amortizations schedules for less than monthly payments.
//E.g. for a $100,000 loan at 4.5% interest you would pay $4,500 for the first year in interest. But if you pay with monthly payments you pay only $4,308.25 in interest on the first year because the amount that goes towards interest is recalculated more frequently where the principal is lower.

//However, the impact of increased frequency in the amortization table isn't as big a gain as one might expect. For the above case, the amount of interest paid on 12 payments per year is $82,404.60. The amount of interest paid on 240 payments per year is $82.277.40, a difference of $127.20 -->  ./a.out -i 4.5 -l 100000 -p 12 -n 360  vs  ./a.out -i 4.5 -l 100000 -p 24 -n 7200 
//If instead you made an additional $1 contribution per pay period on the 12 payments per year loan you would save $398.17 in interest over the life of the loan. -->  ./a.out -i 4.5 -l 100000 -p 12 -n 360 -e 1
// ./a.out -i 4.5 -l 100000 -p 240 -n 7200 -e 1


//---->> Ultimate Lesson: Paying off add'l principal per pay period has the greatest impact


double moneyround(double amt);

class AmortizedLoan
{
public:
  AmortizedLoan();
  AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthly_payment);

  AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_);
void   set_AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthly_payment);
  void PrintLoanDetails();
  void PrintCurrentIteration();
  void IteratePayment();
  double AmountOwedAfterXMonths(int mon);
  double get_periodicmortgagepayment();
  double get_principal();
  double get_loan_amount();
  double get_overpaymenttoprincipal();
  double get_totalinterestonloan();
  int get_monthstopayoffloan();
  void set_principal(double new_p);
  double calc_paymenttowardsinterest();
  double calc_paymenttowardsprincipal();
  void calc_newprincipal();
  double calc_paymentpercentages();//only return the percentage of one and subtract this for the other. want this so can see how quickly the amount going ot int drops off
  //  double get_principal();
  void AmortizationTable();
  void AmortizationTable2();
  void PrintPeriodicMortgagePayment();
  void AmortizationAmounts();
private:
  //  string GetPeriodString()
  void reset_principal();
  void calc_periodicmortgagepayment();//double int_rate, int num_pmnts, double principal, int freq);
  void CalcAmortizationValues();
  double int_rate_pct,principal,loan_amount,additionalperiodicpaymenttoprincipal,periodicmortgagepayment,totalcostofloan,totalinterestonloan;
  int num_pmnts,freq,monthstopayoffloan;
};

int AmortizedLoan::get_monthstopayoffloan()
{return monthstopayoffloan;}

double AmortizedLoan::get_totalinterestonloan()
{
  return totalinterestonloan;
}
void AmortizedLoan::PrintLoanDetails()
{
  printf("Using %.2f %% interest rate for %d months on $ %.2f loan with payments due XXXX and additional XXX payments of $ %.2f\n", int_rate_pct*100,num_pmnts,loan_amount,additionalperiodicpaymenttoprincipal);
}
void AmortizedLoan::reset_principal()
{
  principal=loan_amount;
}
double AmortizedLoan::get_overpaymenttoprincipal()
{
  return additionalperiodicpaymenttoprincipal;
}
/*
string AmortizedLoan::GetPeriodString()
{
  switch(freq)
    {
    case 1: return "annually";break;
    case 2: return "semi-annually";break;
    case 4: return "quarterly";break;
    case 6: return "bimonthly";break;
    case 12: return "monthly";break;
    case 24: return "twice a month";break;
    case 26: return "biweekly";break;
    case 52: return "weekly";break;
    default: return "periodic";

    }
}
*/

void AmortizedLoan::PrintPeriodicMortgagePayment()
{
  printf("Your mortgage payment will be %0.2f.\n" , periodicmortgagepayment);
}


void AmortizedLoan::AmortizationTable()
{
  printf("month interest principal principalleft\n");
  int month=0;
  double totalprincipal=0, totalinterest=0;
  while (principal > 0.000001) //the floating point must put the result off by just enough that the error accumulates over all the iterations.
    {
      //      printf("%d %2.f\n" , month,principal);
      double paymenttowardsinterest=calc_paymenttowardsinterest();
      //printf("payment twd int %d %f\n" , month,paymenttowardsinterest);
      double paymenttowardsprincipal=calc_paymenttowardsprincipal();
      //printf("payment twd print %d %f\n" , month,paymenttowardsprincipal);
      calc_newprincipal();
      month++;
      //      printf("%d %0.2f %0.2f %0.2f\n" , month,paymenttowardsinterest,paymenttowardsprincipal,principal);
      //      printf("%d %f %f %f\n" , month,paymenttowardsinterest,paymenttowardsprincipal,principal);
      printf("%d %f %f %f %f\n" , month,paymenttowardsinterest,paymenttowardsprincipal,principal,AmountOwedAfterXMonths(month));
      totalprincipal+=paymenttowardsprincipal;
	totalinterest+=paymenttowardsinterest;
    }
      printf("total int %0.2f , total princ %0.2f \n" , totalinterest,totalprincipal);
}

void AmortizedLoan::PrintCurrentIteration()
{
  printf("%0.2f\t%0.2f\t%0.2f\t", calc_paymenttowardsinterest(),calc_paymenttowardsprincipal(),get_principal());
}

void AmortizedLoan::IteratePayment()
{
  calc_newprincipal();
}

void AmortizedLoan::AmortizationAmounts()
{
   reset_principal();
  double totalinterest=0;
  //while (principal > 0.000001) //the floating point must put the result off by just enough that the error accumulates over all the iterations.
  for (int i=0;i<num_pmnts;i++)
    {
      totalinterest+=calc_paymenttowardsinterest();//paymenttowardsinterest;
      calc_newprincipal();
      if (principal<=0.001)
	{	
	  monthstopayoffloan=i; 
	  i+=num_pmnts; //to break out of loop
	}
    }
   totalinterestonloan=totalinterest;
}

AmortizedLoan::AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment)
{

  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = additionalperiodicpaymenttoprincipal_;
  num_pmnts =   num_pmnts_;
  freq = freq_;
  calc_periodicmortgagepayment();//int_rate_pct, num_pmnts, principal,freq);

  //override items if monthlypayment specified
  if (monthlypayment>periodicmortgagepayment && monthlypayment!=0) // <- will the second argument eval to false ever? use > 0.01 instead?
    additionalperiodicpaymenttoprincipal =monthlypayment-periodicmortgagepayment;


}
void AmortizedLoan::set_AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment)
{
  //  std::cout<<"setting values";
  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = moneyround(additionalperiodicpaymenttoprincipal_);
  num_pmnts =   num_pmnts_;
  freq = freq_;
  calc_periodicmortgagepayment();//int_rate_pct, num_pmnts, principal,freq);

  //override items if monthlypayment specified
  if (monthlypayment>periodicmortgagepayment)// && monthlypayment!=0) // <- will the second argument eval to false ever? use > 0.01 instead?
    additionalperiodicpaymenttoprincipal =monthlypayment-periodicmortgagepayment;

}


AmortizedLoan::AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_)
{
  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = moneyround(additionalperiodicpaymenttoprincipal_);
  num_pmnts =   num_pmnts_;
  freq = freq_;
  calc_periodicmortgagepayment();//int_rate_pct, num_pmnts, principal,freq);

}

AmortizedLoan::AmortizedLoan()
{
  principal = int_rate_pct = loan_amount = additionalperiodicpaymenttoprincipal = periodicmortgagepayment = 0;
  num_pmnts = freq = 0;
}
double AmortizedLoan::get_periodicmortgagepayment()
{
  return periodicmortgagepayment;
}
double AmortizedLoan::get_principal()
{
  return principal;
}
double  AmortizedLoan::get_loan_amount()
{
  return loan_amount;
}

void AmortizedLoan::set_principal(double p)
{
  principal=p;
  loan_amount=p;
}

void AmortizedLoan::calc_periodicmortgagepayment() //double int_rate, int num_pmnts, double principal, int freq)
{
  /* This function will calculate the payment amount of a loan.
     @ Inputs
     - int_rate - The interest rate of the loan
     - num_pmnts - The number of payments required
     - principal - The original amount of the loan (minus down-payment)
     - freq - Frequency of payments (weekly, monthly, quarterly, annually)
     @ Returns
     - pmnt_amt - The amount that each payment will be
  */
 
  double rr = int_rate_pct / freq;
  double x = pow((1.0 + rr), num_pmnts);
  double y = rr / (x - 1.0);
  double pmnt_amt = (rr + y) * principal;

    periodicmortgagepayment=moneyround(pmnt_amt);
    //periodicmortgagepayment=(pmnt_amt);
    //  printf("pmntamt %f periodicpayment %f\n" , pmnt_amt,periodicmortgagepayment);
}

double moneyround(double amt)
{
  return floor(amt*100 +0.5) / 100;
}
double AmortizedLoan::calc_paymenttowardsinterest()
{
  return moneyround(principal* int_rate_pct / freq );
}

double AmortizedLoan::calc_paymenttowardsprincipal()
{
  double paymenttowardsprincipal=0;
  //  if ( principal>0) // is this redundant? I think it is.
    {
      if (periodicmortgagepayment+additionalperiodicpaymenttoprincipal < principal)
	{//do I really want to calculate this including the add'l payment? It doesn't make sense not to. ==> this leads to double dipping of adding in the add'l payment
	  //	paymenttowardsprincipal=(periodicmortgagepayment+additionalperiodicpaymenttoprincipal-calc_paymenttowardsinterest());
	paymenttowardsprincipal=(periodicmortgagepayment-calc_paymenttowardsinterest());
	}
      else
	{
	  //we are making our final payment where we pay off the principal. The amount going towards the interest is not zero. 
	paymenttowardsprincipal=(principal);
	}
    }
  return moneyround(paymenttowardsprincipal);
}


//calculate the amount of each payment that goes toward principal and interest
double AmortizedLoan::calc_paymentpercentages()
{
  double paymenttowardsprincipal=0;
  //  if ( principal>0) // is this redundant? I think it is.
    {
      if (periodicmortgagepayment+additionalperiodicpaymenttoprincipal < principal)
	{
	  //	paymenttowardsprincipal=(periodicmortgagepayment+additionalperiodicpaymenttoprincipal-calc_paymenttowardsinterest());
	  paymenttowardsprincipal=(periodicmortgagepayment-calc_paymenttowardsinterest());
	}
      else
	{
	  //	std::cout<<"h---------------h";
	paymenttowardsprincipal=(principal-calc_paymenttowardsinterest());
	}
    }
  return paymenttowardsprincipal;
}

void AmortizedLoan::calc_newprincipal()
{
  double temp=0;
  if (periodicmortgagepayment+additionalperiodicpaymenttoprincipal < principal)
    {//i was double dipping on the extra payment towards principal
      temp=principal-calc_paymenttowardsprincipal()-additionalperiodicpaymenttoprincipal;
    }
      /*
  else
    {


      std::cout<<"final payment was "<<principal+calc_paymenttowardsinterest()<<"; is this the same as the monthly mort payment?"<<periodicmortgagepayment<<"\n";
      std::cout<<"Shouldn't the final payment be exactly one mortgage payment (or only off by a cent or two?)and not less?\nNO this is false. The final mortgage payment would only equal one full mortgage payment if when the mortgage payment was calculated it came out exactly to the hundredths place and didn't require rounding. Otherwise the rounding up will cause you to slightly overpay such that your last payment will be less than a full mortgage payment; Ugggh this might cause a problem when the mortgage payment is rounded down however. ";

    }
      */
  principal=moneyround(temp); //round off the cents so don't accumulate errors. Am guessing that this is how things are calculated by the banks. They don't carry over beyond the cents position.
  //  principal=temp;
  
}

//http://en.wikipedia.org/wiki/Mortgage_calculator#Monthly_payment_formula
double AmortizedLoan::AmountOwedAfterXMonths(int mon)
{//calculate the amount left on the loan after paying in X months worth of payments
  double oneplusrton = pow(1+int_rate_pct/12,mon);
  //This number will be off slightly due to it not having previous payments rounded off
    return moneyround(loan_amount*oneplusrton-periodicmortgagepayment*(oneplusrton-1)*12/int_rate_pct);
    //return moneyround(loan_amount*oneplusrton)-moneyround(periodicmortgagepayment*(oneplusrton-1)*12/int_rate_pct));
}

void AmortizedLoan::CalcAmortizationValues() //double periodicpayment,double int_rate, double principal,int freq, additionalperiodicpaymenttoprincipal)
{
  //  double paymenttowardsinterest=calc_paymenttowardsinterest();
  //double paymenttowardsprincipal=calc_paymenttowardsprincipal();
  if (periodicmortgagepayment<principal)       //if aren't paying extra then you'll hit 0 principal on your final payment, but if pay extra last payment will be less than what your normal payment would've been.
    {
      calc_newprincipal();
    }
  else //this case covers our last payment where the principal is less than the payment, 
    {
      principal=0;
    }
  //  return paymenttowardsinterest,paymenttowardsprincipal,principal

}
 
void AmortizedLoan::AmortizationTable2()//periodicpayment,int_rate,principal,freq,additionalperiodicpaymenttoprincipal):
{
  printf("months_to_pay_off total_interest_paid\n");// principal principalleft")
  int month=0;
  double totalinterest=0;
  int amountremaining=-99;
    while (amountremaining!=0)//principal > 0)
    {
      double paymenttowardsinterest=calc_paymenttowardsinterest();
      totalinterest+=paymenttowardsinterest;
      double paymenttowardsprincipal=calc_paymenttowardsprincipal();
      calc_newprincipal();
      month++;
      amountremaining=int(principal);
    }
  printf("%d %2.f\n" ,month,totalinterest);
}

//-------------------------------------------------------------------------------------

//kept getting:
//LoanCalculator.cpp:308: error: expected ‘)’ before ‘,’ token
//  LoanCalculator.cpp:324: error: expected initializer before ‘)’ token
//because I forgot to include the dataypes for the prototype since I cut and pasted.

class LoanComparison
{
public:
  //  LoanComparison();
  LoanComparison(double rate,int terminmonths, double amount,int paymentsperyear,double extrapayment,double monthlypayment);
  void PrintLoanAmortizationTableComparison();
  void PrintLoanDetails();
  double get_interest_saved();
  int get_time_periods_saved();
private:
  //  AmortizedLoan NormalLoan(),ExtraPaymentLoan();
  AmortizedLoan NormalLoan,ExtraPaymentLoan;
  double interestsaved;
  int numberofpayments;
};

double LoanComparison::get_interest_saved()
{
  return NormalLoan.get_totalinterestonloan()-ExtraPaymentLoan.get_totalinterestonloan();
}
int LoanComparison::get_time_periods_saved()
{ //compute the number of months/weeks/year/time periods reduced by paying off early
  return 6;
}
void LoanComparison::PrintLoanDetails()
  {
    std::cout<<"Details for loan without extra paymnets:";
    NormalLoan.PrintLoanDetails();
    std::cout<<"Details for loan --with-- extra paymnets:";
    ExtraPaymentLoan.PrintLoanDetails();
  }

void LoanComparison::PrintLoanAmortizationTableComparison()
{
  for (int i=0;i<numberofpayments;i++)
    {
      std::cout<<i<<"\t";
      NormalLoan.PrintCurrentIteration();
      ExtraPaymentLoan.PrintCurrentIteration();
      NormalLoan.IteratePayment();
      ExtraPaymentLoan.IteratePayment();
      std::cout<<"\n";
    }
  
  NormalLoan.PrintPeriodicMortgagePayment();
  NormalLoan.AmortizationAmounts();
  ExtraPaymentLoan.AmortizationAmounts();
  
  std::cout<<"By paying an extra $"<<ExtraPaymentLoan.get_overpaymenttoprincipal()<<" per pay period you saved $"<<NormalLoan.get_totalinterestonloan()-ExtraPaymentLoan.get_totalinterestonloan()<<" on interest and cut off "<<NormalLoan.get_monthstopayoffloan()-ExtraPaymentLoan.get_monthstopayoffloan()<<" months from the loan."<<std::endl;
  std::cout<<"Interest paid on loan without add'l payments towards principal:$"<<NormalLoan.get_totalinterestonloan()<<"\nInterest paid with extra payments:$"<<ExtraPaymentLoan.get_totalinterestonloan()<<"\n";
  
}

//LoanComparison::LoanComparison(){}
LoanComparison::LoanComparison(double rate,int terminmonths,double amount,int paymentsperyear,double extrapayment,double monthlypayment)
{
  //
  //  std::cout<<"setting variables etc\n";
  numberofpayments=terminmonths;
  //void AmortizedLoan::set_AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment)
  NormalLoan.set_AmortizedLoan(rate,amount,0,terminmonths,paymentsperyear,monthlypayment);
  ExtraPaymentLoan.set_AmortizedLoan(rate,amount,extrapayment,terminmonths,paymentsperyear,monthlypayment);
}
//-------------------------------------------------------------------------------------

void usage()
{
  std::cout<<"Please define the interest rate (i), loan amount (l), number of payments (n), and payments per year (p).\nAdditionally, you can specify extra payment amount to apply toward principal each pay period (e) or a monthly payment amount that includes the base payment plus any overage towards principal(m).\n./a.out -i 4.5 -l 120000 -p 12 -n 360 -e 30\n";
}

// getopt: http://pubs.opengroup.org/onlinepubs/000095399/functions/getopt.html http://stackoverflow.com/questions/2219562/using-getopt-to-parse-program-arguments-in-c
    
int main(int argc, char *argv[])
{

  
  int c;
  char *filename;
  extern char *optarg;
  extern int optind, optopt, opterr;

  //setup defaults
  double interest_rate=4.5;
  int numberOfPayments=4;//36;
  double loanAmount=100000.0;
  double extraPayments=1000;//240.0;
  int paymentsPerYear = 12;//"monthly"
  float monthlyPayments =0.0;

  if (argc > 3 )
    {
  interest_rate = loanAmount = extraPayments = monthlyPayments = 0.0;
  numberOfPayments = paymentsPerYear = 0;
    while ((c = getopt(argc, argv, ":i:n:l:e:p:m:")) != -1) {
      switch(c) {
      case 'i':
	interest_rate = atof(optarg);
        printf("interest_rate is %f\n", interest_rate);
        break;
  case 'n':
    numberOfPayments = atoi(optarg);
        printf("numberOfPayments is %d\n", numberOfPayments);
        break;
  case 'l':
    loanAmount= atof(optarg);
    printf("loanAmount is %f\n", loanAmount);
        break;
  case 'e':
    extraPayments = atof(optarg);
    printf("extraPayments is %f\n", extraPayments);
        break;
  case 'p':
    paymentsPerYear = atoi(optarg);
        printf("paymentsPerYear is %d\n", paymentsPerYear);
        break;
  case 'm':
    monthlyPayments = atof(optarg);
        printf("monthlyPayments is %f\n", monthlyPayments);
        break;
	/*case '':
         = optarg;
        printf(" is %s\n", );
        break; */
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
  //  AmortizedLoan al(r,la,ep,t,rt,00);
    //    if (monthlyPayments>0)
    LoanComparison LC(interest_rate,numberOfPayments,loanAmount,paymentsPerYear,extraPayments,monthlyPayments);
      //else
      // LoanComparison LC(interest_rate,numberOfPayments,loanAmount,paymentsPerYear,extraPayments,0);



  LC.PrintLoanDetails();
  LC.PrintLoanAmortizationTableComparison();
  /*/
  double balance = 1234.56;

  std::locale usloc;//("English_US");
  //  locale gloc("German_Germany");

  //  std::cout << std::showbase;

  std::cout.imbue(usloc);
  typedef std::ostreambuf_iterator<char, std::char_traits<char> > Iter;
  Iter begin (std::cout);
  const std::money_put<char,Iter> &us_mon = std::use_facet<std::money_put<char,Iter> >(usloc);//std::cout.getloc());
  //  const std::money_put<char> &us_mon = std::use_facet<std::money_put<char> >(usloc);//std::cout.getloc());




  us_mon.put(std::cout, false, std::cout, ' ', "123456");
  us_mon.put(std::cout, true, std::cout, ' ', -299);
  us_mon.put(std::cout, false, std::cout, ' ', balance * 100);
  / * /

  std::locale eloc;//create copy of current locale   // ("English_US");
  std::cout.imbue(eloc);

  std::cout << "English format: " << 12345678.12 << "\n\n";
  //*/


  /*
  al.AmortizationTable();  
  al.PrintPeriodicMortgagePayment();
  std::cout<<  moneyround(131.2455)<<" "<<  moneyround(131.25455)<<" "<<  moneyround(131.00455);
  printf("%f %f %f", moneyround(131.2455),  moneyround(131.25455), moneyround(131.00455));
  */


  /*
  //MonthlyPayment=1.5*payment //making a payment of ~150% of the regular mortgage payment will pay off the mortgage in about 1/2 the time.
    

  import sys,getopt

  try:
  options, remainder = getopt.gnu_getopt(sys.argv[1:], 'i:n:l:e:f:m:', ['--interest_rate=',
  '--number_of_payments=',
  '--loan_amount=',
  '--extra_principal_payment_amount=',
  '--payment_frequency=',
  '--monthly_payment_amount=',
  ])
  except getopt.GetoptError, err:
  // printf help information and exit:
  printf str(err) // will printf something like "option -a not recognized"
  //usage()
  sys.exit(2)

  for opt, arg in options:
  if opt in ('-i', '--interest_rate'):
  r = double(arg)
  elif opt in ('-n', '--number_of_payments'):
  t = int(arg)
  elif opt in ('-l', '--loan_amount'):
  la = double(arg)
  elif opt in ('-e', '--extra_principal_payment_amount'):
  ep = double(arg)
  elif opt in ('-f', '--payment_frequency'):
  rt = arg
  elif opt in ('-m', '--monthly_payment_amount'):
  MonthlyPayment = double(arg)
  elif opt == '--version':
  version = arg

  //    rt = None
  while rt not in ['weekly', 'biweekly', 'monthly', 'quarterly', 'annually']:
  if rt:
  rt = raw_input('Sorry that was not an option, please respond with weekly, monthly, quarterly, or annually: ').lower()
  else:
  rt = raw_input('Do you make your payments weekly, biweekly, monthly, quarterly, or annually? ').lower()
  */
  /*


  std::cout<<"-------why is this so jacked up compared to the python code??";  
  printf("Using %.2f %% interest rate for %d months on $ %.2f loan with payments due XXXX and additional XXX payments of $ %.2f\n", r,t,la,al.get_overpaymenttoprincipal());
  std::cout<<"make a class that compares two objects(loans),computes total  interest of loan,total cost of loan,computes amount saved by paying off early, is there no closed form formula to calculate how much a loan costs you?";
  */


  //check vs one of the online calcs. am I rounding to currency at the approp places?

  //the super class would just have two AmortizedLoan objects as members and then the super class would handle the comparison


  //  DualAmortizationTable(payment,r,la,rt,ep,t);
  //    AmortizationTable2(payment,r,la,rt,0)
  //    AmortizationTable2(payment,r,la,rt,ep)


}


//Create a function to calculate how much extra per month you would need to pay to pay off loan in X months instead of on normal schedule.
//This is just the difference between the normal mortgage payment for X periods vs Y periods.
//E.g. To pay off 30 yr in 15 yrs pay the 15 yr mortgage payment for your 30 yr mortgage. 

//write a bash version of this and see how much slower/faster it runs.
//write a java version of this and see how much faster it runs.
//write a C++ version of this and see how much faster it runs.
//write a C version of this and see how much faster it runs.


/*
  void AmortizedLoan::PrintfDual(int i,double pi1,double pp1,double p1,double pi2,double pp2,double p2)
  {
  double  pi1mpi2=0;
  double p1mp2=0;
  double pp2mpp1=0; //the payment to principal will be greater on the scenario where add'l payments are made.
  if (pi1-pi2>0)
  {
  pi1mpi2=pi1-pi2;
  }
  if (p1-p2>0 && p2!=0)
  {
  p1mp2=p1-p2;
  }
  
  printff("%3d | %10.2f  %10.2f %10.2f | %10.2f %10.2f %10.2f | %10.2f %10.2f " % (i,pi1,pp1,p1,pi2,pp2,p2,pi1mpi2,p1mp2));
    
  }

  void DualAmortizationTable(double periodicpayment,double int_rate, double principal,int freq,double additionalperiodicpaymenttoprincipal,int num_pmnts)
  {
  /*    import locale
  locale.setlocale(locale.LC_ALL,'') * /
  double p1=principal;
  double p2=principal;
  int i=1;
  double totint1=0;
  double totint2=0;
  bool  flag=false; //flag to prevent rewriting of month when p2 was paid off
  printf("//pmnt IntPmnt1 PrinPmnt1 Prin1 IntPmnt2 PrinPmnt2 Prin2 DiffIntPmnt DiffPrin");
  while (i <=  num_pmnts)
  {
  pi1,pp1,p1=CalcAmortizationValues(periodicpayment,int_rate,p1,freq,0);
  pi2,pp2,p2=CalcAmortizationValues(periodicpayment,int_rate,p2,freq,additionalperiodicpaymenttoprincipal);
  totint1+=pi1;
  totint2+=pi2;
  PrintfDual(i,pi1,pp1,p1,pi2,pp2,p2)

  if (p2==0 && flag==false) //this might not work since we can't *really* test if a double is 0
  {
  monthstopayoffwithaddlpayments=i;
  flag=true;
  }
	  
  i++;
  }
  printf("Total interest paid wo add'l payments:%s, with add'l payments %s, a difference of %s" % (locale.currency(totint1,grouping=True),locale.currency(totint2,grouping=True),locale.currency(totint1-totint2,grouping=True)))
  printf("The additional payments cut off %d months of the loan." % (num_pmnts-monthstopayoffwithaddlpayments))
  }
*/
