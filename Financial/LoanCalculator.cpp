//g++ -o LoanCalculator LoanCalculator.cppOB
/*
  http://en.cppreference.com/w/cpp/io/c/fprintf
  TODO: allow reading of a matrix/list of extra payments from a file that correspond to months when applied. ie. 3rd line = apply extra payment to 3rd month or 12:35 to symbolize a $35 add'l payment for the 12th pay period
include opiton to prohibit add'l payments for a set # of years. 

*/
#define DEBUG_PENALTY_PERIOD  0
//#include <locale.h> //for currency formatting
#include <unistd.h>  //for getopt
#include <getopt.h> //for getopt_long
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
  AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthly_payment, double taxes, double insurance);

  AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_);
  AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double  taxes_ , double insurance_);
  void   set_AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthly_payment, double taxes, double insurance, int penalty_periods);
  void   set_AmortizedLoan2(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthly_payment, double taxes, double insurance, int penalty_periods, float association_fees_);
  void PrintLoanDetails();
  void PrintCurrentIteration();
  void IteratePayment();
  double AmountOwedAfterXMonths(int mon);
  double get_periodicmortgagepayment();
  double get_periodicmortgagepaymentwithtaxesandinsurance();
  double get_principal();
  double get_loan_amount();
  double get_overpaymenttoprincipal();
  double get_totalinterestonloan();
  int get_monthstopayoffloan();
  void set_principal(double new_p);
  double calc_paymenttowardsinterest();
  double calc_paymenttowardsprincipal();
  void calc_newprincipal();
  void calc_newprincipal(bool);
  double calc_paymentpercentages();//only return the percentage of one and subtract this for the other. want this so can see how quickly the amount going ot int drops off
  //  double get_principal();
  void AmortizationTable();
  void AmortizationTable2();
  void PrintPeriodicMortgagePayment();
  void PrintPeriodicMortgagePaymentWithTaxesAndInsurance();
  void AmortizationAmounts();
  double ComputeLoanAmountAsIfMortgagePaymentPlusAssociationFeesWasTheMortgagePayment();
private:
  //  string GetPeriodString()
  void reset_principal();
  void calc_periodicmortgagepayment();//double int_rate, int num_pmnts, double principal, int freq);
  void CalcAmortizationValues();
  double int_rate_pct,principal,loan_amount,additionalperiodicpaymenttoprincipal,periodicmortgagepayment,totalcostofloan,totalinterestonloan,insurance_yearly,taxes_yearly, periodicmortgagepaymentwithtaxesandinsurance,association_fees;
  int num_pmnts,freq,monthstopayoffloan,penalty_periods;

};

int AmortizedLoan::get_monthstopayoffloan()
{return monthstopayoffloan;}

