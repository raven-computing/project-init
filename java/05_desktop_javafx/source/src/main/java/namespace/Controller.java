${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.CheckBox;
import javafx.scene.control.Button;


/**
 * Dummy controller class.
 *
 */
public class Controller {

    @FXML
    private CheckBox checkboxLog;

    @FXML
    private Button btnClick;

    @FXML
    private Label labelTxt;
    
    @FXML
    private Label labelTxtCounter;
    
    @FXML
    private Label labelVersionJava;
    
    @FXML
    private Label labelVersionJFX;

    private int counter;

    public void initialize(){ }

    @FXML
    private void onButtonClick(ActionEvent event){
        ++counter;

        final String countValue = "(" + counter + ")";
        labelTxtCounter.setText(countValue);

        if(checkboxLog.isSelected()){
            System.out.println("You clicked me!  " + countValue);
        }

        final String jVersion = System.getProperty("java.version");
        final String jfxVersion = System.getProperty("javafx.version");

        labelVersionJava.setText("Java version: " + jVersion);
        labelVersionJFX.setText("JavaFX version: " + jfxVersion);

        labelTxt.setText("${{VAR_PROJECT_SLOGAN_STRING}}");
    }

}
