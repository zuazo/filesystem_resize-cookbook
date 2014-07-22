require 'chef/mixin/shell_out'

require 'forwardable'

module PartitionResize
  class Partition
    # Partition type abstract base class
    class Base
      extend Forwardable
      extend Chef::Mixin::ShellOut

      attr_reader :device
      attr_reader :loop_device

      def initialize(dev)
        from_loop = Partition.from_loop(dev)
        if !from_loop.nil?
          @device = from_loop
          @loop_device = dev
        else
          @device = dev
          @loop_device = Partition.to_loop(dev)
        end
      end

      def self.shell_out(*args)
        cmd = super(args)
        Chef::Log.debug("#shell_out: #{args[0]}")
        unless cmd.status.success?
          Chef::Log.info("#shell_out #{args[0]} (STDOUT): #{cmd.stdout}")
          Chef::Log.info("#shell_out #{args[0]} (STDERR): #{cmd.stderr}")
        end
        cmd
      end
      def_delegator self, :shell_out

      def block_device
        @loop_device || @device
      end

      def loop?
        !@loop_device.nil?
      end

      def to_s
        loop? ? "#{device} (#{loop_device})" : device
      end
    end
  end
end
