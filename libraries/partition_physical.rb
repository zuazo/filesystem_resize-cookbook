module PartitionResize
  class Partition
    # This class represent the real disk partition from the physical point of
    # view. If the physical partition is resized will be reflected here
    class Physical < Base
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
          if line =~ /^#{Regexp.escape(dev)}\s([0-9]+)/
            Regexp.last_match[1].to_i
          else
            nil
          end
        end
      end

      def self.list
        lsblk_list.split("\n").each_with_object([]) do |name, partitions|
          dev = name =~ /^\// ? name : "/dev/#{name}"
          partitions << dev
          partitions.delete(Regexp.last_match[1]) if dev =~ /^([^0-9]+)[0-9]+$/
        end
      end
    end
  end
end
