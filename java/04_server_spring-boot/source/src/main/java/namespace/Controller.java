${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;


@RestController
public class Controller {

    @RequestMapping(
        path = "/",
        method = RequestMethod.GET)
    public String index(){
        return "${{VAR_PROJECT_SLOGAN_STRING}}";
    }

}
