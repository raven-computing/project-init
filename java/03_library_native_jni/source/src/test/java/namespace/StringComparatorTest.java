${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

import static org.junit.Assert.*;
import static org.junit.Assume.*;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * Tests for the StringComparator class.
 *
 */
public class StringComparatorTest {

    /**
    * Indicates whether native shared libraries have been built
    * and are available to the test suite.
    */
    public static boolean nativeAvailable;

    @BeforeClass
    public static void setUpBeforeClass(){
        nativeAvailable = System.getProperty("nativeLibsAvailable", "false")
                                .equals("true");
    }

    @AfterClass
    public static void tearDownAfterClass(){ }

    @Before
    public void setUp(){ }

    @After
    public void tearDown(){ }

    @Test
    public void testTrivial() throws Exception{
        assertTrue(1 == 1);
    }

    @Test
    public void testStringEqual() throws Exception{
        assumeTrue(nativeAvailable);
        Comparator<String> dummy = new StringComparator("TEST-C");
        int res = dummy.compare("TEST-C");
        assertTrue(res == 0);
    }

    @Test
    public void testStringGreater() throws Exception{
        assumeTrue(nativeAvailable);
        Comparator<String> dummy = new StringComparator("TEST-C");
        int res = dummy.compare("TEST-E");
        assertTrue(res == -2);
    }

    @Test
    public void testStringSmaller() throws Exception{
        assumeTrue(nativeAvailable);
        Comparator<String> dummy = new StringComparator("TEST-C");
        int res = dummy.compare("TEST-A");
        assertTrue(res == 2);
    }

}
