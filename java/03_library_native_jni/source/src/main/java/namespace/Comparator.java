${{VAR_COPYRIGHT_HEADER}}

${{VAR_NAMESPACE_PACKAGE_DECLARATION}}

/**
 * Dummy interface.
 *
 * @param <T> The type of objects to compare.
 *
 */
public interface Comparator<T> {

    /**
     * Compares the specified object to the set object of this Comparator.
     *
     * @param val The object to compare.
     *
     * @return An int indicating the result of the comparison.
     *         Returns 0 (zero) if both objects are equal.
     *         Returns a negative int value if the set object is less
     *         than the specified object. Returns a positive int value if
     *         the set object is greater than the specified object.
     */
    public int compare(T val);

}
