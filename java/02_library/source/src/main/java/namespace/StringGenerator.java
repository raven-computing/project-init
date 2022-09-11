${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

/**
 * A dummy implementation of the {@link Generator} interface.
 *
 */
public class StringGenerator implements Generator<String> {

    private String val;
    private int n;

    /**
     * Constructs a new <code>StringGenerator</code> for generating dummy strings
     */
    public StringGenerator(){
        this.val = "${{VAR_PROJECT_SLOGAN_STRING}}";
    }

    /**
     * Generates a dummy String of this StringGenerator
     *
     * @return A String object of this Generator
     */
    @Override
    public String generate(){
        return this.val + " " + (n++);
    }

}
