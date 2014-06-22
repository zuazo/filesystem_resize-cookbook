require 'chef/mixin/shell_out'

class PartitionResize

  class Partition

    class Base
      extend Chef::Mixin::ShellOut

      def initialize(dev)
        @dev = dev
      end
    end

    class Physical < Base

      def size
        @size ||= begin
          cmd = self.class.shell_out("lsblk --bytes --raw --noheadings --output NAME,SIZE '#{@dev.gsub(/'/, '')}'")
          if cmd.exitstatus == 0
            line = cmd.stdout.split("\n")[0]
            dev = ::File.basename(@dev)
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
          cmd = self.class.shell_out("dumpe2fs -h '#{@dev.gsub(/'/, '')}'")
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
          unless block_count.nil? or block_size.nil?
            block_count * block_size
          else
            nil
          end
        end
      end

      def type
        @type ||= begin
          cmd = self.class.shell_out("file --special-files --dereference '#{@dev.gsub(/'/, '')}'")
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

      def get_mountpoint
        @mountpoint ||= begin
          cmd = self.class.shell_out("findmnt --list --first-only --canonicalize --evaluate --noheadings --output TARGET '#{@dev.gsub(/'/, '')}'")
          if cmd.exitstatus == 0
            cmd.stdout.split("\n")[0]
          else
            nil
          end
        end
      end

      def resize
        Chef::Log.info("#{@dev} type: #{type}")
        command = case type
        when /^ext[0-9]+$/
          if command_running?('resize2fs')
            Chef::Log.warn('PartitionResize: resize2fs already running, skipping')
            return nil
          end
          "resize2fs '#{@dev.gsub(/'/, '')}'"
        when 'xfs'
          if command_running?('xfs_growfs')
            Chef::Log.warn('PartitionResize: xfs_growfs already running, skipping')
            return false
          end
          mountpoint = get_mountpoint
          if mountpoint.nil?
            Chef::Log.warn("PartitionResize: mountpoint not found for #{@dev}, required by XFS")
          else
            "xfs_growfs -d '#{mountpoint.gsub(/'/, '')}'"
          end
        else
          Chef::Log.warn("PartitionResize: unknown partition type: #{type}")
          return false
        end
        Chef::Log.info("PartitionResize: resizing #{@dev} partition...")
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
        Chef::Log.info("#{@dev}: physical size: #{physical.size}, logical size: #{logical.size}")
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

  end # Partition

end # PartitionResize
