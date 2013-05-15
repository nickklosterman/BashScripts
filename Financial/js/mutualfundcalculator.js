$(function() {
    $("#expenseRatio").slider({
	orientation: "horizontal",
	min: 0,
	max: 3,
	value: 1,
	slide: function (event, ui) {
//	    $("#expenseRatioOut").val(ui.value);
	    calculate();
	}
    })
    $("#expenseRatioOut").val( $("#expenseRatio").slider("value") );
});
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
    var history = [];

    var value = 0, valueNoFees = 0, totalAppreciation = 0 , totalFeesPaid = 0 ;    
    // Get the user's input from the input elements. Assume it is all valid.
    // Convert interest from a percentage to a decimal
    var temp = {};
    for ( var cntr = 0 ; cntr < parseInt(years.value) ; cntr++)
    {
	// Now compute the monthly payment figure.
	value  = (parseFloat(initialInvestment.value)*(1-parseFloat(redemptionFee.value)/100))*Math.pow(1 + parseFloat(annualReturn.value)/100, parseInt(years.value))*Math.pow(1-parseFloat(expenseRatio.value)/100,parseInt(years.value));   // Math.pow() computes powers
	valueNoFees  = (parseFloat(initialInvestment.value)*Math.pow(1 + parseFloat(annualReturn.value)/100, parseInt(years.value)));   // Math.pow() computes powers
	console.log(value);

	console.log(cntr,value,valueNoFees);

	temp.period = cntr;
	temp.value = value ;
	temp.valueNoFees = valueNoFees;
	history.push(temp);

    }


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


}

