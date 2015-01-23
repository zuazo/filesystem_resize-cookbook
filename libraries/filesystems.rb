# encoding: UTF-8

require 'chef/mixin/shell_out'

module FilesystemResize
  # Cookbook Helper to resize file systems
  class Filesystems
    extend Chef::Mixin::ShellOut

    def initialize(dev)
      @device = dev
    end

    def physical
      @physical ||= FilesystemDisk.new(@device)
    end

    def logical
      @logical ||= Filesystem.new(@device)
    end

    def resize?
      !physical.size.nil? && !logical.size.nil? &&
        physical.size > logical.size
    end

    def resize
      if resize?
        Chef::Log.info("#{physical}: physical size: #{physical.size}, "\
          "logical size: #{logical.size}")
        logical.resize
      else
        false
      end
    end

    def self.resize_any?
      devs = FilesystemDisk.list
      devs.reduce(false) do |r, dev|
        r || Filesystems.new(dev).resize?
      end
    end

    def self.resize_all
      devs = FilesystemDisk.list
      devs.reduce(false) do |r, dev|
        Filesystems.new(dev).resize || r
      end
    end

    def self.from_loop(dev)
      cmd = shell_out('losetup -a')
      if cmd.status.success?
        cmd.stdout.split("\n").each do |line|
          next unless line =~ /^#{Regexp.escape(dev)}: [^ ]+ [(](.+)[)]$/
          return Regexp.last_match[1]
        end
      end
      nil
    end

    def self.to_loop(dev)
      cmd = shell_out("losetup -j '#{dev.gsub(/'/, '')}'")
      if cmd.status.success?
        lo_dev = cmd.stdout.split(':', 2)[0]
        return lo_dev unless lo_dev.nil? || lo_dev.length == 0
      end
      nil
    end
  end
end
