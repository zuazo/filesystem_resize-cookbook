# encoding: UTF-8

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
      cmd = shell_out("dumpe2fs -h '#{@device.gsub(/'/, '')}'")
      return unless cmd.status.success?
      cmd.stdout.split("\n").each { |line| dumpe2fs_parse(line) }
    end

    def resize
      if command_running?('resize2fs')
        Chef::Log.warn("#{self.class}: resize2fs already running, skipping")
        return false
      end
      shell_out("e2fsck -f -y '#{@device.gsub(/'/, '')}'")
      shell_out("resize2fs '#{@device.gsub(/'/, '')}'").status.success?
    end
  end
end