double AmortizedLoan::get_totalinterestonloan()
{
  return totalinterestonloan;
}
void AmortizedLoan::PrintLoanDetails()
{
  printf("Using %.2f %% interest rate for %d months on $ %.2f loan with payments due %i times a year and an additional %.2f applied towards principal each payment.\n", int_rate_pct*100,num_pmnts,loan_amount,freq,additionalperiodicpaymenttoprincipal);
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


void AmortizedLoan::PrintPeriodicMortgagePaymentWithTaxesAndInsurance()
{
  printf("Your mortgage payment with taxes and insurance will be %0.2f.\n" , periodicmortgagepaymentwithtaxesandinsurance);
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
{ //ummmm why do I have one function that simply calls another function? it'd be one thing if calc_newprincipal was private but its public
  calc_newprincipal();
}

void AmortizedLoan::AmortizationAmounts()
{
  reset_principal();
  double totalinterest=0;
  //while (principal > 0.000001) //the floating point must put the result off by just enough that the error accumulates over all the iterations.
  monthstopayoffloan=num_pmnts-1; //set default so we don't have an uninitialized variable; this was happening in the case where no extra payments were made.
  for (int i=0;i<num_pmnts;i++)
    {
      totalinterest+=calc_paymenttowardsinterest();//paymenttowardsinterest;
      if (i>penalty_periods)
	{
#if DEBUG_PENALTY_PERIOD
	printf("False i %i num_pmnts %i penalty_periods %i \n",i,num_pmnts,penalty_periods); 
#endif
	  calc_newprincipal(false);
	}
      else
	{
#if DEBUG_PENALTY_PERIOD
	printf("True i %i num_pmnts %i penalty_periods %i \n",i,num_pmnts,penalty_periods); 

#endif
	calc_newprincipal(true);
	}

      if (principal<=0.001)
	{	
	  monthstopayoffloan=i+1;//+1 since our first payment is at index 0 
	  //	  printf("i:%d;monthstopayoffloan:%d",i,monthstopayoffloan);
	  i=num_pmnts; //to break out of loop ....or could set totalinterestonloan=totalinterest; here and then return, breaking out of this function
	}
    }
  totalinterestonloan=totalinterest;
  //  std::cout<<"this really needs to be done in a while loop";
}

AmortizedLoan::AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment,  double taxes_yearly_, double insurance_yearly_)
{

  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = additionalperiodicpaymenttoprincipal_;
  num_pmnts =   num_pmnts_;
  freq = freq_;
  calc_periodicmortgagepayment();//int_rate_pct, num_pmnts, principal,freq);
  insurance_yearly=insurance_yearly_;
  taxes_yearly=taxes_yearly_;

  //override items if monthlypayment specified
  if (monthlypayment>moneyround(taxes_yearly/12.0)+moneyround(insurance_yearly/12.0)+periodicmortgagepayment && monthlypayment!=0) // <- will the second argument eval to false ever? use > 0.01 instead?
    additionalperiodicpaymenttoprincipal =monthlypayment-moneyround(taxes_yearly/12.0)-moneyround(insurance_yearly/12.0)-periodicmortgagepayment;

}
void AmortizedLoan::set_AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment, double taxes_yearly_, double insurance_yearly_,int penalty_periods_)
{
  //  std::cout<<"setting values";
  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = moneyround(additionalperiodicpaymenttoprincipal_);
  num_pmnts =   num_pmnts_;
  freq = freq_;
  insurance_yearly=insurance_yearly_;
  taxes_yearly=taxes_yearly_;
  penalty_periods=penalty_periods_;
  printf("%i %i",  penalty_periods,penalty_periods_);
  calc_periodicmortgagepayment();//int_rate_pct, num_pmnts, principal,freq);

  //override items if monthlypayment specified
  if (monthlypayment>moneyround(taxes_yearly/12.0)+moneyround(insurance_yearly/12.0)+periodicmortgagepayment && monthlypayment>0) //monthlypayment!=0) // <- will the second argument eval to false ever? use > 0.01 instead?
    {
    additionalperiodicpaymenttoprincipal = moneyround(monthlypayment-moneyround(taxes_yearly/12.0)-moneyround(insurance_yearly/12.0)-periodicmortgagepayment);
    //    std::cout<<"statement is true";
    }
    //printf("add'l payment %f",additionalperiodicpaymenttoprincipal);

}
void AmortizedLoan::set_AmortizedLoan2(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment, double taxes_yearly_, double insurance_yearly_,int penalty_periods_, float association_fees_)
{
  //  std::cout<<"setting values";
  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = moneyround(additionalperiodicpaymenttoprincipal_);
  num_pmnts =   num_pmnts_;
  freq = freq_;
  insurance_yearly=insurance_yearly_;
  taxes_yearly=taxes_yearly_;
  penalty_periods=penalty_periods_;
  //  printf("penalt periods:%i %i\n",  penalty_periods,penalty_periods_);
  calc_periodicmortgagepayment();//int_rate_pct, num_pmnts, principal,freq);
  association_fees=association_fees_;

  //override items if monthlypayment specified
  if (monthlypayment>moneyround(taxes_yearly/12.0)+moneyround(insurance_yearly/12.0)+periodicmortgagepayment && monthlypayment>0) //monthlypayment!=0) // <- will the second argument eval to false ever? use > 0.01 instead?
    {
    additionalperiodicpaymenttoprincipal = moneyround(monthlypayment-moneyround(taxes_yearly/12.0)-moneyround(insurance_yearly/12.0)-periodicmortgagepayment);
    //    std::cout<<"statement is true";
    }
    //printf("add'l payment %f",additionalperiodicpaymenttoprincipal);

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
  insurance_yearly=0;
  taxes_yearly=0;

}
AmortizedLoan::AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_,double taxes_,double insurance_ )
{
  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  insurance_yearly=insurance_;
  taxes_yearly=taxes_;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = moneyround(additionalperiodicpaymenttoprincipal_);
  num_pmnts =   num_pmnts_;
  freq = freq_;
  calc_periodicmortgagepayment();//int_rate_pct, num_pmnts, principal,freq);

}

