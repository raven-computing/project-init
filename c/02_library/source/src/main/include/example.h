${{VAR_COPYRIGHT_HEADER}}

#ifndef ${{VAR_PREFIX_INCLUDE_GUARD}}_EXAMPLE_H
#define ${{VAR_PREFIX_INCLUDE_GUARD}}_EXAMPLE_H

/**
 * Adds the number 42 to the specified number.
 *
 * @param number The number to add 42 to.
 * @return The specified number plus 42 added to it.
 */
int addFortyTwo(const int number);

/**
 * Returns a magic text string. The returned char pointer
 * must not be freed by the caller.
 *
 * @return A really cool text string.
 */
const char* getText();

#endif // ${{VAR_PREFIX_INCLUDE_GUARD}}_EXAMPLE_H
