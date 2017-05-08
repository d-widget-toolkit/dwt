module hellodwt;

/*
	it's generally not a good practice to include all
	this will increase the size of the exe
	however, if you use upx to compress, the increase is only about 100Kb
*/

import org.eclipse.swt.all;

/*
//these would be the correct imports for the code below
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
*/

void main()
{
    auto display = new Display;
    auto shell = new Shell;
    shell.setText("Hello World!");
	
	shell.setLayout(new RowLayout());
	
	Label lblInfo = new Label(shell, SWT.NONE);
	lblInfo.setText("With Visual Styles enabled, buttons change color when you hover over them: ");

	Button btnOK = new Button(shell, SWT.BORDER);
    btnOK.setText("OK");
	
	btnOK.addSelectionListener(new class SelectionAdapter
	{
		override public void widgetSelected(SelectionEvent e)
		{
			display.dispose();
		}
	});
	
	shell.pack();
    shell.open();

    while (!shell.isDisposed)
        if (!display.readAndDispatch())
            display.sleep();

    display.dispose();
}
