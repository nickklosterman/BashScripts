#!/bin/python
import math
#PercentDownPayment=[10,20,25,30,40,45]
#PercentAnnualizedPropertyAppreciation=[0,1,1.5,2,2.5,3] use range
MortgageDurationInYears=[15,20,30]
#PercentAnnualizedReturnOnCapital=0 we calc this
for Mortgage in MortgageDurationInYears:
    for PercentDownPayment in range(5,25,5):
        print "Mortgage,DownPayment,PropertyAppreciation,AnnualizedReturn,PctDownPayment"
        for PercentAnnualizedPropertyAppreciation in range(0,6,1):
            bob=100/float(PercentDownPayment)
            PercentAnnualizedReturnOnCapital=pow((100/float(PercentDownPayment))*pow((1+(float(PercentAnnualizedPropertyAppreciation)/10)),float(Mortgage)),(1/float(Mortgage)))
            print "A",Mortgage,"yr mortgage with",PercentDownPayment,"% down and an annual property appreciation rate of",PercentAnnualizedPropertyAppreciation,"% will give a ",(PercentAnnualizedReturnOnCapital-1)*100,"% annual return on your capital"# (PercentDownPayment/100.0)
#            print Mortgage,PercentDownPayment,"%",PercentAnnualizedPropertyAppreciation,(PercentAnnualizedReturnOnCapital-1)*100,(PercentDownPayment/100.0)


