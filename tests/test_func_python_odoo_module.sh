#!/bin/bash
# Copyright (C) 2024 Raven Computing
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
# *      ***   Functionality Test for Python Odoo Module Projects   ***       *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_python_odoo_module.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=("LICENSE");
  files+=(".gitignore");
  files+=(".global.sh");
  files+=("setup.sh");
  files+=("build.sh");
  files+=("test.sh");
  files+=("setup.py");
  files+=("pyproject.toml");
  files+=("MANIFEST.in");
  files+=("requirements.txt");
  files+=(".docker/Dockerfile-build");
  files+=(".docker/etc/odoo.conf");
  files+=("the_test_module/__init__.py");
  files+=("the_test_module/__manifest__.py");
  files+=("the_test_module/controllers/__init__.py");
  files+=("the_test_module/controllers/the_test_module.py");
  files+=("the_test_module/models/__init__.py");
  files+=("the_test_module/models/new_model.py");
  files+=("the_test_module/security/ir.model.access.csv");
  files+=("the_test_module/security/the_test_module_groups.xml");
  files+=("the_test_module/security/new_model_security.xml");
  files+=("the_test_module/tests/__init__.py");
  files+=("the_test_module/tests/test_trivial.py");
  files+=("the_test_module/views/new_model_menus.xml");
  files+=("the_test_module/views/new_model_views.xml");
  files+=("the_test_module/views/report_invoice.xml");
  files+=("the_test_module/wizard/__init__.py");
  files+=("the_test_module/wizard/create_new_model_views.xml");
  files+=("the_test_module/wizard/create_new_model.py");
  files+=("docs/mkdocs.yaml");
  files+=("docs/index.md");

  local not_files=();
  not_files+=("the_test_module/controllers/module.py");
  not_files+=("the_test_module/security/module_groups.py");

  local dirs=();
  dirs+=("the_test_module");
  dirs+=("docs");

  local not_dirs=();
  not_dirs+=("module");

  assert_files_exist "${files[@]}"         &&
  assert_files_not_exist "${not_files[@]}" &&
  assert_dirs_exist "${dirs[@]}"           &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
