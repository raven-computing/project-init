#!/bin/bash
# Copyright (C) 2025 Raven Computing
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# #***************************************************************************#
# *                                                                           *
# *            ***   Compatibility Tests for the awk command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: echo "TEST_A:VALUE-1" |awk -F  ":" '{print $1}'
function test_single_delimiter_first() {
  local expected="TEST_A";
  local actual;
  actual=$(echo "TEST_A:VALUE-1" |awk -F  ":" '{print $1}');
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "TEST_B:VALUE-2" |awk -F  ":" '{print $2}'
function test_single_delimiter_second() {
  local expected="VALUE-2";
  local actual;
  actual=$(echo "TEST_B:VALUE-2" |awk -F  ":" '{print $2}');
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "TEST_A=>VALUE_1" |awk -F'=>' '{print $1}'
function test_multichar_delimiter_first() {
  local expected="TEST_A";
  local actual;
  actual=$(echo "TEST_A=>VALUE_1" |awk -F'=>' '{print $1}');
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo " TEST_B => VALUE_2 " |awk -F'=>' '{print $2}'
function test_multichar_delimiter_second() {
  local expected=" VALUE_2 ";
  local actual;
  actual=$(echo " TEST_B => VALUE_2 " |awk -F'=>' '{print $2}');
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: awk 'NR!~/^('"3"')$/' "resources/awk_remove_line.txt"
function test_remove_line_from_file() {
  local line_num=3;
  local expected="";
  expected=$(cat << EOS
Line A
Line B
Line D
Line E
EOS
)
  local actual;
  actual="$(awk 'NR!~/^('"$line_num"')$/' "resources/awk_remove_line.txt")";
  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_replace_variable_from_file() {
  local _var_key="TEST_KEY";
  local _var_value="TEST_VALUE";
  local expected="";
  expected=$(cat << EOS
Line A
Line B TEST_VALUE_Data
Line C
EOS
)
  local actual;
  # shellcheck disable=SC2030
  actual="$(export value="${_var_value}" &&               \
            awk -v key='\\${{VAR_'"${_var_key}"'}}'       \
                '{ gsub(key, ENVIRON["value"]); print; }' \
                "resources/awk_replace_var.txt")";

  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_replace_include_directive_from_file() {
  local _include_file_key="the/shared/file/to/include";
  local _include_value="";
  _include_value=$(cat << EOS
  _INCL_BEGIN_  
THE_INCLUDED_DATA with an esc slash \/ and dot \. and an & ampersand
  _INCL_END_  
EOS
)

  _include_value="${_include_value//&/\\&}";

  local expected="";
  expected=$(cat << EOS
Line A
Line B
Line C
  _INCL_BEGIN_  
THE_INCLUDED_DATA with an esc slash \/ and dot \. and an & ampersand
  _INCL_END_  
Line D
Line E
EOS
)
  local actual;
  # shellcheck disable=SC2031
  actual=$(export value="${_include_value}" &&                  \
           awk -v key='\\${{INCLUDE:'"${_include_file_key}"'}}' \
                '{ gsub(key, ENVIRON["value"]); print; }'       \
                "resources/awk_replace_include_directive.txt");

  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_replace_all_strings_in_file() {
  local input_file="resources/awk_replace_strings.txt";
  local source_str="The_Source_\\(<\\)\\[_String";
  local target_str="";
  target_str=$(cat << EOS
A multi-line replacement string
;\'\\:&/%~\`\\.$}_-#|^@,"\\{]?+!\\>*[=)<(
With special chars
The END.
EOS
)

  target_str="${target_str//&/\\&}";
  local expected="";
  expected=$(cat << EOS
Line A
Line B A multi-line replacement string
;\'\\:&/%~\`\\.$}_-#|^@,"\\{]?+!\\>*[=)<(
With special chars
The END.DataA multi-line replacement string
;\'\\:&/%~\`\\.$}_-#|^@,"\\{]?+!\\>*[=)<(
With special chars
The END.
Line C
( 2 < F P Z d n x
) 3 = G Q [ e o y
* 4 > H R \ f p z
! + 5 ? I S ] g q {
" , 6 @ J T ^ h r |
# - 7 A K U _ i s }
$ . 8 B L V \` j t ~
% / 9 C M W a k u
& 0 : D N X b l v
' 1 ; E O Y c m w
A multi-line replacement string
;\'\\:&/%~\`\\.$}_-#|^@,"\\{]?+!\\>*[=)<(
With special chars
The END.
Line D
EOS
)

  local actual;
  # shellcheck disable=SC2030
  actual=$(export replacement="$target_str" &&                \
            awk -v str="$source_str"                          \
              '{ gsub(str, ENVIRON["replacement"]); print; }' \
              "$input_file");

  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_replace_n_string_occurrences_in_file() {
  local input_file="resources/awk_replace_strings.txt";
  local repl_count=1;
  local source_str="The_Source_\\(<\\)\\[_String";
  local target_str="";
  target_str=$(cat << EOS
A multi-line replacement string
;\'\\:&/%~\`\\.$}_-#|^@,"\\{]?+!\\>*[=)<(
With special chars
The END.
EOS
)

  target_str="${target_str//&/\\&}";
  local expected="";
  expected=$(cat << EOS
Line A
Line B A multi-line replacement string
;\'\\:&/%~\`\\.$}_-#|^@,"\\{]?+!\\>*[=)<(
With special chars
The END.DataThe_Source_(<)[_String
Line C
( 2 < F P Z d n x
) 3 = G Q [ e o y
* 4 > H R \ f p z
! + 5 ? I S ] g q {
" , 6 @ J T ^ h r |
# - 7 A K U _ i s }
$ . 8 B L V \` j t ~
% / 9 C M W a k u
& 0 : D N X b l v
' 1 ; E O Y c m w
The_Source_(<)[_String
Line D
EOS
)

  local actual;
  # shellcheck disable=SC2031
  actual=$(
    export replacement="$target_str" &&                                       \
      awk -v limit=$repl_count                                                \
          -v str="$source_str"                                                \
          'limit>0 && sub(str, ENVIRON["replacement"]){limit-=1}; { print; }' \
          "$input_file");

  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_single_delimiter_first              &&
  test_single_delimiter_second             &&
  test_multichar_delimiter_first           &&
  test_multichar_delimiter_second          &&
  test_remove_line_from_file               &&
  test_replace_variable_from_file          &&
  test_replace_include_directive_from_file &&
  test_replace_all_strings_in_file         &&
  test_replace_n_string_occurrences_in_file;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi
