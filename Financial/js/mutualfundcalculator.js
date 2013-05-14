//I was failing to trigger the function bc the ng-click was outside of the controller scope in teh html
// I also was trying ot iterate over years which is a dom object insted of iterating over its value/the # of payments.

// function AmortizationTable($scope){
//     //var Amortizationtable= [];
//     $scope.amortizationTable = [{payPeriod:0, principalRemaining:0, paymentTowardsPrincipal:0, paymentTowardsInterest:0, totalInterestPaid:0, equity:0 }];//computeAmortizationTable();

//     $scope.stuff= function() {
// 	console.log("stuff");
//     }
//     //computeAmortizationTable:function(){
//     //function computeAmortizationTable(){
//     $scope.computeAmortizationTable = function(){
// 	var amount = document.getElementById("amount");
// 	var apr = document.getElementById("apr");
// 	var years = document.getElementById("years");
// 	var principal = parseFloat(amount.value);
// 	var interest = parseFloat(apr.value) / 100 / 12;
// 	var payments = parseFloat(years.value) * 12;
// 	var yearlyTaxes =  document.getElementById("taxes");
// 	console.log(principal, interest,payments);

// 	//	calculate();
// 	var table=[];
// 	var tableItem={};

// 	var x = Math.pow(1 + interest, payments);   // Math.pow() computes powers
// 	var monthly = (principal*x*interest)/(x-1);

// 	var equity = 0;
// 	var bal = principal;

//         var thisMonthsInterest = bal*interest;

// 	var totalInterestPaid = 0;
// 	var currentDate = new Date();
// 	for (var idx = 1 ; idx <= payments; idx++) {
//             var thisMonthsInterest = (principal-equity)*interest;
//             equity += (monthly - thisMonthsInterest);  // The rest goes to equity
//             bal -= (monthly - thisMonthsInterest);     // The rest goes to equity
// //	    computeTaxIncrease(idx,parseFloat(yearlyTaxes.value));
// 	    totalInterestPaid+=thisMonthsInterest;//.toFixed(2); <-- doing it this way treats it as a string. 
// 	    tableItem.payPeriod=idx; //get current year and month and perform date math adding a month at a time? and reformat ?
// 	    tableItem.payPeriod=payPeriodDate(idx,currentDate);
// 	    tableItem.principalRemaining=bal.toFixed(2);
// 	    tableItem.paymentTowardsPrincipal=(monthly-thisMonthsInterest).toFixed(2);
// 	    tableItem.paymentTowardsInterest=thisMonthsInterest.toFixed(2);
// 	    tableItem.totalInterestPaid=totalInterestPaid.toFixed(2);
// 	    tableItem.equity=equity.toFixed(2);
// 	    tableItem.monthlyTax=computeTaxIncrease(idx,parseFloat(yearlyTaxes.value));
// 	    //console.log(tableItem);
// 	    table.push(tableItem);
// 	    tableItem = {}; //clear out for next iteration
	    
// 	}
// 	//return table;
// 	$scope.amortizationTable = table;
//     }

// }


"use strict"; // Use ECMAScript 5 strict mode in browsers that support it

/*
 * This script defines the calculate() function called by the event handlers
 * in HTML above. The function reads values from <input> elements, calculates
 * loan payment information, displays the results in <span> elements. It also
 * saves the user's data, displays links to lenders, and draws a chart.
 */
function calculate() {
    // Look up the input and output elements in the document
    var initialInvestment = (document.getElementById("initialInvestment"));
    var annualReturn = (document.getElementById("annualReturn"));
    var years = (document.getElementById("years"));
    var expenseRatio = (document.getElementById("expenseRatio"));
    var redemptionFee = (document.getElementById("redemptionFee"));


var value = 0, valueNoFees = 0, totalAppreciation = 0 , totalFeesPaid = 0 ;    
    // Get the user's input from the input elements. Assume it is all valid.
    // Convert interest from a percentage to a decimal

// for ( var cntr = 0 ; cntr < years ; cntr++)
// {
// push
// }


    // Now compute the monthly payment figure.
    value  = (parseFloat(initialInvestment.value)*(1-parseFloat(redemptionFee.value)/100))*Math.pow(1 + parseFloat(annualReturn.value)/100, parseInt(years.value))*Math.pow(1-parseFloat(expenseRatio.value)/100,parseInt(years.value));   // Math.pow() computes powers
    valueNoFees  = (parseFloat(initialInvestment.value)*Math.pow(1 + parseFloat(annualReturn.value)/100, parseInt(years.value)));   // Math.pow() computes powers
console.log(value);

    // If the result is a finite number, the user's input was good and
    // we have meaningful results to display
    if (isFinite(value)) {
	console.log("finite");
        // Fill in the output fields, rounding to 2 decimal places
        valueOutput.innerHTML = value.toFixed(2);
valueNoFeesOutput.innerHTML = valueNoFees.toFixed(2);
        totalAppreciationOutput.innerHTML = (value-parseFloat(initialInvestment.value)).toFixed(2);
	var temp = valueNoFees-value;
	totalFeesPaidOutput.innerHTML = (temp).toFixed(2);
	totalFeesPercentageOutput.innerHTML = ((temp/(value - parseFloat(initialInvestment.value)))*100).toFixed(2);
// loop over fees showing how the expense ratio can eat a huge % of your profits. use JS as a way to animate and inform. 
//	console.log((temp).toFixed(2));

        // total.innerHTML = (monthly * payments).toFixed(2);
        // // Save the user's input so we can restore it the next time they visit
        // save(amount.value, apr.value, years.value, yearlyTaxes.value);

        // // Finally, chart loan balance, and interest and equity payments
        // chart(principal, interest, monthly, payments);
    }
    else {  
        // Result was Not-a-Number or infinite, which means the input was
        // incomplete or invalid. Clear any previously displayed output.
        value.innerHTML = "phail";        // Erase the content of these elements
	totalAppreciation.innerHTML = "pahil";
        // total.innerHTML = ""
        // totalinterest.innerHTML = "";
	// taxpayment.innerHTML = "";
        // chart();                       // With no arguments, clears the chart
    }

    //    computeAmortizationTable();
}

