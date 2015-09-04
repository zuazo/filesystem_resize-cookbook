# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize
# Library:: filesystem_disk
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

module FilesystemResizeCookbook
  # This class represent the underlying partition from the physical point of
  # view. If the physical partition is resized will be reflected here.
  class FilesystemDisk < DiskDeviceBase
    def self.lsblk_list
      cmd = shell_out('lsblk --raw --noheadings --output NAME')
      cmd.status.success? ? cmd.stdout : ''
    end

    def lsblk_block
      path = block_device.delete("'")
      cmd = shell_out(
        "lsblk --bytes --raw --noheadings --output NAME,SIZE '#{path}'"
      )
      cmd.status.success? ? cmd.stdout : ''
    end

    def size
      @size ||= begin
        line = lsblk_block.split("\n")[0]
        dev = ::File.basename(block_device)
        Regexp.last_match[1].to_i if line =~ /^#{Regexp.escape(dev)}\s([0-9]+)/
      end
    end

    def self.list
      lsblk_list.split("\n").each_with_object([]) do |name, devs|
        dev = name =~ %r{^/} ? name : "/dev/#{name}"
        devs << dev
        devs.delete(Regexp.last_match[1]) if dev =~ /^([^0-9]+)[0-9]+$/
      end
    end
  end
end
