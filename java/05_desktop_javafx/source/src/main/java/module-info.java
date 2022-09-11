module ${{VAR_NAMESPACE_DECLARATION}} {
    requires javafx.controls;
    requires javafx.fxml;

    opens ${{VAR_NAMESPACE_DECLARATION}} to javafx.fxml;
    exports ${{VAR_NAMESPACE_DECLARATION}};
}
