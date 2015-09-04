# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize
# Library:: filesystem
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
  # This class represent the logical file system as seen from the
  # operating system
  class Filesystem < DiskDeviceBase
    def initialize(dev)
      super
      @block_count = @block_size = nil
    end

    def fs_object
      @fs_object ||= begin
        Chef::Log.debug("#{self} type: #{type}")
        case type
        when /^ext[0-9]+$/ then FilesystemExt.new(device, block_device)
        when 'xfs' then FilesystemXfs.new(device, block_device)
        else
          Chef::Log.warn("#{self.class}: Unknown fs type: #{type}")
          return nil
        end
      end
    end

    def file_type
      cmd = shell_out(
        "file --special-files --dereference '#{device.delete("'")}'"
      )
      return nil unless cmd.status.success?
      cmd.stdout.split("\n")[0]
    end

    def block_count
      return nil if fs_object.nil?
      fs_object.block_count
    end

    def block_size
      return nil if fs_object.nil?
      fs_object.block_size
    end

    # Returns the fs logical size in bytes, nil if not found or error
    def size
      @size ||= begin
        block_count * block_size unless block_count.nil? || block_size.nil?
      end
    end

    def type
      @type ||= begin
        Regexp.last_match[1].downcase if file_type =~ / ([^ ]+) filesystem /
      end
    end

    def resize
      return false if fs_object.nil?
      fs_object.resize
      true # ignore console errors
    end
  end
end
