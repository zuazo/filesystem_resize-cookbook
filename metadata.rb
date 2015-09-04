# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2014-2015 Onddo Labs, SL.
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

name 'filesystem_resize'
maintainer 'Xabier de Zuazo'
maintainer_email 'xabier@zuazo.org'
license 'Apache 2.0'
description <<-EOS
Resize the file system automatically when the underlying partition or disk
increases its size.
EOS
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0'

if respond_to?(:source_url)
  source_url "https://github.com/zuazo/#{name}-cookbook"
end
if respond_to?(:issues_url)
  issues_url "https://github.com/zuazo/#{name}-cookbook/issues"
end

supports 'amazon', '>= 2012.03'
supports 'centos', '>= 6.0'
supports 'debian', '>= 7.0'
supports 'fedora'
supports 'redhat'
supports 'ubuntu', '>= 12.04'

recipe 'filesystem_resize::default', 'Resizes all mounted file systems.'

provides 'filesystem_resize'
provides 'filesystem_resize_all'

attribute 'filesystem_resize/compiletime',
          display_name: 'fs resize at compile time',
          description: 'Resize the file sistems at compile time.',
          choice: %w(true false),
          type: 'string',
          required: 'optional',
          default: 'false'
