//I was failing to trigger the function bc the ng-click was outside of the controller scope in the html
// I also was trying to iterate over years which is a dom object insted of iterating over its value/the # of payments.

function AmortizationTable($scope){
  //var Amortizationtable= [];
  $scope.amortizationTable = [{payPeriod:0, principalRemaining:0, paymentTowardsPrincipal:0, paymentTowardsInterest:0, totalInterestPaid:0, equity:0 }];//computeAmortizationTable();

  $scope.stuff= function() {
    console.log("stuff");
  }
  $scope.computeAmortizationTable = function(){
    var amount = document.getElementById("amount");
    var apr = document.getElementById("apr");
    var years = document.getElementById("years");
    var principal = parseFloat(amount.value);
    var interest = parseFloat(apr.value) / 100 / 12;
    var payments = parseFloat(years.value) * 12;
    var yearlyTaxes =  document.getElementById("taxes");
    console.log(principal, interest,payments);

    //	calculate();
    var table=[];
    var tableItem={};

    var x = Math.pow(1 + interest, payments);   
    var monthly = (principal*x*interest)/(x-1);

    var equity = 0;
    var bal = principal;

    var thisMonthsInterest = bal*interest;

    var totalInterestPaid = 0;
    var currentDate = new Date();
    for (var idx = 1 ; idx <= payments; idx++) {
      var thisMonthsInterest = (principal-equity)*interest;
      equity += (monthly - thisMonthsInterest);  // The rest goes to equity
      bal -= (monthly - thisMonthsInterest);     // The rest goes to equity
      //	    computeTaxIncrease(idx,parseFloat(yearlyTaxes.value));
      totalInterestPaid+=thisMonthsInterest;//.toFixed(2); <-- doing it this way treats it as a string. 
      tableItem.payPeriod=idx; //get current year and month and perform date math adding a month at a time? and reformat ?
      tableItem.payPeriod=payPeriodDate(idx,currentDate);
      tableItem.principalRemaining=bal.toFixed(2);
      tableItem.paymentTowardsPrincipal=(monthly-thisMonthsInterest).toFixed(2);
      tableItem.paymentTowardsInterest=thisMonthsInterest.toFixed(2);
      tableItem.totalInterestPaid=totalInterestPaid.toFixed(2);
      tableItem.equity=equity.toFixed(2);
      tableItem.monthlyTax=computeTaxIncrease(idx,parseFloat(yearlyTaxes.value));
      //console.log(tableItem);
      table.push(tableItem);
      tableItem = {}; //clear out for next iteration
    }
    //return table;
    $scope.amortizationTable = table;
  }
}

"use strict"; // Use ECMAScript 5 strict mode in browsers that support it


// Save the user's input as properties of the localStorage object. Those
// properties will still be there when the user visits in the future
// This storage feature will not work in some browsers (Firefox, e.g.) if you 
// run the example from a local file:// URL.  It does work over HTTP, however.
function save(amount, apr, years, yearlyTaxes) {
  if (window.localStorage) {  // Only do this if the browser supports it
    /*        localStorage.loan_amount = amount;
              localStorage.loan_apr = apr;
              localStorage.loan_years = years;
              localStorage.loan_taxes = yearlyTaxes;*/
  }
}

// Automatically attempt to restore input fields when the document first loads.
window.onload = function() {
  // If the browser supports localStorage and we have some stored data
  if (window.localStorage && localStorage.loan_amount) {  
    /*        document.getElementById("amount").value = localStorage.loan_amount;
              document.getElementById("apr").value = localStorage.loan_apr;
              document.getElementById("years").value = localStorage.loan_years;
              document.getElementById("taxes").value = localStorage.loan_taxes;*/
  }
};


//----------------------

