# encoding: UTF-8
#
# Cookbook Name:: filesystem_resize-test
# Recipe:: default
#
# Copyright 2014-2015, Onddo Labs, Sl.
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

node['filesystem_resize-test']['packages']['xfs'].each do |pkg|
  (package pkg).run_action(:install)
end

require 'chef/mixin/shell_out'
Chef::Recipe.send(:include, FilesystemResizeCookbook)

def block_device_path(type)
  ::File.join(
    node['filesystem_resize-test']['directory'],
    "#{type}_disk.img"
  )
end

def mount_point_path(type)
  ::File.join(
    node['filesystem_resize-test']['directory'],
    "#{type}_disk"
  )
end

node['filesystem_resize-test']['types_to_test'].each do |type|
  block_device = block_device_path(type)
  mount_point = mount_point_path(type)
  size = 100 # MB
  mkfs_args =
    case type
    # Force mke2fs to create a filesystem, # even if the
    # specified device is not a fs on a # block
    # special device. (only for ext2-4)
    when /^ext/ then %w(-F)
    # Force overwrite when an existing filesystem is
    # detected  on the device.
    else
      %w(-f)
  end

  ruby_block "loop_fs_create(#{type})" do
    block do
      # cleaning
      Shell.run("umount #{mount_point} 2> /dev/null || true")
      Shell.run("rm -f #{block_device}")

      Shell.run("dd if=/dev/zero of=#{block_device} bs=1M count=#{size}")

      Shell.run("mkfs.#{type} #{mkfs_args.join(' ')} #{block_device}")
      Shell.run("e2fsck -f -y #{block_device}") if type =~ /^ext/

      Shell.run(
        "dd oflag=append conv=notrunc if=/dev/zero of=#{block_device} "\
        "bs=1M count=#{size}"
      )
      Shell.run("mkdir -p #{mount_point}")
      Shell.run("mount -o loop #{block_device} #{mount_point}")

      physical = FilesystemDisk.new(block_device)
      logical = Filesystem.new(block_device)
      if physical.size == logical.size
        fail "Filesystem size equal: #{block_device} (#{physical.size})"
      end
    end
  end
end

include_recipe 'filesystem_resize'

node['filesystem_resize-test']['types_to_test'].each do |type|
  block_device = block_device_path(type)
  mount_point = mount_point_path(type)

  ruby_block "loop_fs_destroy(#{type})" do
    block do
      physical = FilesystemDisk.new(block_device)
      logical = Filesystem.new(block_device)
      unless physical.size == logical.size
        fail "Filesystem not resized: #{block_device} "\
          "(#{physical.size} == #{logical.size})"
      end

      # cleaning
      Shell.run("umount #{mount_point}")
      Shell.run("rmdir #{mount_point}")
      Shell.run("rm #{block_device}")
    end
  end
end