AmortizedLoan::AmortizedLoan()
{
  principal = int_rate_pct = loan_amount = additionalperiodicpaymenttoprincipal = periodicmortgagepayment = insurance_yearly = taxes_yearly = 0.0;
  num_pmnts = freq = 0;
}
double AmortizedLoan::get_periodicmortgagepayment()
{
  return periodicmortgagepayment;
}
double AmortizedLoan::get_periodicmortgagepaymentwithtaxesandinsurance()
{
  return periodicmortgagepaymentwithtaxesandinsurance;
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
  periodicmortgagepaymentwithtaxesandinsurance=moneyround(pmnt_amt) +moneyround(insurance_yearly/freq)+moneyround(taxes_yearly/freq);
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

void AmortizedLoan::calc_newprincipal(bool Penalty)
{
  double temp=0;
  if (periodicmortgagepayment+additionalperiodicpaymenttoprincipal < principal)
    {//i was double dipping on the extra payment towards principal
      temp=principal-calc_paymenttowardsprincipal();
	if (!Penalty) //If we are outside the prepayment penalty period then apply the additional payments.
	temp-=additionalperiodicpaymenttoprincipal;
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
      amountremaining=moneyround(principal);//int(principal);
    }
  printf("%d %2.f\n" ,month,totalinterest);
}

double AmortizedLoan::ComputeLoanAmountAsIfMortgagePaymentPlusAssociationFeesWasTheMortgagePayment()
{
  double rr = int_rate_pct / freq;
  double principal_no_condo_fees = 0;
  
  principal_no_condo_fees=(periodicmortgagepayment+association_fees)*(1-(pow(1+rr,-num_pmnts)))/rr;
  printf("A $%0.2f monthly mortgage payment with $%0.2f in monthly condo and association fees for a $%0.2f loan would be akin to a $%0.2f monthly mortgage payment on a $%0.2f loan.\n", periodicmortgagepayment,association_fees,principal, periodicmortgagepayment+association_fees, principal_no_condo_fees);
  return principal_no_condo_fees ;
   

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
  LoanComparison(double rate,int terminmonths, double amount,int paymentsperyear,double extrapayment,double monthlypayment,double taxes, double insurance,int penatly_periods);
  void PrintLoanAmortizationTableComparison();
  void PrintLoanAmortizationComparison();
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
  std::cout<<"Details for loan without extra payments:\n";
  NormalLoan.PrintLoanDetails();
  std::cout<<"Details for loan --with-- extra payments:\n";
  ExtraPaymentLoan.PrintLoanDetails();
}


void LoanComparison::PrintLoanAmortizationTableComparison()
{
  if ( 1==1)
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
    }  
}
void LoanComparison::PrintLoanAmortizationComparison()
{
  NormalLoan.PrintPeriodicMortgagePayment();
  NormalLoan.PrintPeriodicMortgagePaymentWithTaxesAndInsurance();
  NormalLoan.AmortizationAmounts();
  ExtraPaymentLoan.AmortizationAmounts();
  //  std::cout<<NormalLoan.get_totalinterestonloan()<<"-"<<ExtraPaymentLoan.get_totalinterestonloan()<<","<<NormalLoan.get_monthstopayoffloan()<<"-"<<ExtraPaymentLoan.get_monthstopayoffloan()<<std::endl;
  std::cout<<"By paying an extra $"<<ExtraPaymentLoan.get_overpaymenttoprincipal()<<" per pay period you saved $"<<NormalLoan.get_totalinterestonloan()-ExtraPaymentLoan.get_totalinterestonloan()<<" on interest and cut off "<<NormalLoan.get_monthstopayoffloan()-ExtraPaymentLoan.get_monthstopayoffloan()<<" months from the loan."<<std::endl;
  std::cout<<"Interest paid on loan without add'l payments towards principal:$"<<NormalLoan.get_totalinterestonloan()<<"\nInterest paid with extra payments:$"<<ExtraPaymentLoan.get_totalinterestonloan()<<"\n";
  
}

