# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize
# Library:: disk_device_base
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

require 'chef/mixin/shell_out'
require 'forwardable'

module FilesystemResizeCookbook
  # Disk device type abstract base class
  class DiskDeviceBase
    extend Forwardable
    extend Chef::Mixin::ShellOut

    attr_reader :device
    attr_reader :loop_device

    def initialize(dev)
      from_loop = Filesystems.from_loop(dev)
      if !from_loop.nil?
        @device = from_loop
        @loop_device = dev
      else
        @device = dev
        @loop_device = Filesystems.to_loop(dev)
      end
    end

    def self.shell_out(*args)
      cmd = super(*args)
      Chef::Log.debug("#shell_out: #{args[0]}")
      unless cmd.status.success?
        Chef::Log.info("#shell_out #{args[0]} (STDOUT): #{cmd.stdout}")
        Chef::Log.info("#shell_out #{args[0]} (STDERR): #{cmd.stderr}")
      end
      cmd
    end
    def_delegator self, :shell_out

    def block_device
      @loop_device || @device
    end

    def loop?
      !@loop_device.nil?
    end

    def to_s
      loop? ? "#{device} (#{loop_device})" : device
    end
  end
end
