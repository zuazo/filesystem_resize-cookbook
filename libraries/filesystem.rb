# encoding: UTF-8

module FilesystemResize
  # This class represent the logical file system as seen from the
  # operating system
  class Filesystem < DiskDeviceBase
    def initialize(dev)
      super
      @block_count = @block_size = nil
    end

    def command_running?(cmd)
      shell_out("pgrep '#{cmd.gsub(/'/, '')}'").status.success?
    end

    def ext_size
      cmd = shell_out("dumpe2fs -h '#{device.gsub(/'/, '')}'")
      return unless cmd.status.success?
      cmd.stdout.split("\n").each do |line|
        case line
        when /^Block\s+count:\s+([0-9]+)$/
          @block_count = Regexp.last_match[1].to_i
        when /^Block\s+size:\s+([0-9]+)$/
          @block_size = Regexp.last_match[1].to_i
        end
      end
    end

    def ext_resize
      if command_running?('resize2fs')
        Chef::Log.warn("#{self.class}: resize2fs already running, skipping")
        return false
      end
      shell_out("e2fsck -f -y '#{device.gsub(/'/, '')}'")
      shell_out("resize2fs '#{device.gsub(/'/, '')}'").status.success?
    end

    # must be mounted
    def xfs_size
      cmd = shell_out("xfs_info '#{mount_point.gsub(/'/, '')}'")
      return unless cmd.status.success?
      cmd.stdout.split("\n").each do |line|
        next unless line =~ /^data\s+=\s+bsize=([0-9]+)\s+blocks=([0-9]+),/
        @block_size = Regexp.last_match[1].to_i
        @block_count = Regexp.last_match[2].to_i
      end
    end

    def xfs_resize
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

    def file_type
      cmd = shell_out(
        "file --special-files --dereference '#{device.gsub(/'/, '')}'"
      )
      return nil unless cmd.status.success?
      cmd.stdout.split("\n")[0]
    end

    # Returns the fs logical size in bytes, nil if not found or error
    def size
      @size ||= begin
        case type
        when /^ext[0-9]+$/ then ext_size
        when 'xfs' then xfs_size
        end
        @block_count * @block_size unless @block_count.nil? || @block_size.nil?
      end
    end

    def type
      @type ||= begin
        if file_type =~ / ([^ ]+) filesystem /
          Regexp.last_match[1].downcase
        else
          nil
        end
      end
    end

    def mount_point
      @mount_point ||= begin
        cmd = shell_out(
          'findmnt --list --first-only --canonicalize --evaluate '\
          '--noheadings --output TARGET '\
          "'#{block_device.gsub(/'/, '')}'"
        )
        cmd.status.success? ? cmd.stdout.split("\n")[0] : nil
      end
    end

    def resize
      Chef::Log.debug("#{self} type: #{type}")
      case type
      when /^ext[0-9]+$/ then ext_resize
      when 'xfs' then xfs_resize
      else
        Chef::Log.warn("#{self.class}: unknown fs type: #{type}")
        return false
      end
      true # ignore console errors
    end
  end
end
