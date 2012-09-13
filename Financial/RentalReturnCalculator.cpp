/*
  http://en.cppreference.com/w/cpp/io/c/fprintf
  TODO: allow reading of a matrix/list of extra payments from a file that correspond to months when applied. ie. 3rd line = apply extra payment to 3rd month

*/
//g++ -o RentalReturnCalc RentalReturnCalculator.cpp


#include <unistd.h>  //for getopt
#include <getopt.h> //for getopt_long
#include <math.h> //for pow 
#include <cstdio>
#include <cstdlib> //for atoi atof
#include <string.h>
#include <iostream>

//The *only* way to decrease the amount of interest paid for a set of variables is to pay extra towards the principal. Increaseing the frequency of payment (but making a smaller payment) doesn't do anything towards reducing the amount of interest paid. The whole basis of the biweekly payment plan is that each year you pay an additional monthly mortgage payment that is applied towards principal. For a given amount of principal and interest rate, the only other way to decrease the amount paid towards interest besides add'l payments towards principal is to increase the frequency of payments. However, I'm not sure that banks would make amortizations schedules for less than monthly payments.
//E.g. for a $100,000 loan at 4.5% interest you would pay $4,500 for the first year in interest. But if you pay with monthly payments you pay only $4,308.25 in interest on the first year because the amount that goes towards interest is recalculated more frequently where the principal is lower.

//However, the impact of increased frequency in the amortization table isn't as big a gain as one might expect. For the above case, the amount of interest paid on 12 payments per year is $82,404.60. The amount of interest paid on 240 payments per year is $82.277.40, a difference of $127.20 -->  ./a.out -i 4.5 -l 100000 -p 12 -n 360  vs  ./a.out -i 4.5 -l 100000 -p 24 -n 7200 
//If instead you made an additional $1 contribution per pay period on the 12 payments per year loan you would save $398.17 in interest over the life of the loan. -->  ./a.out -i 4.5 -l 100000 -p 12 -n 360 -e 1
// ./a.out -i 4.5 -l 100000 -p 240 -n 7200 -e 1


//---->> Ultimate Lesson: Paying off add'l principal per pay period has the greatest impact

struct PropertyLoanDetails{
  double monthlyPayments,interest_rate,rent_inflation,insurance,taxes,down_payment,loanAmount,extraPayments,downpaymentPct,house_appreciation;
  int numberOfPayments,paymentsPerYear,rent_payment, houseprice;
};

double moneyround(double amt);