// // Save the user's input as properties of the localStorage object. Those
// // properties will still be there when the user visits in the future
// // This storage feature will not work in some browsers (Firefox, e.g.) if you 
// // run the example from a local file:// URL.  It does work over HTTP, however.
// function save(amount, apr, years, yearlyTaxes) {
//     if (window.localStorage) {  // Only do this if the browser supports it
//         localStorage.loan_amount = amount;
//         localStorage.loan_apr = apr;
//         localStorage.loan_years = years;
//         localStorage.loan_taxes = yearlyTaxes;
//     }
// }

// // Automatically attempt to restore input fields when the document first loads.
// window.onload = function() {
//     // If the browser supports localStorage and we have some stored data
//     if (window.localStorage && localStorage.loan_amount) {  
//         document.getElementById("amount").value = localStorage.loan_amount;
//         document.getElementById("apr").value = localStorage.loan_apr;
//         document.getElementById("years").value = localStorage.loan_years;
//         document.getElementById("taxes").value = localStorage.loan_taxes;
//     }
// };

// Chart monthly loan balance, interest and equity in an HTML <canvas> element.
// If called with no arguments then just erase any previously drawn chart.
function chart(principal, interest, monthly, payments) {
    var graph = document.getElementById("graph"); // Get the <canvas> tag
    graph.width = graph.width;  // Magic to clear and reset the canvas element

    // If we're called with no arguments, or if this browser does not support
    // graphics in a <canvas> element, then just return now.
    if (arguments.length == 0 || !graph.getContext) return;

    // Get the "context" object for the <canvas> that defines the drawing API
    var g = graph.getContext("2d"); // All drawing is done with this object
    var width = graph.width, height = graph.height; // Get canvas size

    // These functions convert payment numbers and dollar amounts to pixels
    function paymentToX(n) { return n * width/payments; }
    function amountToY(a) { return height-(a * height/(monthly*payments*1.05));}

    // Payments are a straight line from (0,0) to (payments, monthly*payments)
    g.moveTo(paymentToX(0), amountToY(0));         // Start at lower left
    g.lineTo(paymentToX(payments),                 // Draw to upper right
             amountToY(monthly*payments));
    g.lineTo(paymentToX(payments), amountToY(0));  // Down to lower right
    g.closePath();                                 // And back to start
    g.fillStyle = "#f05";                          // Light red
    g.fill();                                      // Fill the triangle
    g.font = "bold 12px sans-serif";               // Define a font
    g.fillText("Total Interest Payments", 20,20);  // Draw text in legend

    // Cumulative equity is non-linear and trickier to chart
    var equity = 0;
    g.beginPath();                                 // Begin a new shape
    g.moveTo(paymentToX(0), amountToY(0));         // starting at lower-left
    for(var p = 1; p <= payments; p++) {
        // For each payment, figure out how much is interest
        var thisMonthsInterest = (principal-equity)*interest;
        equity += (monthly - thisMonthsInterest);  // The rest goes to equity
        g.lineTo(paymentToX(p),amountToY(equity)); // Line to this point
    }
    g.lineTo(paymentToX(payments), amountToY(0));  // Line back to X axis
    g.closePath();                                 // And back to start point
    g.fillStyle = "green";                         // Now use green paint
    g.fill();                                      // And fill area under curve
    g.fillText("Total Equity", 20,35);             // Label it in green

    // Loop again, as above, but chart loan balance as a thick black line
    var bal = principal;
    g.beginPath();
    g.moveTo(paymentToX(0),amountToY(bal));
    for(var p = 1; p <= payments; p++) {
        var thisMonthsInterest = bal*interest;
        bal -= (monthly - thisMonthsInterest);     // The rest goes to equity
        g.lineTo(paymentToX(p),amountToY(bal));    // Draw line to this point
    }
    g.lineWidth = 3;                               // Use a thick line
    g.stroke();                                    // Draw the balance curve
    g.fillStyle = "black";                         // Switch to black text
    g.fillText("Loan Balance", 20,50);             // Legend entry

    // Now make yearly tick marks and year numbers on X axis
    g.textAlign="center";                          // Center text over ticks
    var y = amountToY(0);                          // Y coordinate of X axis
    for(var year=1; year*12 <= payments; year++) { // For each year
        var x = paymentToX(year*12);               // Compute tick position
        g.fillRect(x-0.5,y-3,1,3);                 // Draw the tick
        if (year == 1) g.fillText("Year", x, y-5); // Label the axis
        if (year % 5 == 0 && year*12 !== payments) // Number every 5 years
            g.fillText(String(year), x, y-5);
    }

    // Mark payment amounts along the right edge
    g.textAlign = "right";                         // Right-justify text
    g.textBaseline = "middle";                     // Center it vertically
    var ticks = [monthly*payments, principal];     // The two points we'll mark
    var rightEdge = paymentToX(payments);          // X coordinate of Y axis
    for(var i = 0; i < ticks.length; i++) {        // For each of the 2 points
        var y = amountToY(ticks[i]);               // Compute Y position of tick
        g.fillRect(rightEdge-3, y-0.5, 3,1);       // Draw the tick mark
        g.fillText(String(ticks[i].toFixed(0)),    // And label it.
                   rightEdge-5, y);
    }
}
