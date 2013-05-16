
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
    var annualContribution = (document.getElementById("annualContribution"));
    var history = [];
    var value = 0, valueNoFees = 0, totalAppreciation = 0 , totalFeesPaid = 0 ;    

    var investedAmount = parseFloat(initialInvestment.value);
    var temp= {};
    for ( var cntr = 0 ; cntr < parseInt(years.value) ; cntr++)
    {

	value  = investedAmount*(1 + parseFloat(annualReturn.value)/100);
	investedAmount = value + parseFloat(annualContribution.value);
	console.log(value,investedAmount);

	console.log(cntr,value);

	temp.period = cntr;
	temp.value = value ;
	temp.investedAmount = investedAmount;
	history.push(temp);

    }


    // If the result is a finite number, the user's input was good and
    // we have meaningful results to display
    if (isFinite(value)) {
	console.log("finite");
        // Fill in the output fields, rounding to 2 decimal places
        valueOutput.innerHTML = value.toFixed(2);
//	valueNoFeesOutput.innerHTML = valueNoFees.toFixed(2);
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
    }
}