class AmortizedLoan
{
public:
  AmortizedLoan();
  AmortizedLoan( PropertyLoanDetails);
  void   set_AmortizedLoan(PropertyLoanDetails);
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
  double calc_paymentpercentages();//only return the percentage of one and subtract this for the other. want this so can see how quickly the amount going ot int drops off
  //  double get_principal();
  void calc_equity();
  void AmortizationTable();
  void AmortizationTable2();
  void PrintPeriodicMortgagePayment();
  void PrintPeriodicMortgagePaymentWithTaxesAndInsurance();
  void AmortizationAmounts();
private:
  //  string GetPeriodString()
  void reset_principal();
  void calc_periodicmortgagepayment();//double int_rate, int num_pmnts, double principal, int freq);
  void CalcAmortizationValues();
  double int_rate_pct,principal,loan_amount,additionalperiodicpaymenttoprincipal,periodicmortgagepayment,totalcostofloan,totalinterestonloan,insurance_yearly,taxes_yearly, periodicmortgagepaymentwithtaxesandinsurance,equity_in_property,rent_inflation,propertyprice,downpaymentPct,house_appreciation;
  int num_pmnts,freq,monthstopayoffloan,rent_payment;
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
{
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
      calc_newprincipal();
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

AmortizedLoan::AmortizedLoan(PropertyLoanDetails PLD)//  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment,  double taxes_yearly_, double insurance_yearly_)
{
  if (PLD.loanAmount>0&&PLD.houseprice>0)
    std::cout<<"Loan amount and house price both specified. House price is overriding the loan amount."<<std::endl;
  if (PLD.houseprice!=0 && PLD.downpaymentPct!=0) //should I use > instead of !=??
    loan_amount=PLD.houseprice*(1-PLD.downpaymentPct);
  //interest_rate, numberOfPayments, paymentsPerYear
  //loanAmount or houseprice & downpaymentPct
  //extraPayments or monthlyPayments

  principal =  loan_amount;
  int_rate_pct =  PLD.interest_rate;
  additionalperiodicpaymenttoprincipal = PLD.extraPayments;
  num_pmnts =   PLD.numberOfPayments;//num_pmnts_;
  freq = PLD.paymentsPerYear;//freq_;
  insurance_yearly=PLD.insurance;
  taxes_yearly=PLD.taxes;
  propertyprice=PLD.houseprice;
  downpaymentPct=PLD.downpaymentPct;
  rent_payment = PLD.rent_payment;
  rent_inflation = PLD.rent_inflation;
  house_appreciation=PLD.house_appreciation;
  equity_in_property=0;

  calc_periodicmortgagepayment(); //needs variables set before calculation.

  //override items if monthlypayment specified
  if (PLD.monthlyPayments>moneyround(taxes_yearly/12.0)+moneyround(insurance_yearly/12.0)+periodicmortgagepayment && PLD.monthlyPayments>0) // <- will the second argument eval to false ever? use > 0.01 instead?
    {
      additionalperiodicpaymenttoprincipal = moneyround(PLD.monthlyPayments-moneyround(taxes_yearly/12.0)-moneyround(insurance_yearly/12.0)-periodicmortgagepayment);
      //      additionalperiodicpaymenttoprincipal =monthlypayment-moneyround(taxes_yearly/12.0)-moneyround(insurance_yearly/12.0)-periodicmortgagepayment;
    }
  else
    additionalperiodicpaymenttoprincipal=PLD.extraPayments;
}

void AmortizedLoan::set_AmortizedLoan(PropertyLoanDetails PLD)//  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment, double taxes_yearly_, double insurance_yearly_,int rent_payment_,double rent_inflation_)
{
  std::cout<<"I should just copy the PLD object instead of doing all this crap."<<std::endl;
  if (PLD.loanAmount>0&&PLD.houseprice>0)
    {
      loan_amount=PLD.houseprice*(1-PLD.downpaymentPct);
      std::cout<<"Loan amount and house price both specified. House price is overriding the loan amount."<<std::endl<<"Loan is for "<<loan_amount<<"."<<std::endl;
      //  if (PLD.houseprice>0 && PLD.downpaymentPct>0) //should I use > instead of !=??
     
    }
  principal =    loan_amount;
  int_rate_pct =  PLD.interest_rate;

  additionalperiodicpaymenttoprincipal = PLD.extraPayments;
  num_pmnts =   PLD.numberOfPayments;//num_pmnts_;
  freq = PLD.paymentsPerYear;//freq_;

  //  std::cout<<"pld.ins"<<PLD.insurance<<std::endl;
  insurance_yearly=PLD.insurance;
  taxes_yearly=PLD.taxes;
  propertyprice=PLD.houseprice;
  downpaymentPct=PLD.downpaymentPct;
  //  std::cout<<"taxes : "<<taxes_yearly<<" ins :"<<insurance_yearly<<" "<<taxes_yearly/freq<<" "<<insurance_yearly/freq<<std::endl;
  rent_payment = PLD.rent_payment;
  rent_inflation = PLD.rent_inflation;
  house_appreciation=PLD.house_appreciation;
  equity_in_property=0;

  calc_periodicmortgagepayment(); //needs variables set before calculation.

  //override items if monthlypayment specified
  if (PLD.monthlyPayments>moneyround(taxes_yearly/12.0)+moneyround(insurance_yearly/12.0)+periodicmortgagepayment && PLD.monthlyPayments>0) // <- will the second argument eval to false ever? use > 0.01 instead?
    {
      additionalperiodicpaymenttoprincipal = moneyround(PLD.monthlyPayments-moneyround(taxes_yearly/12.0)-moneyround(insurance_yearly/12.0)-periodicmortgagepayment);
      //      additionalperiodicpaymenttoprincipal =monthlypayment-moneyround(taxes_yearly/12.0)-moneyround(insurance_yearly/12.0)-periodicmortgagepayment;
    }
  else
    additionalperiodicpaymenttoprincipal=PLD.extraPayments;

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
  periodicmortgagepaymentwithtaxesandinsurance=periodicmortgagepayment+moneyround(insurance_yearly/freq)+moneyround(taxes_yearly/freq);//moneyround(pmnt_amt) +moneyround(insurance_yearly/freq)+moneyround(taxes_yearly/freq);
  //  printf("ins %f ins / freq %f roundeed %f taxes %f taxes /freq %f rounded %f",insurance_yearly,insurance_yearly/freq,moneyround(insurance_yearly/freq),taxes_yearly,taxes_yearly/freq,moneyround(taxes_yearly/(freq+0.0)));
  //periodicmortgagepayment=(pmnt_amt);
  //printf("pmntamt %f periodicpayment %f with taxes and ins %f\n" , pmnt_amt,periodicmortgagepayment,periodicmortgagepaymentwithtaxesandinsurance);
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
void AmortizedLoan::calc_equity()
{
  reset_principal();//make sure calculation is starting over
  double total_equity=propertyprice*downpaymentPct;
  //  std::cout<<"still need to add in downpayment towards equity as well as divide by the downpayment for annualized return. also need to add in house appreciation towards equity"<<std::endl;
  int  month=0;
  int year=0;
  std::cout<<freq<<std::endl;
  while ( principal > 0.000001)
    {
      total_equity+=rent_payment-calc_paymenttowardsinterest();//periodicmortgagepayment+calc_paymenttowardsprincipal();

      year=month/freq+1;
      int trigger=month%freq;
      if (trigger==0)
	{
	  double annualreturn=pow(total_equity/(propertyprice*downpaymentPct),1/(year+0.0));
	  printf("Annual return for rental at year %d is %f; total_equity %f: year %d: month %d\n",year,annualreturn,total_equity,year,month);
	  rent_payment*=(1+rent_inflation);//update rent for inflation
	  total_equity+=propertyprice*pow(house_appreciation+1,year)-propertyprice;//we just get the portion of the house price that it has appreciated. so if we bought for 100k and now worth 110, we just own the 10k of appreciation ; also you can't just divide the house_appreciation by 12 and perform appreciation monthly as this produces a diff result than compounding annually
	}
      //      std::cout<<principal<<std::endl;     
      calc_newprincipal();
      month++;
    }
  printf("At the end of the loan the total amount of equity you have is %f\nThe monthly rent payments are now %d\n.",total_equity,rent_payment);
  printf("The equity calculation is true but there is the additional cost of property taxes that suck away from your annualized return.\nThe property taxes would probably grow at a rate reflected in the rate increase of rent.\nHOw often are property taxes reevaluated? Would you be workign at a reduced rate of return until you increased rent to reflect the yearly incresae in property taxes? ");
  printf("(2012-07-02)I think that there are simply too many facets that I'm unfamiliar with, such as property taxes as well as tax reduction due to mortgage interest, to accurately formulate a return on investment at this time.");
  //it appears that taxes are reassessed on a 6 yr cycle in ohio and updated every 3 years. Not sure what that exactly means however. source:http://tax.ohio.gov/divisions/real_estate/reappraisal_and_triennial_update.stm http://tax.ohio.gov/divisions/real_property/index.stm
  reset_principal();
}

void AmortizedLoan::calc_newprincipal()
{
  double temp=0;
  if (periodicmortgagepayment+additionalperiodicpaymenttoprincipal < principal)
    {
      temp=principal-calc_paymenttowardsprincipal()-additionalperiodicpaymenttoprincipal;
    }
  principal=moneyround(temp); //round off the cents so don't accumulate errors. Am guessing that this is how things are calculated by the banks. They don't carry over beyond the cents position.
  
}

//http://en.wikipedia.org/wiki/Mortgage_calculator#Monthly_payment_formula
double AmortizedLoan::AmountOwedAfterXMonths(int mon)
{//calculate the amount left on the loan after paying in X months worth of payments
  double oneplusrton = pow(1+int_rate_pct/12,mon);
  //This number will be off slightly due to it not having previous payments rounded off
  return moneyround(loan_amount*oneplusrton-periodicmortgagepayment*(oneplusrton-1)*12/int_rate_pct);
  //return moneyround(loan_amount*oneplusrton)-moneyround(periodicmortgagepayment*(oneplusrton-1)*12/int_rate_pct));
}

void AmortizedLoan::CalcAmortizationValues() 
{
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
 
void AmortizedLoan::AmortizationTable2()
{
  printf("months_to_pay_off total_interest_paid\n");
  int month=0;
  double totalinterest=0;
  int amountremaining=-99;
  while (amountremaining!=0)
    {
      double paymenttowardsinterest=calc_paymenttowardsinterest();
      totalinterest+=paymenttowardsinterest;
      double paymenttowardsprincipal=calc_paymenttowardsprincipal();
      calc_newprincipal();
      month++;
      amountremaining=moneyround(principal);
    }
  printf("%d %2.f\n" ,month,totalinterest);
}

//-------------------------------------------------------------------------------------

class LoanComparison
{
public:

  LoanComparison(PropertyLoanDetails);//double rate,int terminmonths, double amount,int paymentsperyear,double extrapayment,double monthlypayment,double taxes, double insurance,int rent_payment, double rent_inflation);
  void PrintLoanAmortizationTableComparison();
  void PrintLoanAmortizationComparison();
  void PrintLoanDetails();
  double get_interest_saved();
  int get_time_periods_saved();
private:
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
void LoanComparison::PrintLoanAmortizationComparison()
{
  NormalLoan.PrintPeriodicMortgagePayment();
  NormalLoan.PrintPeriodicMortgagePaymentWithTaxesAndInsurance();
  NormalLoan.AmortizationAmounts();
  ExtraPaymentLoan.AmortizationAmounts();
  //  std::cout<<NormalLoan.get_totalinterestonloan()<<"-"<<ExtraPaymentLoan.get_totalinterestonloan()<<","<<NormalLoan.get_monthstopayoffloan()<<"-"<<ExtraPaymentLoan.get_monthstopayoffloan()<<std::endl;
  std::cout<<"By paying an extra $"<<ExtraPaymentLoan.get_overpaymenttoprincipal()<<" per pay period you saved $"<<NormalLoan.get_totalinterestonloan()-ExtraPaymentLoan.get_totalinterestonloan()<<" on interest and cut off "<<NormalLoan.get_monthstopayoffloan()-ExtraPaymentLoan.get_monthstopayoffloan()<<" months from the loan."<<std::endl;
  std::cout<<"Interest paid on loan without add'l payments towards principal:$"<<NormalLoan.get_totalinterestonloan()<<"\nInterest paid with extra payments:$"<<ExtraPaymentLoan.get_totalinterestonloan()<<"\n";
  NormalLoan.calc_equity();
  
}

LoanComparison::LoanComparison(PropertyLoanDetails PLD)//double rate,int terminmonths,double amount,int paymentsperyear,double extrapayment,double monthlypayment, double taxes, double insurance,int rent,double rent_inflation)
{

  numberofpayments=PLD.numberOfPayments;

  ExtraPaymentLoan.set_AmortizedLoan(PLD);//rate,amount,extrapayment,terminmonths,paymentsperyear,monthlypayment,taxes,insurance,rent,rent_inflation);
  PLD.extraPayments=0;//set for normal loan wo extra payment
  //would a better way to have a flag in the PLD for extra payment and to have two separate PLD
  NormalLoan.set_AmortizedLoan(PLD);//rate,amount,0,terminmonths,paymentsperyear,0,taxes, insurance,rent,rent_inflation);
}
//-------------------------------------------------------------------------------------

void usage()
{
  std::cout<<"Please define the interest rate (i), loan amount (l), number of payments (n), and payments per year (p).\nAdditionally, you can specify extra payment amount to apply toward principal each pay period (e) or a monthly payment amount that includes the base payment plus any overage towards principal (m).\nTo simplify actual scenarios you may also specify annual property taxes(), mortgage insurance (). In lieu of calculating a loan amount you can specify the house purchase price () and down payment amount () and the required loan amount will be calculated from this information.\n ./a.out -i 4.5 -l 120000 -p 12 -n 360 -e 30 -t 2700 -h 100000 -d 20 -r 450 -f 1\n./a.out --interest-rate=4.5 --loan-amount=100000 --number-of-payments=360 --payments-per-year=12 --down-payment=15 --taxes=2800 --insurance=600 --monthly-payment=800 --extra-payment=30 --house-price=120000 --table -rent-payment 650 -rent-inflation 1";
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
  float downpaymentPct=0;//20;
  float monthlyPayments =0.0;
  double insurance=0.0;
  double taxes=0;//2700.0; //this amount is approximately what taxes are on 828 Greenmount (was 1362 semi-annually)
  int show_table_flag=0;
  int house_price_flag=0,down_payment_flag=0; 
  int rent_payment=0;
  float rent_inflation=0;
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
    {"rent-payment", required_argument, 0, 'r'},
    {"rent-inflation", required_argument, 0, 'f'},
    {"house-appreciation", required_argument, 0, 'o'},
    {"table", no_argument, 0, 'a'},
    {NULL, 1, NULL, 0} //this MUST be last entry 
  };

  PropertyLoanDetails PLD;
  std::cout<<"  ///need to initialize PLD---------"<<std::endl;
  PLD.insurance=0;

  int option_index=0;

  if (argc > 3 )
    {
      PLD.interest_rate = PLD.loanAmount = PLD.extraPayments = PLD.monthlyPayments = 0.0;
      PLD.numberOfPayments = PLD.paymentsPerYear = 0;
      while ((c = getopt_long(argc, argv, ":i:n:l:e:p:m:t:s:d:h:ar:f:o:",long_options,&option_index)) != -1) {
	switch(c) {
	case 0:
	  printf ("option %s", long_options[option_index].name);
	  if (optarg)
	    printf (" with arg %s", optarg);
	  printf ("\n");
	  break;
	case 'i':
	  PLD.interest_rate = atof(optarg);
	  if  (!(PLD.interest_rate<1))
	    {//if  expressed as decimal, then convert to float e.g. 3 -> 0.03
	      PLD.interest_rate/=100;
	    }

	  printf("interest_rate is %f\n", PLD.interest_rate);
	  break;
	case 'n':
	  PLD.numberOfPayments = atoi(optarg);
	  printf("numberOfPayments is %d\n", PLD.numberOfPayments);
	  break;
	case 'l':
	  PLD.loanAmount= atof(optarg);
	  printf("loanAmount is %f\n", PLD.loanAmount);
	  break;
	case 'e':
	  PLD.extraPayments = atof(optarg);
	  printf("extraPayments is %f\n", PLD.extraPayments);
	  break;
	case 'p':
	  PLD.paymentsPerYear = atoi(optarg);
	  printf("paymentsPerYear is %d\n", PLD.paymentsPerYear);
	  break;
	case 'd':
	  PLD.downpaymentPct = atof(optarg);
	  if (!(PLD.downpaymentPct<1))
	    {//if  is expressed as decimal, then convert to float
	      PLD.downpaymentPct/=100;
	    }
	  printf("downpaymentPct is %f\n", downpaymentPct);
	  down_payment_flag=1; // if we set defaults to 0 then we just need to check for that, but if we set up a default case then it's good to check flags or that it isn't the default value;
	  break;
	case 'h':
	  PLD.houseprice = atoi(optarg);
	  printf("houseprice is %d\n", PLD.houseprice); 
	  house_price_flag=1;
	  break;
	case 'm':
	  PLD.monthlyPayments = atof(optarg);
	  printf("monthlyPayments is %f\n", PLD.monthlyPayments);
	  break;
	  /*case '':
	    = optarg;
	    printf(" is %s\n", );
	    break; */
	case 's':
	  PLD.insurance = atof(optarg);
	  printf("insurance is %f\n",PLD.insurance );
	  break;
	case 't':
	  PLD.taxes  = atof(optarg);
	  printf("taxes is %f\n",PLD.taxes );
	  break;
	case 'r':
	  PLD.rent_payment = atoi(optarg);
	  printf("rent amount is %d\n", PLD.rent_payment); 
	  break;
	case 'f':
	  PLD.rent_inflation = atof(optarg);
	  if (!(PLD.rent_inflation<1))
	    {//if rent_inflation is expressed as decimal, then convert to float
	      PLD.rent_inflation/=100;
	    }
	  printf("rent inflation is %f\n", PLD.rent_inflation); 
	  break;
	case 'o':
	  PLD.house_appreciation = atof(optarg);
	  if (!(PLD.house_appreciation<1))
	    {//if rent_inflation is expressed as decimal, then convert to float
	      PLD.house_appreciation/=100;
	    }
	  printf("house appreciation is %f\n", PLD.house_appreciation); 
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

	//	std::cout<<"pld.insurance in main:"<<PLD.insurance<<std::endl;
  LoanComparison LC(PLD);//interest_rate,numberOfPayments,loanAmount,paymentsPerYear,extraPayments,monthlyPayments,taxes,insurance,rent_payment,rent_inflation);
  //else
  // LoanComparison LC(interest_rate,numberOfPayments,loanAmount,paymentsPerYear,extraPayments,0);

  LC.PrintLoanDetails();
  if (show_table_flag)
    LC.PrintLoanAmortizationTableComparison();
  LC.PrintLoanAmortizationComparison();


  //the super class would just have two AmortizedLoan objects as members and then the super class would handle the comparison



}


//Create a function to calculate how much extra per month you would need to pay to pay off loan in X months instead of on normal schedule.
//This is just the difference between the normal mortgage payment for X periods vs Y periods.
//E.g. To pay off 30 yr in 15 yrs pay the 15 yr mortgage payment for your 30 yr mortgage. 

//write a bash version of this and see how much slower/faster it runs.
//write a java version of this and see how much faster it runs.
//write a C++ version of this and see how much faster it runs.
//write a C version of this and see how much faster it runs.
