# encoding: UTF-8

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
      shell_out("pgrep '#{cmd.gsub(/'/, '')}'").status.success?
    end

    def mount_point
      @mount_point ||= begin
        cmd = shell_out(
          'findmnt --list --first-only --canonicalize --evaluate '\
          '--noheadings --output TARGET '\
          "'#{@block_device.gsub(/'/, '')}'"
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