//LoanComparison::LoanComparison(){}
LoanComparison::LoanComparison(double rate,int terminmonths,double amount,int paymentsperyear,double extrapayment,double monthlypayment, double taxes, double insurance,int penalty_periods)
{
  //
  //  std::cout<<"setting variables etc\n";
  //std::cout<<"extrapayment:"<<extrapayment;
  numberofpayments=terminmonths;
  //void AmortizedLoan::set_AmortizedLoan(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment)
  NormalLoan.set_AmortizedLoan(rate,amount,0,terminmonths,paymentsperyear,0,taxes, insurance,penalty_periods);
  ExtraPaymentLoan.set_AmortizedLoan(rate,amount,extrapayment,terminmonths,paymentsperyear,monthlypayment,taxes,insurance,penalty_periods);
}
//-------------------------------------------------------------------------------------

void usage()
{
  std::cout<<"Please define the interest rate (i), loan amount (l), number of payments (n), and payments per year (p).\nAdditionally, you can specify extra payment amount to apply toward principal each pay period (e) or a monthly payment amount that includes the base payment plus any overage towards principal (m).\nTo simplify actual scenarios you may also specify annual property taxes(), mortgage insurance (),. In lieu of calculating a loan amount you can specify the house purchase price () and down payment amount () and the required loan amount will be calculated from this information.\n ./a.out -i 4.5 -l 100000  -n 360  -p 12 -d 20 -t 2700  -e 30 -h 120000  -f 120\n./a.out --interest-rate=4.5 --loan-amount=100000 --number-of-payments=360 --payments-per-year=12 --down-payment=20 --taxes=2700 --insurance=600 --monthly-payment=800 --extra-payment=30 --house-price=120000 --table  --penatly-periods=36 --association-fee=120";
}

// getopt: http://pubs.opengroup.org/onlinepubs/000095399/functions/getopt.html http://stackoverflow.com/questions/2219562/using-getopt-to-parse-program-arguments-in-c
    
