# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize_test
# Library:: shell_run
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014-2015 Onddo Labs, SL. (www.onddo.com)
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Runs a shell command and returns the stdout.
module Shell
  extend Chef::Mixin::ShellOut

  def self.run(cmd)
    result = shell_out(cmd)
    unless result.status.success?
      fail "ShellOut error:\nSTDOUT\n#{result.stdout}\nSTDERR#{result.stderr}"
    end
    result.stdout
  end
end
