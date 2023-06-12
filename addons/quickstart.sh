#!/bin/bash
# Copyright (C) 2023 Raven Computing
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
# *                   ***   Addon Quickstart Functions  ***                   *
# *                                                                           *
# #***************************************************************************#


function quickstart_addon_function() {
  logI "Creating addon example executable script";
  copy_shared "example.sh" "example.sh";
  replace_var "VAR_FOO" "bar";
  return $QUICKSTART_STATUS_OK;
}

# Alias for quickstart_addon_function()
function quickstart_example_sh() {
  quickstart_addon_function;
  return $?;
}