int main(int argc, char *argv[])
{
 
  int c;
  char *filename;
  extern char *optarg;
  extern int optind, optopt, opterr;

  //setup defaults
  double interest_rate=0;//4.5;
  int numberOfPayments=0;//360;//4;//36;
  double loanAmount=0;//100000.0;
  double extraPayments=0;//1000;//240.0;
  int paymentsPerYear = 0;//12;//"monthly"
  int houseprice=0;//100000;
  int downpaymentPct=0;//20;
  float monthlyPayments =0.0;
  double insurance=0.0;
  double taxes=0;//2700.0; //this amount is approximately what taxes are on 828 Greenmount (was 1362 semi-annually)
  int show_table_flag=0;
  int house_price_flag=0,down_payment_flag=0,penalty_periods=0; 
  double /*float*/ association_fee=0;
  static struct option long_options[] = {
    {"?", 0, 0, 0},
    {"interest-rate", required_argument, 0, 'i'},
    {"number-of-payments", required_argument, 0, 'n'},
    {"loan-amount", required_argument, 0, 'l'},
    {"payments-per-year", required_argument, 0, 'p'},
    {"down-payment", required_argument, 0,'d'}, //&down_payment_flag, 'd'},
    {"house-price", required_argument, 0, 'h'}, //&house_price_flag, 'h'},
    {"taxes", required_argument, 0, 't'},
    {"insurance", required_argument, 0, 's'},
    {"monthly-payment", required_argument, 0, 'm'},
    {"extra-payment", required_argument, 0, 'e'},
    {"penalty-period", required_argument, 0, 'y'},
    {"association-fee", required_argument, 0, 'f'},
    {"table", no_argument, 0, 'a'},
    {NULL, 1, NULL, 0} //this MUST be last entry 
  };

  /*

I totally forgot about using capital letters for optargs

   */
  int option_index=0;

  if (argc > 3 )
    {
      interest_rate = loanAmount = extraPayments = monthlyPayments = 0.0;
      numberOfPayments = paymentsPerYear = 0;
      while ((c = getopt_long(argc, argv, ":i:n:l:e:p:m:t:s:d:h:f:a",long_options,&option_index)) != -1) {
	switch(c) {
	case 0:
	  printf ("option %s", long_options[option_index].name);
	  if (optarg)
	    printf (" with arg %s", optarg);
	  printf ("\n");
	  break;
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
	case 'd':
	  downpaymentPct = atoi(optarg);
	  printf("downpaymentPct is %d\n", downpaymentPct);
	  down_payment_flag=1; // if we set defaults to 0 then we just need to check for that, but if we set up a default case then it's good to check flags or that it isn't the default value;
	  break;
	case 'h':
	  houseprice = atoi(optarg);
	  printf("houseprice is %d\n", houseprice); 
	  house_price_flag=1;
	  break;
	case 'm':
	  monthlyPayments = atof(optarg);
	  printf("monthlyPayments is %f\n", monthlyPayments);
	  break;
	  /*case '':
	    = optarg;
	    printf(" is %s\n", );
	    break; */
	case 's':
	  insurance = atof(optarg);
	  printf("insurance is %f\n",insurance );
	  break;
	case 't':
	  taxes  = atof(optarg);
	  printf("taxes is %f\n",taxes );
	  break;
	case 'y':
	  penalty_periods  = atoi(optarg);
	  printf("penalty_periods is %i; is it better to take penalty than to not pay during penalty period? I bet the banks made it so it isn't worth it\n",penalty_periods );
	  break;
	case 'f': //why does this segfault? because you were trying to atoi(null) you had the : before the f not after to denote that an option is mandatory
	  association_fee  = atoi(optarg);
	  //	  printf("optarg:%s",optarg);
	  //association_fee  = 150;
	  printf("monthly association fee of %f\n",association_fee ); //this is difficult since we I feel like there are monthly condo fees, plus querterly/yearly assoc fees etc. So how do we handle this so that the user just inputs numbers and the program does the math. ?
	  break;
	case 'a':
	  show_table_flag  = true;
	  printf("show amortization table");
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

  //I need to check and make sure that enough information is being supplied to actually compute a calculation
  printf(" Check void AmortizedLoan::calc_periodicmortgagepayment() for the 4 min arguments needed to compute, pass in house price or down payment pct so that you can back calculate how the equiv house without condos fees");
  if (downpaymentPct!=0 && houseprice==0 && loanAmount > 0)
    {
      printf("You specified a down payment percentage but not a house price.\nSubstituting loan amount for house price.\n");// Would you like to substitute the loan amount as the house price? (Y/n)\n")
      houseprice = loanAmount;
    }


  if (houseprice!=0 && downpaymentPct!=0) //should I use > instead of !=??
    loanAmount=houseprice*(100-downpaymentPct)/100.0;
  //interest_rate, numberOfPayments, paymentsPerYear
  //loanAmount or houseprice & downpaymentPct
  //extraPayments or monthlyPayments
  //  std::cout<<"loan amount is:"<<loanAmount<<"\n";


    AmortizedLoan NormalLoan;
  NormalLoan.set_AmortizedLoan2(interest_rate,loanAmount,0,numberOfPayments,paymentsPerYear,0,taxes,insurance,penalty_periods,association_fee);//rate,amount,0,terminmonths,paymentsperyear,0,taxes, insurance,penalty_periods);
  // NormalLoan.;
  
    NormalLoan.ComputeLoanAmountAsIfMortgagePaymentPlusAssociationFeesWasTheMortgagePayment();
    NormalLoan.PrintPeriodicMortgagePayment();
  //double AmortizedLoan::ComputeLoanAmountAsIfMortgagePaymentPlusAssociationFeesWasTheMortgagePayment()
  if (false)
    {    

  //  printf("extrapayments %f",extraPayments);
  LoanComparison LC(interest_rate,numberOfPayments,loanAmount,paymentsPerYear,extraPayments,monthlyPayments,taxes,insurance,penalty_periods);
  //else
  // LoanComparison LC(interest_rate,numberOfPayments,loanAmount,paymentsPerYear,extraPayments,0);



  LC.PrintLoanDetails();
  if (show_table_flag)
    LC.PrintLoanAmortizationTableComparison();
  LC.PrintLoanAmortizationComparison();
  std::cout<<"Redo passing single variables with a struct?? Like I did in Gweled."<<std::endl;

    }
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


  //the super class would just have two AmortizedLoan objects as members and then the super class would handle the comparison



}

/*
Penalty payments aren't really a concern when interest rates are low and you can make more money elsewhere.
I read about there being stipulations in fixed rate mortgages of prepayment penalties for the first 3-5 years.
*/


//Create a function to calculate how much extra per month you would need to pay to pay off loan in X months instead of on normal schedule.
//This is just the difference between the normal mortgage payment for X periods vs Y periods.
//E.g. To pay off 30 yr in 15 yrs pay the 15 yr mortgage payment for your 30 yr mortgage. 

//write a bash version of this and see how much slower/faster it runs.
//write a java version of this and see how much faster it runs.
//write a C++ version of this and see how much faster it runs.
//write a C version of this and see how much faster it runs.


