#http://www.daniweb.com/software-development/python/threads/228317/loan-calculator
def calc_payment(int_rate, num_pmnts, principal, freq):
    ''' This function will calculate the payment amount of a loan.
    @ Inputs
    - int_rate - The interest rate of the loan
    - num_pmnts - The number of payments required
    - principal - The original amount of the loan (minus down-payment)
    - freq - Frequency of payments (weekly, monthly, quarterly, annually)
    @ Returns
    - pmnt_amt - The amount that each payment will be
    '''
    freq_lookup = {'weekly':52, 'biweekly': 26,'monthly':12, 'quarterly':4, 'annually':1}
    int_rate = float(int_rate) / 100
    rr = int_rate / freq_lookup[freq]
    x = (1.0 + rr) ** num_pmnts
    y = rr / (x - 1.0)
    pmnt_amt = (rr + y) * principal
    return pmnt_amt

def calc_paymenttowardsinterest(int_rate,principal,freq):
    freq_lookup = {'weekly':52, 'biweekly': 26,'monthly':12, 'quarterly':4, 'annually':1}
    int_rate = float(int_rate) / 100
    rr = int_rate / freq_lookup[freq]
    return rr*principal

def calc_paymenttowardsprincipal(periodicpayment,paymenttowardsinterest,principal):
    if principal>0:
        return periodicpayment-paymenttowardsinterest
    else:
        return 0

def calc_newprincipal(principal,paymenttowardsprincipal,additionalperiodicpaymenttoprincipal):
    return principal-paymenttowardsprincipal-additionalperiodicpaymenttoprincipal

def PrintDual(i,pi1,pp1,p1,pi2,pp2,p2):
    pi1mpi2=0
    p1mp2=0
    pp2mpp1=0 #the payment to principal will be greater on the scenario where add'l payments are made.
    if pi1-pi2>0:
        pi1mpi2=pi1-pi2

    if p1-p2>0 and p2!=0:
        p1mp2=p1-p2
        
    print("%3d | %10.2f  %10.2f %10.2f | %10.2f %10.2f %10.2f | %10.2f %10.2f " % (i,pi1,pp1,p1,pi2,pp2,p2,pi1mpi2,p1mp2))
""" this is redundant as the diff in the amount paid ot interest and the diff in amount paid to principal are equal! DUh. That which isn't being paid to principal is being paid to the principal...derrrrr
    if pp2-pp1>0:
        pp2mpp1=pp2-pp1
   """     
#    print("%d | %10.2f  %10.2f %10.2f | %10.2f %10.2f %10.2f | %10.2f %10.2f %10.2f " % (i,pi1,pp1,p1,pi2,pp2,p2,pi1mpi2,pp2mpp1,p1mp2))


def DualAmortizationTable(periodicpayment,int_rate,principal,freq,additionalperiodicpaymenttoprincipal,num_pmnts):
    import locale
    locale.setlocale(locale.LC_ALL,'')
    p1=principal
    p2=principal
    i=1
    totint1=0
    totint2=0
    flag=0 #flag to prevent rewriting of month when p2 was paid off
    print("#pmnt IntPmnt1 PrinPmnt1 Prin1 IntPmnt2 PrinPmnt2 Prin2 DiffIntPmnt DiffPrin")
    while i <=  num_pmnts:
        pi1,pp1,p1=CalcAmortizationValues(periodicpayment,int_rate,p1,freq,0)
        pi2,pp2,p2=CalcAmortizationValues(periodicpayment,int_rate,p2,freq,additionalperiodicpaymenttoprincipal)
#        print("%d %.2f  %.2f %.2f | %.2f %.2f %.2f | %.2f %.2f %.2f " % (i,pi1,pp1,p1,pi2,pp2,p2,pi1-pi2,pp2-pp1,p1-p2)) #comes out wobbly since just state to print two decimals
        totint1+=pi1
        totint2+=pi2
    #    print("%d | %10.2f  %10.2f %10.2f | %10.2f %10.2f %10.2f | %10.2f %10.2f %10.2f " % (i,pi1,pp1,p1,pi2,pp2,p2,pi1-pi2,pp2-pp1,p1-p2))

        PrintDual(i,pi1,pp1,p1,pi2,pp2,p2)

        if p2==0 and flag==0:
            monthstopayoffwithaddlpayments=i
            flag=1
        i+=1
#    print("Total interest paid wo add'l payments:$%.2f, with add'l payments $%.2f, difference $%.2f" % (locale.currency(totint1,grouping=True),locale.currency(totint2,grouping=True),totint1-totint2))
        #using locale.currency turns the output into a string and prepends the appropriate currency symbol to the front as well as only displaying two decimal places
    print("Total interest paid wo add'l payments:%s, with add'l payments %s, a difference of %s" % (locale.currency(totint1,grouping=True),locale.currency(totint2,grouping=True),locale.currency(totint1-totint2,grouping=True)))
    print("The additional payments cut off %d months of the loan." % (num_pmnts-monthstopayoffwithaddlpayments))

