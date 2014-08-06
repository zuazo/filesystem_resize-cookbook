# encoding: UTF-8

require 'chef/mixin/shell_out'

module FilesystemResize
  # Cookbook Helper to resize file systems
  class Filesystems
    extend Chef::Mixin::ShellOut

    def initialize(dev)
      @device = dev
    end

    def resize
      physical = FilesystemDisk.new(@device)
      logical = Filesystem.new(@device)
      if !physical.size.nil? && !logical.size.nil?
        Chef::Log.info("#{physical}: physical size: #{physical.size}, "\
          "logical size: #{logical.size}")
        logical.resize if physical.size > logical.size
      else
        false
      end
    end

    def self.resize_all
      devs = FilesystemDisk.list
      devs.each do |dev|
        Filesystem.new(dev).resize
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
