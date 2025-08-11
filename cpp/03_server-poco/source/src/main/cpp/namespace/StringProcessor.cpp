${{VAR_COPYRIGHT_HEADER}}

#include <string>
#include <algorithm>

#include "${{VAR_NAMESPACE_PATH}}/StringProcessor.h"


${{VAR_NAMESPACE_DECL_BEGIN}}
using std::string;

StringProcessor::StringProcessor(const string& value)
    :val(value){ }


string StringProcessor::reverse(){
    string reversed(val);
    std::reverse_copy(std::begin(val), std::end(val), std::begin(reversed));
    return reversed;
}

${{VAR_NAMESPACE_DECL_END}}
