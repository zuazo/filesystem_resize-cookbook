#
# Cookbook Name:: partition_resize-test
# Recipe:: default
#
# Copyright 2014, Onddo Labs, Sl.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node['partition_resize']['packages']['xfs'].each do |pkg|
  (package pkg).run_action(:install)
end

require 'chef/mixin/shell_out'
Chef::Recipe.send(:include, PartitionResize)

node['partition_resize-test']['types_to_test'].each do |type|
  block_device = "/tmp/#{type}_disk.img"
  mount_point = "/tmp/#{type}_disk"
  size = 100 # MB
  mkfs_args = case type
    when /^ext/
      # Force mke2fs to create a filesystem, # even if the
      # specified device is not a partition on a # block
      # special device. (only for ext2-4)
      [ '-F' ]
    else
      #  Force overwrite when an existing filesystem is
      # detected  on the device.
      [ '-f' ]
  end

  ruby_block "loop_partition_create(#{type})" do
    block do
      # cleaning
      Shell.run("umount #{mount_point} 2> /dev/null || true")
      Shell.run("rm -f #{block_device}")

      Shell.run("dd if=/dev/zero of=#{block_device} bs=1M count=#{size}")

      Shell.run("mkfs.#{type} #{mkfs_args.join(' ')} #{block_device}")

      Shell.run("dd oflag=append conv=notrunc if=/dev/zero of=#{block_device} bs=1M count=#{size}")
      Shell.run("mkdir -p #{mount_point}")
      Shell.run("mount -o loop #{block_device} #{mount_point}")

      physical = Partition::Physical.new(block_device)
      logical = Partition::Logical.new(block_device)
      raise "Partition size equal: #{block_device} (#{physical.size})" if physical.size == logical.size
    end
  end
end

include_recipe 'partition_resize'

node['partition_resize-test']['types_to_test'].each do |type|
  block_device = "/tmp/#{type}_disk.img"
  mount_point = "/tmp/#{type}_disk"

  ruby_block "loop_partition_destroy(#{type})" do
    block do
      physical = Partition::Physical.new(block_device)
      logical = Partition::Logical.new(block_device)
      raise "Partition not resized: #{block_device} (#{physical.size} == #{logical.size})" unless physical.size == logical.size

      # cleaning
      Shell.run("umount #{mount_point}")
      Shell.run("rmdir #{mount_point}")
      Shell.run("rm #{block_device}")
    end
  end
end
