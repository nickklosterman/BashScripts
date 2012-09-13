/*
TODO: allow reading of a matrix/list of extra payments from a file that correspond to months when applied. ie. 3rd line = apply extra payment to 3rd month

http://www.java2s.com/Tutorial/Java/0120__Development/SpecifyingtheWidthandPrecision.htm 
*/

//import java.math;



public class LoanCalculator
{

private  double int_rate_pct,principal,loan_amount,additionalperiodicpaymenttoprincipal,periodicmortgagepayment,totalcostofloan,totalinterestonloan;
private  int num_pmnts,freq,monthstopayoffloan;


public int get_monthstopayoffloan()
{return monthstopayoffloan;}

public double get_totalinterestonloan()
{
  return totalinterestonloan;
}

public void PrintLoanDetails()
{
  System.out.printf("Using %.2f %% interest rate for %d months on $ %.2f loan with payments due XXXX and additional XXX payments of $ %.2f\n", int_rate_pct*100,num_pmnts,loan_amount,additionalperiodicpaymenttoprincipal);
}

public void reset_principal()
{
  principal=loan_amount;
}
public double get_overpaymenttoprincipal()
{
  return additionalperiodicpaymenttoprincipal;
}
/*
public String GetPeriodString()
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

public void PrintPeriodicMortgagePayment()
{
  System.out.printf("Your mortgage payment will be %0.2f.\n" , periodicmortgagepayment);
}

public void AmortizationTable()
{
  System.out.printf("month interest principal principalleft(doesn't include add'l payments) \n");
  int month=0;
  double totalprincipal=0, totalinterest=0;
    while (principal > 0.000001) //the floating point must put the result off by just enough that the error accumulates over all the iterations.
  //  for (int i=0;i<num_pmnts;i++) ///this fails when you make add'l payments towards principal
    {
      calc_newprincipal();
      month++;
      //      System.out.printf("%d %0.2f %0.2f %0.2f\n" , month,paymenttowardsinterest,paymenttowardsprincipal,principal);
      //      System.out.printf("%d %f %f %f\n" , month,paymenttowardsinterest,paymenttowardsprincipal,principal);
      System.out.printf("%d %.2f %.2f %.2f %.2f\n" , month,calc_paymenttowardsinterest(),calc_paymenttowardsprincipal(),principal,AmountOwedAfterXMonths(month)); // using 0.2f causes a MissingFormatWidthException
      totalprincipal+=calc_paymenttowardsprincipal();
      totalinterest+=calc_paymenttowardsinterest();
    }
  //      System.out.printf("total int %0.2f , total princ %0.2f \n" , totalinterest,totalprincipal);
      System.out.printf("total int %.2f , total princ %.2f \n" , totalinterest,totalprincipal);
}

public void PrintCurrentIteration()
{
  System.out.printf("%0.2f\t%0.2f\t%0.2f\t", calc_paymenttowardsinterest(),calc_paymenttowardsprincipal(),get_principal());
}

public void IteratePayment()
{
  calc_newprincipal();
}

public void AmortizationAmounts()
{
   reset_principal();
  double totalinterest=0;
  //while (principal > 0.000001) //the floating point must put the result off by just enough that the error accumulates over all the iterations.
  for (int i=0;i<num_pmnts;i++)
    {
      totalinterest+=calc_paymenttowardsinterest();
      calc_newprincipal();
      if (principal<=0.001)
	{	
	  monthstopayoffloan=i; 
	  i+=num_pmnts; //to break out of loop
	}
    }
   totalinterestonloan=totalinterest;
}

public LoanCalculator(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment)
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
public void set_LoanCalculator(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment)
{
  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = moneyround(additionalperiodicpaymenttoprincipal_);
  num_pmnts =   num_pmnts_;
  freq = freq_;
  calc_periodicmortgagepayment();

  //override items if monthlypayment specified
  if (monthlypayment>periodicmortgagepayment)
    additionalperiodicpaymenttoprincipal =monthlypayment-periodicmortgagepayment;

}


public LoanCalculator(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_)
{
  principal =  loan_amount_;
  int_rate_pct =  int_rate_ / 100;
  loan_amount = loan_amount_ ;
  additionalperiodicpaymenttoprincipal = moneyround(additionalperiodicpaymenttoprincipal_);
  num_pmnts =   num_pmnts_;
  freq = freq_;
  calc_periodicmortgagepayment();

}

public LoanCalculator()
{
  principal = int_rate_pct = loan_amount = additionalperiodicpaymenttoprincipal = periodicmortgagepayment = 0;
  num_pmnts = freq = 0;
}
public double get_periodicmortgagepayment()
{
  return periodicmortgagepayment;
}
public double get_principal()
{
  return principal;
}
public double  get_loan_amount()
{
  return loan_amount;
}

public void set_principal(double p)
{
  principal=p;
  loan_amount=p;
}

public void calc_periodicmortgagepayment() //double int_rate, int num_pmnts, double principal, int freq)
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
  double x = Math.pow((1.0 + rr), num_pmnts);
  double y = rr / (x - 1.0);
  double pmnt_amt = (rr + y) * principal;

    periodicmortgagepayment=moneyround(pmnt_amt);

}

public double moneyround(double amt)
{
  return Math.floor(amt*100 +0.5) / 100;
}
public double calc_paymenttowardsinterest()
{
  return moneyround(principal* int_rate_pct / freq );
}

public double calc_paymenttowardsprincipal()
{
  double paymenttowardsprincipal=0;

    {
      if (periodicmortgagepayment+additionalperiodicpaymenttoprincipal < principal)
	{
	 
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
public double calc_paymentpercentages()
{
  double paymenttowardsprincipal=0;

    {
      if (periodicmortgagepayment+additionalperiodicpaymenttoprincipal < principal)
	{
	
	  paymenttowardsprincipal=(periodicmortgagepayment-calc_paymenttowardsinterest());
	}
      else
	{
	
	paymenttowardsprincipal=(principal-calc_paymenttowardsinterest());
	}
    }
  return paymenttowardsprincipal;
}

public void calc_newprincipal()
{
  double temp=0;
  if (periodicmortgagepayment+additionalperiodicpaymenttoprincipal < principal)
    {
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
 
}

//http://en.wikipedia.org/wiki/Mortgage_calculator#Monthly_payment_formula
public double AmountOwedAfterXMonths(int mon)
{//calculate the amount left on the loan after paying in X months worth of payments
  double oneplusrton = Math.pow(1+int_rate_pct/12,mon);
  //This number will be off slightly due to it not having previous payments rounded off
    return moneyround(loan_amount*oneplusrton-periodicmortgagepayment*(oneplusrton-1)*12/int_rate_pct);

}

public void CalcAmortizationValues() //double periodicpayment,double int_rate, double principal,int freq, additionalperiodicpaymenttoprincipal)
{

  if (periodicmortgagepayment<principal)       //if aren't paying extra then you'll hit 0 principal on your final payment, but if pay extra last payment will be less than what your normal payment would've been.
    {
      calc_newprincipal();
    }
  else //this case covers our last payment where the principal is less than the payment, 
    {
      principal=0;
    }

}
 
public void AmortizationTable2()//periodicpayment,int_rate,principal,freq,additionalperiodicpaymenttoprincipal):
{
  System.out.println("months_to_pay_off total_interest_paid\n");
  int month=0;
  double totalinterest=0;
  int amountremaining=-99;
    while (amountremaining!=0)//principal > 0)
    {
	totalinterest+=calc_paymenttowardsinterest();
	calc_newprincipal();
	month++;
	amountremaining=(int)(principal);
    }
  System.out.printf("%d %2.f\n" ,month,totalinterest);
}
}

    /*/-------------------------------------------------------------------------------------

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
  //  LoanCalculator NormalLoan(),ExtraPaymentLoan();
  LoanCalculator NormalLoan,ExtraPaymentLoan;
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
  //void set_LoanCalculator(  double int_rate_, double loan_amount_, double additionalperiodicpaymenttoprincipal_,   int num_pmnts_, int freq_, double monthlypayment)
  NormalLoan.set_LoanCalculator(rate,amount,0,terminmonths,paymentsperyear,monthlypayment);
  ExtraPaymentLoan.set_LoanCalculator(rate,amount,extrapayment,terminmonths,paymentsperyear,monthlypayment);
}
//-------------------------------------------------------------------------------------* /