def CalcAmortizationValues(periodicpayment,int_rate,principal,freq,additionalperiodicpaymenttoprincipal):
    paymenttowardsinterest=calc_paymenttowardsinterest(int_rate,principal,freq)
    if periodicpayment<principal:       #if aren't paying extra then you'll hit 0 principal on your final payment, but if pay extra last payment will be less than what your normal payment would've been.
        paymenttowardsprincipal=calc_paymenttowardsprincipal(periodicpayment,paymenttowardsinterest,principal)
        principal=calc_newprincipal(principal,paymenttowardsprincipal,additionalperiodicpaymenttoprincipal)
    else: #this case covers our last payment where the principal is less than the payment, don't need to make 
        paymenttowardsprincipal=calc_paymenttowardsprincipal(principal,paymenttowardsinterest,principal) 
        principal=0

    return paymenttowardsinterest,paymenttowardsprincipal,principal

def AmortizationTable(periodicpayment,int_rate,principal,freq):
    print("month interest principal principalleft")
    month=0
    while principal > 0:
        paymenttowardsinterest=calc_paymenttowardsinterest(int_rate,principal,freq)
        paymenttowardsprincipal=calc_paymenttowardsprincipal(periodicpayment,paymenttowardsinterest)
        principal=calc_newprincipal(principal,paymenttowardsprincipal,0)
        month+=1
        print("%d %2.f %2.f %2.f" % (month,paymenttowardsinterest,paymenttowardsprincipal,principal))

def AmortizationTable2(periodicpayment,int_rate,principal,freq,additionalperiodicpaymenttoprincipal):
    print("months_to_pay_off total_interest_paid")# principal principalleft")
    month=0
    totalinterest=0
    while principal > 0:
        paymenttowardsinterest=calc_paymenttowardsinterest(int_rate,principal,freq)
        totalinterest+=paymenttowardsinterest
        paymenttowardsprincipal=calc_paymenttowardsprincipal(periodicpayment,paymenttowardsinterest,principal)
        principal=calc_newprincipal(principal,paymenttowardsprincipal,additionalperiodicpaymenttoprincipal)
        month+=1
    print("%d %2.f" % (month,totalinterest))


    
def main():
    one=1
    """ 
    r = input('What is your interest rate? ')
    t = input('How many payments will you make? ')
    la = input('What was the amount of the loan? ')
    ep = input('Extra amount per payment period towards principal? ')
    """
#setup defaults
    r=4.5
    t=360
    la=100000.0
    ep=60.0
    rt = "monthly"


#base the extra payment on how much you could afford to pay per month
    MonthlyPayment=0.0
    #MonthlyPayment=1.5*payment #making a payment of ~150% of the regular mortgage payment will pay off the mortgage in about 1/2 the time.
    

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
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        #usage()
        sys.exit(2)

    for opt, arg in options:
        if opt in ('-i', '--interest_rate'):
            r = float(arg)
        elif opt in ('-n', '--number_of_payments'):
            t = int(arg)
        elif opt in ('-l', '--loan_amount'):
            la = float(arg)
        elif opt in ('-e', '--extra_principal_payment_amount'):
            ep = float(arg)
        elif opt in ('-f', '--payment_frequency'):
            rt = arg
        elif opt in ('-m', '--monthly_payment_amount'):
            MonthlyPayment = float(arg)
        elif opt == '--version':
            version = arg

#    rt = None
    while rt not in ['weekly', 'biweekly', 'monthly', 'quarterly', 'annually']:
        if rt:
            rt = raw_input('Sorry that was not an option, please respond with weekly, monthly, quarterly, or annually: ').lower()
        else:
            rt = raw_input('Do you make your payments weekly, biweekly, monthly, quarterly, or annually? ').lower()
    payment = calc_payment(r, t, la, rt)
    if MonthlyPayment>payment and MonthlyPayment!=0:
        ep=MonthlyPayment-payment


    print("Using %.2f %% interest rate for %d months on $ %.2f loan with payments due %s and additional %s payments of $ %.2f" % (r,t,la,rt,rt,ep))


    DualAmortizationTable(payment,r,la,rt,ep,t)
#    AmortizationTable2(payment,r,la,rt,0)
#    AmortizationTable2(payment,r,la,rt,ep)

    print 'Your %s payment will be %.2f' % (rt, payment)

if __name__ == '__main__':
    main()
#    raw_input('Press Enter to Exit...')


#Create a function to calculate how much extra per month you would need to pay to pay off loan in X months instead of on normal schedule.
#This is just the difference between the normal mortgage payment for X periods vs Y periods.
#E.g. To pay off 30 yr in 15 yrs pay the 15 yr mortgage payment for your 30 yr mortgage. 

#write a bash version of this and see how much slower/faster it runs.
#write a java version of this and see how much faster it runs.
#write a C++ version of this and see how much faster it runs.
#write a C version of this and see how much faster it runs.

