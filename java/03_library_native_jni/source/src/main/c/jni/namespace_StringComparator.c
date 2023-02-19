${{VAR_COPYRIGHT_HEADER}}

#include <jni.h>

// Application JNI header
#include "${{VAR_NAMESPACE_UNDERSCORE}}_StringComparator.h"

#include "${{VAR_NAMESPACE_PATH}}/string_comparator.h"


JNIEXPORT void JNICALL
Java_${{VAR_NAMESPACE_UNDERSCORE}}_StringComparator_printTextNative0
(JNIEnv* env, jobject self){

    printf("${{VAR_PROJECT_SLOGAN_STRING}}\n");
}

JNIEXPORT jint JNICALL
Java_${{VAR_NAMESPACE_UNDERSCORE}}_StringComparator_compareNative0
(JNIEnv* env, jobject self, jstring val2){

    jclass cls = (*env)->GetObjectClass(env, self);
    jfieldID field = (*env)->GetFieldID(env, cls, "val", "Ljava/lang/String;");
    jstring val1 = (jstring) (*env)->GetObjectField(env, self, field);

    const char* str1 = (*env)->GetStringUTFChars(env, val1, 0);
    const char* str2 = (*env)->GetStringUTFChars(env, val2, 0);

    const int res = compare_strings(str1, str2);

    (*env)->ReleaseStringUTFChars(env, val1, str1);
    (*env)->ReleaseStringUTFChars(env, val2, str2);

    return res;
}
