# encoding: UTF-8

module FilesystemResizeCookbook
  # This class represent the underlying partition from the physical point of
  # view. If the physical partition is resized will be reflected here.
  class FilesystemDisk < DiskDeviceBase
    def self.lsblk_list
      cmd = shell_out('lsblk --raw --noheadings --output NAME')
      cmd.status.success? ? cmd.stdout : ''
    end

    def lsblk_block
      path = block_device.gsub(/'/, '')
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
        dev = name =~ /^\// ? name : "/dev/#{name}"
        devs << dev
        devs.delete(Regexp.last_match[1]) if dev =~ /^([^0-9]+)[0-9]+$/
      end
    end
  end
end
