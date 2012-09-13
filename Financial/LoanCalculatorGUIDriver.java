import javax.swing.JFrame;

public class LoanCalculatorGUIDriver
{
    public static void main(String[] args)
    {
	LoanCalculatorGUI LCG = new LoanCalculatorGUI();
	LCG.setDefaultCloseOperation( JFrame.EXIT_ON_CLOSE );
	LCG.setSize( 800, 110 ); // set frame size
	LCG.setVisible( true ); // display frame    
    }
}