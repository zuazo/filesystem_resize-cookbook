# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize
# Library:: filesystem_type_base
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015 Onddo Labs, SL.
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
  # File system type class to use as parent by other file system type classes.
  class FilesystemTypeBase
    include Chef::Mixin::ShellOut

    def initialize(dev, blk_dev)
      @device = dev
      @block_device = blk_dev
      @block_count = @block_size = nil
    end

    def block_count
      return @block_count unless @block_count.nil?
      size_parse
      @block_count
    end

    def block_size
      return @block_size unless @block_size.nil?
      size_parse
      @block_size
    end

    def command_running?(cmd)
      shell_out("pgrep '#{cmd.delete("'")}'").status.success?
    end

    def mount_point
      @mount_point ||= begin
        cmd = shell_out(
          'findmnt --list --first-only --canonicalize --evaluate '\
          '--noheadings --output TARGET '\
          "'#{@block_device.delete("'")}'"
        )
        cmd.status.success? ? cmd.stdout.split("\n")[0] : nil
      end
    end

    def size_parse
      fail "#{self}#size_parse not implemented."
    end

    def resize
      fail "#{self}#resize not implemented."
    end
  end
end
