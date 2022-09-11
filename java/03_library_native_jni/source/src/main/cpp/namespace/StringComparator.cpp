${{VAR_COPYRIGHT_HEADER}}

#include <string.h>

#include "${{VAR_NAMESPACE_PATH}}/StringComparator.h"


${{VAR_NAMESPACE_DECL_BEGIN}}

StringComparator::StringComparator(){ }

int StringComparator::compare(const char* str1, const char* str2){
    return strcmp(str1, str2);
}

${{VAR_NAMESPACE_DECL_END}}
