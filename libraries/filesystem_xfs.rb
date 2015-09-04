# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize
# Library:: filesystem_xfs
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
  # XFS file system type class.
  class FilesystemXfs < FilesystemTypeBase
    def xfs_info_parse(line)
      return unless line =~ /^data\s+=\s+bsize=([0-9]+)\s+blocks=([0-9]+),/
      @block_size = Regexp.last_match[1].to_i
      @block_count = Regexp.last_match[2].to_i
    end

    # must be mounted
    def size_parse
      cmd = shell_out("xfs_info '#{mount_point.delete("'")}'")
      return unless cmd.status.success?
      cmd.stdout.split("\n").each { |line| xfs_info_parse(line) }
    end

    def resize
      if command_running?('xfs_growfs')
        Chef::Log.warn("#{self.class}: xfs_growfs already running, skipping")
        return false
      elsif mount_point.nil?
        Chef::Log.warn(
          "#{self.class}: mount point not found for #{self}, skipping")
        return false
      end
      shell_out("xfs_growfs -d '#{mount_point.delete("'")}'")
        .status.success?
    end
  end
end
