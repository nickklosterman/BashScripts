/*
  TODO: allow reading of a matrix/list of extra payments from a file that correspond to months when applied. ie. 3rd line = apply extra payment to 3rd month
*/

public class LoanCalculatorDriver
{

    public void usage()
    {
	System.out.println("Please define the interest rate (i), loan amount (l), number of payments (n), and payments per year (p).\nAdditionally, you can specify extra payment amount to apply toward principal each pay period (e) or a monthly payment amount that includes the base payment plus any overage towards principal(m).\n./a.out -i 4.5 -l 120000 -p 12 -n 360 -e 30\n");
    }

    private static LoanCalculator LC;
    
    public static void  main(String argv[])
    {
	int c;
	int optind, optopt, opterr;

	//setup defaults
	double interest_rate=4.5;
	int numberOfPayments=4;//36;
	double loanAmount=100000.0;
	double extraPayments=1000;//240.0;
	int paymentsPerYear = 12;//"monthly"
	double monthlyPayments =0.0;

	System.out.println(argv.length);
	System.out.printf("The number of command line arguments is %d.",argv.length);
	if (argv.length==6)
	    {
		for (int i=0;i<argv.length;i++)
		    {
			System.out.println(argv[i]);
		    }
		interest_rate=Double.parseDouble(argv[0]);
		numberOfPayments=Integer.parseInt(argv[1]);
		loanAmount=Double.parseDouble(argv[2]);
		extraPayments=Double.parseDouble(argv[3]);
		paymentsPerYear=Integer.parseInt(argv[4]);
		monthlyPayments=Double.parseDouble(argv[5]);

	    }
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
	*/
    
	//why does this constructor not work??
	//LC = new LoanCalculator(interest_rate,numberOfPayments,loanAmount,paymentsPerYear,extraPayments,monthlyPayments);
	LC = new LoanCalculator();
	LC.set_LoanCalculator(interest_rate,loanAmount,extraPayments,numberOfPayments,paymentsPerYear,monthlyPayments);  
	LC.AmortizationTable();
	LC.PrintLoanDetails();
	//  LC.PrintLoanAmortizationTableComparison();
    }
}

//Create a function to calculate how much extra per month you would need to pay to pay off loan in X months instead of on normal schedule.
//This is just the difference between the normal mortgage payment for X periods vs Y periods.
//E.g. To pay off 30 yr in 15 yrs pay the 15 yr mortgage payment for your 30 yr mortgage. 

//write a bash version of this and see how much slower/faster it runs.
//write a java version of this and see how much faster it runs.
//write a C++ version of this and see how much faster it runs.
//write a C version of this and see how much faster it runs.
