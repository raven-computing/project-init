${{VAR_COPYRIGHT_HEADER}}

#ifndef ${{VAR_NAMESPACE_INCLUDE_GUARD}}_STRING_COMPARATOR_H
#define ${{VAR_NAMESPACE_INCLUDE_GUARD}}_STRING_COMPARATOR_H


${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * Native implementation of the Java StringComparator class.
 *
 */
class StringComparator {

public:

    /**
     * Constructs a new StringComparator for comparing strings.
     */
    StringComparator();

    /**
     * Compares two strings.
     *
     * @param str1 The first string to compare.
     * @param str2 The second string to compare.
     *
     * @return An int indicating the result of the string comparison.
     */
    int compare(const char* str1, const char* str2);

}; // END CLASS StringComparator

${{VAR_NAMESPACE_DECL_END}}
#endif // ${{VAR_NAMESPACE_INCLUDE_GUARD}}_STRING_COMPARATOR_H
