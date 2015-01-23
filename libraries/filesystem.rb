# encoding: UTF-8

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
        "file --special-files --dereference '#{device.gsub(/'/, '')}'"
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
