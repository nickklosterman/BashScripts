import java.awt.*;
import java.awt.FlowLayout;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.JFrame;
import javax.swing.JTextField;
import javax.swing.JButton;
import javax.swing.JLabel;

import javax.swing.JOptionPane;

public class LoanCalculatorGUI extends JFrame
{
    private JLabel interest_rateLBL, principalLBL, insuranceLBL, taxesLBL, freqLBL, extra_paymentLBL, monthly_paymentLBL,loan_lengthLBL;
    private JButton button;
    private JTextField interest_rateTF, principalTF, insuranceTF, taxesTF, freqTF, extra_paymentTF, monthly_paymentTF,loan_lengthTF;

    private double  interest_rate,   principal,	insurance,taxes, extra_payment,monthly_payment;
    private int freq,loan_length;

   

    public LoanCalculatorGUI()
    //    public void init()
    //public static void main(String[] args)
    {
	super("Dialog Frame");
	setLayout(new FlowLayout());
	//Set up labels
	interest_rateLBL= new JLabel("Interest Rate"); 
	principalLBL= new JLabel("Principal $"); 
	insuranceLBL= new JLabel("Insurance $"); 
	taxesLBL= new JLabel("Yearly Property Taxes $"); 
	freqLBL= new JLabel("Frequency of Payments"); 
	extra_paymentLBL= new JLabel("Extra Monthly Payment Towards Principal $"); 
	monthly_paymentLBL= new JLabel("Monthly Payment $");
	loan_lengthLBL=new JLabel("Loan Length");

	interest_rateTF = new JTextField("4.00",5);
	principalTF  = new JTextField("1000000",7);
	insuranceTF = new JTextField("100",5);
	taxesTF  = new JTextField("1000",5); 
	freqTF  = new JTextField("12",2); 
	extra_paymentTF = new JTextField("0",6);
	monthly_paymentTF = new JTextField("0",6);
	loan_lengthTF = new JTextField("360",3);

	TextFieldHandler TFhandler=new TextFieldHandler();
	interest_rateTF.addActionListener(TFhandler);
	principalTF.addActionListener(TFhandler);
	insuranceTF.addActionListener(TFhandler);
	taxesTF.addActionListener(TFhandler);
	freqTF.addActionListener(TFhandler);
	extra_paymentTF.addActionListener(TFhandler);
	monthly_paymentTF.addActionListener(TFhandler);
	loan_lengthTF.addActionListener(TFhandler);

	add (interest_rateLBL); 
	add(interest_rateTF);
	add( principalLBL); 
	add( principalTF); 
	add( insuranceLBL); 
	add( insuranceTF); 
	add( taxesLBL); 
	add( taxesTF); 
	add( freqLBL); 
	add( freqTF); 
	add(loan_lengthLBL);
	add(loan_lengthTF);
	add( extra_paymentLBL); 
	add( extra_paymentTF); 
	add( monthly_paymentLBL );
	add( monthly_paymentTF );  //am pretty sure there is a better weay to do this.

	

	//set up button
	button=new JButton("Calculate Mortgage");
	ButtonActionHandler buttonActionHandler=new ButtonActionHandler();
	button.addActionListener( buttonActionHandler);
	add( button);
    }

    // private inner class for event handling
    private class TextFieldHandler implements ActionListener
    {
	// process text field events
	public void actionPerformed (ActionEvent event)
	{
	    String string = ""; // declare string to display

	    // user pressed Enter in JTextField textField1
	    if(event.getSource()==interest_rateTF )
		{
		interest_rate=Double.parseDouble(interest_rateTF.getText());
		string=""+interest_rate; //convert to string
		}
	    else if( event.getSource()==principalTF)
		principal=Double.parseDouble(principalTF.getText());

	    else if( event.getSource()==insuranceTF)
		insurance=Double.parseDouble(insuranceTF.getText());
	    else if( event.getSource()==taxesTF)
		taxes=Double.parseDouble(taxesTF.getText());
	    else if( event.getSource()==freqTF)
		freq=Integer.parseInt(freqTF.getText());
	    else if( event.getSource()==loan_lengthTF)
		loan_length=Integer.parseInt(loan_lengthTF.getText());
	    else if( event.getSource()==extra_paymentTF)
		extra_payment=Double.parseDouble(extra_paymentTF.getText());
	    else if( event.getSource()==monthly_paymentTF)
		monthly_payment=Double.parseDouble(monthly_paymentTF.getText());
	   
	    JOptionPane.showMessageDialog( null, string );
	} // end method actionPerformed
    } // end private inner class TextFieldHandler


private class ButtonActionHandler implements ActionListener
    {

	public void actionPerformed( ActionEvent e)
	{
	    //grab all the values we need
	    interest_rate=Double.parseDouble(interest_rateTF.getText());
	    principal=Double.parseDouble(principalTF.getText());
	    insurance=Double.parseDouble(insuranceTF.getText());
	    taxes=Double.parseDouble(taxesTF.getText());
	    freq=Integer.parseInt(freqTF.getText());
	    loan_length=Integer.parseInt(loan_lengthTF.getText());
	    extra_payment=Double.parseDouble(extra_paymentTF.getText());
	    monthly_payment=Double.parseDouble(monthly_paymentTF.getText());
	    System.out.format("interest rate %f; principal %f; insurance %f; taxes %f; freq %d; loan length %d; extra_payments %f; monthly_payment %f;",interest_rate,principal,insurance,taxes,freq,loan_length,extra_payment,monthly_payment);
	    System.out.println("you pressed: " + e.paramString() );
	    //call constructor for the mortgage objects and go from there
	    LoanCalculator LC;
	    LC = new LoanCalculator(); //enter values here
	}
    }
    
}