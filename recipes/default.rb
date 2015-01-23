# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize
# Recipe:: default
#
# Copyright 2014, Onddo Labs, Sl.
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

r = ruby_block 'filesystem_resize' do
  Chef::Recipe.send(:include, FilesystemResize)
  block { Filesystems.resize_all }
  only_if { Filesystems.resize_any? }
end
r.run_action(:run) if node['filesystem_resize']['compiletime']
