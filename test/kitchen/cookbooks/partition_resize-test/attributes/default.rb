default['partition_resize-test']['directory'] = '/root'
if node['platform'] == 'centos' && node['platform_version'].to_i == 5
  default['partition_resize-test']['types_to_test'] = %w(ext3 xfs)
else
  default['partition_resize-test']['types_to_test'] = %w(ext3 ext4 xfs)
end
