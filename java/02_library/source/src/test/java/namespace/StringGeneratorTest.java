${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * Tests for the StringGenerator class.
 *
 */
public class StringGeneratorTest {

    @BeforeClass
    public static void setUpBeforeClass(){ }

    @AfterClass
    public static void tearDownAfterClass(){ }

    @Before
    public void setUp(){ }

    @After
    public void tearDown(){ }

    @Test
    public void testStringIsNotEmpty() throws Exception{
        Generator<String> dummy = new StringGenerator();
        String val = dummy.generate();
        assertNotNull(val);
        assertFalse(val.isEmpty());
    }

}
