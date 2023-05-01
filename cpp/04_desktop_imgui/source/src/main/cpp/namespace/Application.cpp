${{VAR_COPYRIGHT_HEADER}}

#include <memory>
#include <string>

#include "${{VAR_NAMESPACE_PATH}}/Application.h"
#include "${{VAR_NAMESPACE_PATH}}/Window.h"


${{VAR_NAMESPACE_DECL_BEGIN}}
using std::string;
using std::unique_ptr;
using std::make_unique;

string Application::getTitle(){
    return "${{VAR_PROJECT_SLOGAN_STRING}}";
}

int Application::run(){

    unique_ptr<Window> window = make_unique<Window>("Demo Window");

    int statSetup = window->setup();
    if(statSetup != 0){
        return statSetup;
    }

    int statCreate = window->create();
    if(statCreate != 0){
        return statCreate;
    }

    window->show();

    window->terminate();

    return 0;
}

${{VAR_NAMESPACE_DECL_END}}
