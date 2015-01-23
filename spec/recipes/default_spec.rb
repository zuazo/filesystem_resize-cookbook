# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2015 Onddo Labs, SL. (www.onddo.com)
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

require 'spec_helper'

describe 'filesystem_resize::default' do
  before do
    stub_shell_out('losetup -a')
    stub_shell_out('lsblk --raw --noheadings --output NAME')
      .and_return_stdout(data_file('lsblk_ok.out'))
    stub_shell_out("losetup -j '/dev/xvda1'")
    stub_shell_out(
      "lsblk --bytes --raw --noheadings --output NAME,SIZE '/dev/xvda1'"
    ).and_return_stdout(data_file('lsblk_size_ok.out'))
    stub_shell_out("file --special-files --dereference '/dev/xvda1'")
      .and_return_stdout(data_file('file_ok.out'))
    stub_shell_out("dumpe2fs -h '/dev/xvda1'")
      .and_return_stdout(data_file('dumpe2fs_ok.out'))
  end

  context 'compiletime false' do
    let(:chef_run) do
      chef_runner = ChefSpec::Runner.new do |node|
        node.set['filesystem_resize']['compiletime'] = false
      end
      chef_runner.converge(described_recipe)
    end

    it 'runs fs resize at converge time' do
      expect(chef_run).to run_ruby_block('filesystem_resize')
    end
  end

  context 'compiletime true' do
    let(:chef_run) do
      chef_runner = ChefSpec::Runner.new do |node|
        node.set['filesystem_resize']['compiletime'] = true
      end
      chef_runner.converge(described_recipe)
    end

    it 'runs fs resize at converge time' do
      expect(chef_run).to run_ruby_block('filesystem_resize').at_compile_time
    end
  end
end
