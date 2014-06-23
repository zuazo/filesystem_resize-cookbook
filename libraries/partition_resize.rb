require 'chef/mixin/shell_out'

module PartitionResize

  class Partition
    extend Chef::Mixin::ShellOut

    class Base
      extend Chef::Mixin::ShellOut

      def initialize(dev)
        from_loop = Partition.from_loop(dev)
        if ! from_loop.nil?
          @dev = from_loop
          @lo_dev = dev
        else
          @dev = dev
          @lo_dev = Partition.to_loop(dev)
        end
      end

      def loop_device
        @lo_dev
      end

      def block_device
        @lo_dev || @dev
      end

      def device
        @dev
      end

      def is_loop?
        ! @lo_dev.nil?
      end

      def to_s
        is_loop? ? "#{device} (#{loop_device})" : device
      end

    end

    class Physical < Base

      def size
        @size ||= begin
          cmd = self.class.shell_out("lsblk --bytes --raw --noheadings --output NAME,SIZE '#{block_device.gsub(/'/, '')}'")
          if cmd.exitstatus == 0
            line = cmd.stdout.split("\n")[0]
            dev = ::File.basename(block_device)
            case line
            when /^#{Regexp.escape(dev)}\s([0-9]+)/
              $1.to_i
            else
              nil
            end
          else
            nil
          end
        end
      end

      def self.list
        cmd = shell_out('lsblk --raw --noheadings --output NAME')
        if cmd.exitstatus == 0
          cmd.stdout.split("\n").inject([]) do |partitions, name|
            dev = name =~ /^\// ? name : "/dev/#{name}"
            partitions << dev
            partitions.delete($1) if dev =~ /^([^0-9]+)[0-9]+$/
            partitions
          end
        else
          []
        end
      end

    end # Physical

    class Logical < Base

      # Returns the partition logical size in bytes, nil if not found or error
      def size
        @size ||= begin
          block_count = block_size = nil
          case type
          when /^ext[0-9]+$/
            cmd = self.class.shell_out("dumpe2fs -h '#{device.gsub(/'/, '')}'")
            if cmd.exitstatus == 0
              cmd.stdout.split("\n").each do |line|
                case line
                when /^Block\s+count:\s+([0-9]+)$/
                  block_count = $1.to_i
                when /^Block\s+size:\s+([0-9]+)$/
                  block_size = $1.to_i
                end
              end
            end
          when 'xfs'
            # must be mounted
            cmd = self.class.shell_out("xfs_info '#{loop_device.gsub(/'/, '')}'")
            if cmd.exitstatus == 0
              cmd.stdout.split("\n").each do |line|
                case line
                when /^data\s+=\s+bsize=([0-9]+)\s+blocks=([0-9]+),/
                  block_size = $1.to_i
                  block_count = $2.to_i
               end
             end
            end
          end
          unless block_count.nil? or block_size.nil?
            block_count * block_size
          else
            nil
          end
        end
      end

      def type
        @type ||= begin
          cmd = self.class.shell_out("file --special-files --dereference '#{device.gsub(/'/, '')}'")
          if cmd.exitstatus == 0
            case cmd.stdout.split("\n")[0]
            when / ([^ ]+) filesystem /
              $1.downcase
            else
              nil
            end
          else
            nil
          end
        end
      end

      def mount_point
        @mount_point ||= begin
          cmd = self.class.shell_out("findmnt --list --first-only --canonicalize --evaluate --noheadings --output TARGET '#{block_device.gsub(/'/, '')}'")
          if cmd.exitstatus == 0
            cmd.stdout.split("\n")[0]
          else
            nil
          end
        end
      end

      def resize
        Chef::Log.info("#{self} type: #{type}")
        command = case type
        when /^ext[0-9]+$/
          if command_running?('resize2fs')
            Chef::Log.warn('PartitionResize: resize2fs already running, skipping')
            return nil
          end
          "resize2fs '#{device.gsub(/'/, '')}'"
        when 'xfs'
          if command_running?('xfs_growfs')
            Chef::Log.warn('PartitionResize: xfs_growfs already running, skipping')
            return false
          end
          if mount_point.nil?
            Chef::Log.warn("PartitionResize: mount point not found for #{self}, required by XFS")
          else
            "xfs_growfs -d '#{mount_point.gsub(/'/, '')}'"
          end
        else
          Chef::Log.warn("PartitionResize: unknown partition type: #{type}")
          return false
        end
        Chef::Log.info("PartitionResize: resizing #{self} partition... (#{command})")
        self.class.shell_out(command)
        return true
      end

      protected

      def command_running?(cmd)
        self.class.shell_out("pgrep '#{cmd.gsub(/'/, '')}'").exitstatus == 0
      end

    end # Logical

    # Partition class

    def initialize(dev)
      @dev = dev
    end

    def resize
      physical = Physical.new(@dev)
      logical = Logical.new(@dev)
      if !physical.size.nil? and !logical.size.nil?
        Chef::Log.info("#{physical}: physical size: #{physical.size}, logical size: #{logical.size}")
        logical.resize if physical.size > logical.size
      else
        false
      end
    end

    def self.resize_all
      partitions = Physical.list
      partitions.each do |dev|
        Partition.new(dev).resize
      end
    end

    def self.from_loop(dev)
      cmd = shell_out('losetup -a')
      if cmd.exitstatus == 0
        cmd.stdout.split("\n").each do |line|
          return $1 if line =~ /^#{Regexp.escape(dev)}: [^ ]+ [(](.+)[)]$/
        end
      end
      nil
    end

    def self.to_loop(dev)
      cmd = shell_out("losetup -j '#{dev.gsub(/'/, '')}'")
      if cmd.exitstatus == 0
        lo_dev = cmd.stdout.split(':', 2)[0]
        return lo_dev unless lo_dev.nil? or lo_dev.length == 0
      end
      nil
    end

  end # Partition

end # PartitionResize
