// source: https://github.com/sentenzo/dwtTemplate

import org.eclipse.swt.all;

void main ()
{
    auto display = new Display;

    auto shell = new Shell(display);
    shell.setLayout(new GridLayout(4, false));

    auto label = new Label(shell, 0);
    label.setText("Hello, DWT!");

	auto button0 = new Button(shell, SWT.ARROW);
	button0.setText("ARROW Me");
    auto button6 = new Button(shell, SWT.ARROW | SWT.LEFT);
	button6.setText("LEFT Me");
    auto button7 = new Button(shell, SWT.ARROW | SWT.RIGHT);
	button7.setText("RIGHT Me");
    auto button8 = new Button(shell, SWT.ARROW | SWT.DOWN);
    auto button1 = new Button(shell, SWT.CHECK);
	button1.setText("CHECK Me");
    auto button2 = new Button(shell, SWT.PUSH);
	button2.setText("PUSH Me");
    auto button3 = new Button(shell, SWT.RADIO);
	button3.setText("RADIO Me");
    auto button4 = new Button(shell, SWT.TOGGLE);
	button4.setText("TOGGLE Me");
    auto button5 = new Button(shell, SWT.FLAT);
	button5.setText("FLAT Me");

	button8.setText("CENTER Me");

    auto combo = new Combo(shell, SWT.NULL);
    combo.add("element1");
    combo.add("element2");
	combo.add("element3");
    
    Canvas canvas = new Canvas(shell,SWT.NO_REDRAW_RESIZE);
    canvas.addPaintListener(new class PaintListener {
        public void paintControl(PaintEvent e) {
            Rectangle clientArea = canvas.getClientArea();
            e.gc.setBackground(display.getSystemColor(SWT.COLOR_CYAN));
            e.gc.fillOval(0,0,clientArea.width,clientArea.height);
            e.gc.setBackground(display.getSystemColor(SWT.COLOR_BLUE));
            e.gc.setForeground(display.getSystemColor(SWT.COLOR_BLACK));
            e.gc.fillGradientRectangle(5,5,90,45,true);
        }
    });
    
    List list = new List(shell, SWT.BORDER | SWT.MULTI | SWT.V_SCROLL);
    list.add("element1");
    list.add("element2");
	list.add("element3");
    list.pack();
    
    Text textBox = new Text(shell, SWT.SINGLE | SWT.BORDER);
    textBox.setText("FILL ME IN");
    
    ProgressBar bar = new ProgressBar(shell, SWT.SMOOTH); 
    bar.setSelection(42);

    Scale scaleH = new Scale(shell, SWT.NULL);
    Scale scaleV = new Scale(shell, SWT.VERTICAL);
    scaleV.setMaximum(20);
    scaleV.setMinimum(0);

    Slider slider = new Slider(shell, SWT.NULL);
    
    TableTree tableTree = new TableTree(shell, SWT.NONE);
    Table table = tableTree.getTable();
    table.setHeaderVisible(true);
    table.setLinesVisible(false);

    int NUM = 3;
    for (int i = 0; i < NUM; i++) {
      new TableColumn(table, SWT.LEFT).setText("Column " );
    }
    for (int i = 0; i < NUM; i++) {
      TableTreeItem parent = new TableTreeItem(tableTree, SWT.NONE);
      parent.setText(0, "Parent " );
      parent.setText(1, "Data");
      parent.setText(2, "More data");

      for (int j = 0; j < NUM; j++) {
        TableTreeItem child = new TableTreeItem(parent, SWT.NONE);
        child.setText(0, "Child ");
        child.setText(1, "Some child data");
        child.setText(2, "More child data");
      }
      parent.setExpanded(true);
    }

    TableColumn[] columns = table.getColumns();
    for (int i = 0, n = cast(int)columns.length; i < n; i++) {
      columns[i].pack();
    }

    Button button = new Button(shell, SWT.PUSH);
    button.setText("EXIT");
    button.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
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