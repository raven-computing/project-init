${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

/**
 * An implementation of the {@link Comparator} interface using Strings.
 *
 */
public class StringComparator implements Comparator<String> {

    static {
        //Load the native library code. For the example code,
        //we do not handle any errors here
        System.loadLibrary("${{VAR_PROJECT_NAME_LOWER}}java");
    }

    private String val;

   /**
    * Constructs a new <code>StringComparator</code> for comparing strings.
    *
    * @param val The first String object to compare. Must not be null.
    */
    public StringComparator(final String val){
        this.val = val;
    }

   /**
    * Prints some example text on stdout.
    */
    public void printText(){
        printTextNative0();
    }

   /**
    * Compares the specified string to the set string of this StringComparator.
    *
    * @param val The second String object to compare. Must not be null.
    * @return An int as specified by the <code>Comparator</code> interface.
    */
    @Override
    public int compare(final String val){
        if(this.val == null){
            throw new RuntimeException("Value of StringComparator is null");
        }
        if(val == null){
            throw new RuntimeException("Argument must not be null");
        }
        return compareNative0(val);
    }

   /**
    * Native implementation of the printText() method.
    */
    private native void printTextNative0();

   /**
    * Native implementation of the compare() method.
    *
    * @param val The second String object to compare. Must not be null.
    * @return An int as specified by the <code>Comparator</code> interface.
    */
    private native int compareNative0(String val);

}