function computation(){
//   http://stackoverflow.com/questions/7615214/in-javascript-why-is-0-equal-to-false-but-when-tested-by-if-it-is-not-fals
  var principal = parseFloat(document.getElementById("principal").value) || 1000,
      stockPercentOfPrincipal = parseFloat(document.getElementById("stockPercentOfPrincipal").value)/100.0 ,//|| 00,
      bondPercentOfPrincipal = parseFloat(document.getElementById("bondPercentOfPrincipal").value)/100.0 ,//|| 100,
      averageStockReturnPercent = parseFloat(document.getElementById("averageStockReturnPercent").value)/100.0,// || 10,
      averageBondReturnPercent = parseFloat(document.getElementById("averageBondReturnPercent").value)/100.0,// || 5,
      investmentTimelineInYears = parseFloat(document.getElementById("investmentTimelineInYears").value) || 10,
      stockMarketDipYear = parseFloat(document.getElementById("stockMarketDipYear").value) || -10,
      stockMarketDipPercentage = parseFloat(document.getElementById("stockMarketDipPercentage").value)/100.0 || 0,
      yearlyExpenses = parseFloat(document.getElementById("yearlyExpenses").value),// || 0,
      yearlyExpensesAppreciationRate = parseFloat(document.getElementById("yearlyExpensesAppreciationRate").value)/100.0 || 0,
      yearlyExpensePercentFromStockPortfolio = parseFloat(document.getElementById("yearlyExpensePercentFromStockPortfolio").value)/100.0 || 0,
      yearlyExpensePercentFromBondPortfolio = parseFloat(document.getElementById("yearlyExpensePercentFromBondPortfolio").value)/100.0 || 0,
      yearlyBenefit = parseFloat(document.getElementById("yearlyBenefit").value) || 0,
      yearlyBenefitCOLA = parseFloat(document.getElementById("yearlyBenefitCOLA").value)/100.0 || 0,
      fake = document.getElementById("fake"),
      loopCounter=0,
      investmentObj={stockPrincipalDepleted:false,bondPrincipalDepleted:false,accountDepleted:false},
      domStockPortfolio = document.getElementById("stockPortfolio"),
      domBondPortfolio = document.getElementById("bondPortfolio"),
      domTotalPortfolio = document.getElementById("totalPortfolio"),
      domWarning = document.getElementById("Warning");

  //arrgg, I really need to validate all of the entries and perform the percentage splits correctly. 
  if (typeof stockPercentOfPrincipal === 'undefined') {
    stockPercentOfPrincipal = 1;
  }
  if (typeof bondPercentOfPrincipal === 'undefined') {
    bondPercentOfPrincipal = 0;
  }
  if (typeof yearlyExpenses === 'undefined') {
    yearlyExpenses = 0;
  }

  // for debug start off with the most basic cases, all but one main calculation set to 0;

  if ( stockPercentOfPrincipal + bondPercentOfPrincipal !== 1 ){
    bondPercentOfPrincipal = 1 - stockPercentOfPrincipal;
  }

  if ( yearlyExpensePercentFromStockPortfolio + yearlyExpensePercentFromBondPortfolio !== 1 ){
    yearlyExpensePercentFromBondPortfolio = 1 - yearlyExpensePercentFromStockPortfolio;
  }


  investmentObj.principal = principal;
  investmentObj.stockPrincipal = principal*/*investmentObj.*/stockPercentOfPrincipal;
  investmentObj.bondPrincipal = principal-investmentObj.stockPrincipal;

  investmentObj.yearlyExpenses = yearlyExpenses ;
  investmentObj.yearlyExpensePercentFromStockPortfolio = yearlyExpensePercentFromStockPortfolio;
  investmentObj.yearlyExpensePercentFromBondPortfolio = yearlyExpensePercentFromBondPortfolio;

  for (loopCounter = 0; loopCounter < investmentTimelineInYears; loopCounter++) {
    if (loopCounter === stockMarketDipYear) {
      console.log("dip");
      investmentObj.stockPrincipal = investmentObj.stockPrincipal * (1 - stockMarketDipPercentage);
    }

    //we are taking out the expenses at the beginning of the loop instead of at the end. I suppose this makes sense.
    //I need to throw an error if the principal is 0 since you can no longer withdrawal from that source at that point. 
    //check if the yearlyExpenses is greater than the {stock|bond}principal and if so then switch the percent to 100% the other investment and subtract the principal needed from that other investment
    if (( investmentObj.yearlyExpenses - yearlyBenefit)*investmentObj.yearlyExpensePercentFromStockPortfolio > investmentObj.stockPrincipal
      || ( investmentObj.yearlyExpenses - yearlyBenefit)*investmentObj.yearlyExpensePercentFromBondPortfolio > investmentObj.bondPrincipal ) {

      if ( ( investmentObj.yearlyExpenses - yearlyBenefit)*investmentObj.yearlyExpensePercentFromStockPortfolio > investmentObj.stockPrincipal ) {
        investmentObj.stockPrincipal = 0;
        investmentObj.stockPrincipalDepleted = true;
      }
      if ( ( investmentObj.yearlyExpenses - yearlyBenefit)*investmentObj.yearlyExpensePercentFromBondPortfolio > investmentObj.bondPrincipal ) {
        investmentObj.bondPrincipal = 0;
        investmentObj.bondPrincipalDepleted = true;
      }

      //      if (( investmentObj.yearlyExpenses - yearlyBenefit)*investmentObj.yearlyExpensePercentFromStockPortfolio > investmentObj.stockPrincipal && ( investmentObj.yearlyExpenses - yearlyBenefit)*investmentObj.yearlyExpensePercentFromBondPortfolio > investmentObj.bondPrincipal ) {
      if ( investmentObj.bondPrincipalDepleted && investmentObj.stockPrincipalDepleted ) {
        console.log("You chose poorly. You really don't have enough money to retire given the circumstances. Your money runs out in year "+loopCounter+".");
investmentObj.accountDepleted = true;
    investmentObj.total = 0;
        break;
      }
    }
    
    if (!investmentObj.stockPrincipalDepleted){ 
      var temp = (investmentObj.stockPrincipal - ( investmentObj.yearlyExpenses - yearlyBenefit)*investmentObj.yearlyExpensePercentFromStockPortfolio)*(1+averageStockReturnPercent);
      investmentObj.stockPrincipal = temp > 0 ? temp : 0;
    }
    if(!investmentObj.bondPrincipalDepleted){
      temp =(investmentObj.bondPrincipal - ( investmentObj.yearlyExpenses - yearlyBenefit) *investmentObj.yearlyExpensePercentFromBondPortfolio)*(1+averageBondReturnPercent);
      investmentObj.bondPrincipal = temp > 0 ? temp : 0;
    }
    
    investmentObj.total = investmentObj.stockPrincipal + investmentObj.bondPrincipal;
    //set the percentage here otherwise if it is above, we screw up the calculation; e.g. if stockprincipal is depleted then we'd flip all expenses to bonds and that would then fail as if it was depleted when it really wasn't
    if (investmentObj.stockPrincipalDepleted) {
      investmentObj.yearlyExpensePercentFromStockPortfolio = 0;
      investmentObj.yearlyExpensePercentFromBondPortfolio = 1;
    }
    if (investmentObj.bondPrincipalDepleted) {
      investmentObj.yearlyExpensePercentFromStockPortfolio = 1;
      investmentObj.yearlyExpensePercentFromBondPortfolio = 0;
    }

    console.log("--");
    console.log("lC:"+loopCounter);
    console.log("iO.yE:"+investmentObj.yearlyExpenses);
    console.log("iO.sP:"+investmentObj.stockPrincipal);
    console.log("iO.bP:"+investmentObj.bondPrincipal);
    console.log("iO.t:"+investmentObj.total);

    // up the expenses for next year; COLA
    // or should I do these at the beginning of each loop and just not apply for year 0?
    investmentObj.yearlyExpenses = investmentObj.yearlyExpenses * (1+yearlyExpensesAppreciationRate);
    yearlyBenefit = yearlyBenefit * (1+yearlyBenefitCOLA); //to test the yearly benefit have the yearly benefit cancel out the yearly expenses with the cola canceling the appreciation rate, this should match a test run without any expenses or benefits.
    // array.push(investmentObj) plot or display using angular

  }
  domStockPortfolio.innerHTML = numberWithCommas(investmentObj.stockPrincipal.toFixed(2));
  domBondPortfolio.innerHTML = numberWithCommas(investmentObj.bondPrincipal.toFixed(2));
  domTotalPortfolio.innerHTML = numberWithCommas(investmentObj.total.toFixed(2));
  if (investmentObj.accountDepleted) {
    domWarning.style.visibility="visible";
domWarning.innerHTML="You ran out of money in year "+loopCounter+" of retirement. :(";
  } else {
   domWarning.style.visibility="hidden";
  }
  console.log("lC:"+loopCounter);
}

//http://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript
function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
/**  TODO
 * introduce some way to have a random / jitter market return. But have it statistically in line with the historical mean / std dev. 
 * add in SS benefits and or any other fixed income (not security related) that can help offset costs.
 * create a calculator that given basic inputs determines if you will be able to retire or if you will run out of money; Is there a formula or is the only solution to do it iteratively
 */