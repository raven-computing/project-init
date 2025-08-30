${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;


/**
 * Main class of the application.
 *
 */
public class Main extends Application {

    private static String STAGE_TITLE = "${{VAR_PROJECT_NAME}}";

    @Override
    public void start(Stage stage) throws Exception{
        Parent root = FXMLLoader.load(getClass().getResource("/layout/Scene.fxml"));

        Scene scene = new Scene(root);
        scene.getStylesheets().add(getClass().getResource("/css/styles.css").toExternalForm());

        stage.setTitle(Main.STAGE_TITLE);
        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args){
        if(args.length >= 2 && args[0].equals("--title")){
            Main.STAGE_TITLE = args[1];
        }
        launch(args);
    }

}
