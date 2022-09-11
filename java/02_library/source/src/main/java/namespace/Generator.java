${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

/**
 * Dummy interface.
 *
 * @param <T> The type of objects to generate
 *
 */
public interface Generator<T> {

    /**
     * Generates an object of the Generator
     *
     * @return An object of the Generator
     */
    public T generate();

}
