# encoding: UTF-8
#
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

require 'spec_helper'

describe 'filesystem_resize::default' do
  let(:chef_runner) { ChefSpec::ServerRunner.new }
  let(:chef_run) { chef_runner.converge(described_recipe) }
  let(:node) { chef_runner.node }

  context 'compiletime false' do
    before { node.set['filesystem_resize']['compiletime'] = false }

    it 'resizes all filesystems at converge time' do
      expect(chef_run).to run_filesystem_resize_all('default')
        .at_converge_time
    end
  end

  context 'compiletime true' do
    before { node.set['filesystem_resize']['compiletime'] = true }

    it 'resizes all filesystems at compile time' do
      expect(chef_run).to run_filesystem_resize_all('default')
        .at_compile_time
    end
  end

  context 'inside filesystem_resize_all resource' do
    let(:chef_runner) do
      ChefSpec::ServerRunner.new(step_into: %w(filesystem_resize_all))
    end
    before do
      stub_shell_out('lsblk --raw --noheadings --output NAME')
        .and_return_stdout(data_file('lsblk.out'))
      stub_shell_out('losetup -a')
      stub_shell_out("losetup -j '/dev/xvda1'")
      stub_shell_out("file --special-files --dereference '/dev/xvda1'")
        .and_return_stdout(data_file('file.out'))
      stub_shell_out("dumpe2fs -h '/dev/xvda1'")
        .and_return_stdout(data_file('dumpe2fs.out'))
    end

    context 'when the size is correct' do
      before do
        stub_shell_out(
          "lsblk --bytes --raw --noheadings --output NAME,SIZE '/dev/xvda1'"
        ).and_return_stdout(data_file('lsblk_size_ok.out'))
      end

      it 'resizes xvda1 filesystems' do
        expect(chef_run).to_not run_filesystem_resize('/dev/xvda1')
      end
    end

    context 'when needs to be resized' do
      before do
        stub_shell_out(
          "lsblk --bytes --raw --noheadings --output NAME,SIZE '/dev/xvda1'"
        ).and_return_stdout(data_file('lsblk_size_resize.out'))
      end

      it 'resizes xvda1 filesystems' do
        expect(chef_run).to run_filesystem_resize('/dev/xvda1')
      end
    end
  end
end
