${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({
    StringGeneratorTest.class})
public class LibTests {
    
}
