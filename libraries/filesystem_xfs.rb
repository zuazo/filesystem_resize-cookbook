# encoding: UTF-8

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
      cmd = shell_out("xfs_info '#{mount_point.gsub(/'/, '')}'")
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
      shell_out("xfs_growfs -d '#{mount_point.gsub(/'/, '')}'")
        .status.success?
    end
  end
end