public class LoanCalculatorDriver{

public void usage()
{
    System.out.println("Please define the interest rate (i), loan amount (l), number of payments (n), and payments per year (p).\nAdditionally, you can specify extra payment amount to apply toward principal each pay period (e) or a monthly payment amount that includes the base payment plus any overage towards principal(m).\n./a.out -i 4.5 -l 120000 -p 12 -n 360 -e 30\n");
}


    
public int main(int argc, String argv[])
{

  
  int c;
  //  char *filename;

  //extern char *optarg;
  //  extern 
int optind, optopt, opterr;

  //setup defaults
  double interest_rate=4.5;
  int numberOfPayments=4;//36;
  double loanAmount=100000.0;
  double extraPayments=1000;//240.0;
  int paymentsPerYear = 12;//"monthly"
  float monthlyPayments =0.0;
  /*
  if (argc > 3 )
    {
  interest_rate = loanAmount = extraPayments = monthlyPayments = 0.0;
  numberOfPayments = paymentsPerYear = 0;
    while ((c = getopt(argc, argv, ":i:n:l:e:p:m:")) != -1) {
      switch(c) {
      case 'i':
	interest_rate = atof(optarg);
        System.out.printf("interest_rate is %f\n", interest_rate);
        break;
  case 'n':
    numberOfPayments = atoi(optarg);
        System.out.printf("numberOfPayments is %d\n", numberOfPayments);
        break;
  case 'l':
    loanAmount= atof(optarg);
    System.out.printf("loanAmount is %f\n", loanAmount);
        break;
  case 'e':
    extraPayments = atof(optarg);
    System.out.printf("extraPayments is %f\n", extraPayments);
        break;
  case 'p':
    paymentsPerYear = atoi(optarg);
        System.out.printf("paymentsPerYear is %d\n", paymentsPerYear);
        break;
  case 'm':
    monthlyPayments = atof(optarg);
        System.out.printf("monthlyPayments is %f\n", monthlyPayments);
        break;
	
      case ':':
        System.out.printf("-%c without filename\n", optopt);
        break;
      case '?':
        System.out.printf("unknown arg %c\n", optopt);
        break;
      }
    }
    }
  else {
    usage();
  }
  * /
    
  LoanComparison LC(interest_rate,numberOfPayments,loanAmount,paymentsPerYear,extraPayments,monthlyPayments);
  
  LC.PrintLoanDetails();
  LC.PrintLoanAmortizationTableComparison();



}
}

//Create a function to calculate how much extra per month you would need to pay to pay off loan in X months instead of on normal schedule.
//This is just the difference between the normal mortgage payment for X periods vs Y periods.
//E.g. To pay off 30 yr in 15 yrs pay the 15 yr mortgage payment for your 30 yr mortgage. 

//write a bash version of this and see how much slower/faster it runs.
//write a java version of this and see how much faster it runs.
//write a C++ version of this and see how much faster it runs.
//write a C version of this and see how much faster it runs.
*/