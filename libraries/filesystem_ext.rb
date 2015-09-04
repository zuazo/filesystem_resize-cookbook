# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize
# Library:: filesystem_ext
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

require_relative 'filesystem_type_base'

module FilesystemResizeCookbook
  # ext2, ext3 and ext4 file system types class.
  class FilesystemExt < FilesystemTypeBase
    def dumpe2fs_parse(line)
      case line
      when /^Block\s+count:\s+([0-9]+)$/
        @block_count = Regexp.last_match[1].to_i
      when /^Block\s+size:\s+([0-9]+)$/
        @block_size = Regexp.last_match[1].to_i
      end
    end

    def size_parse
      cmd = shell_out("dumpe2fs -h '#{@device.delete("'")}'")
      return unless cmd.status.success?
      cmd.stdout.split("\n").each { |line| dumpe2fs_parse(line) }
    end

    def resize
      if command_running?('resize2fs')
        Chef::Log.warn("#{self.class}: resize2fs already running, skipping")
        return false
      end
      shell_out("e2fsck -f -y '#{@device.delete("'")}'")
      shell_out("resize2fs '#{@device.delete("'")}'").status.success?
    end
  end
end
