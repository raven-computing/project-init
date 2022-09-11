${{VAR_COPYRIGHT_HEADER}}

#include <iostream>

#include <jni.h>

// Application JNI header
#include "${{VAR_NAMESPACE_UNDERSCORE}}_StringComparator.h"

#include "${{VAR_NAMESPACE_PATH}}/StringComparator.h"

using ${{VAR_NAMESPACE_COLON}}::StringComparator;


JNIEXPORT void JNICALL
Java_${{VAR_NAMESPACE_UNDERSCORE}}_StringComparator_printTextNative0
(JNIEnv* env, jobject self){

    std::cout << "${{VAR_PROJECT_SLOGAN_STRING}}" << std::endl;
}

JNIEXPORT jint JNICALL
Java_${{VAR_NAMESPACE_UNDERSCORE}}_StringComparator_compareNative0
(JNIEnv* env, jobject self, jstring val2){

    jclass cls = env->GetObjectClass(self);
    jfieldID field = env->GetFieldID(cls, "val", "Ljava/lang/String;");
    jstring val1 = (jstring) env->GetObjectField(self, field);

    const char* str1 = env->GetStringUTFChars(val1, 0);
    const char* str2 = env->GetStringUTFChars(val2, 0);

    StringComparator comparator;
    const int res = comparator.compare(str1, str2);

    env->ReleaseStringUTFChars(val1, str1);
    env->ReleaseStringUTFChars(val2, str2);

    return res;
}
