# encoding: UTF-8

default['filesystem_resize-test']['packages']['xfs'] = %w(xfsprogs)

default['filesystem_resize-test']['directory'] = '/root'
if node['platform'] == 'centos' && node['platform_version'].to_i == 5
  default['filesystem_resize-test']['types_to_test'] = %w(ext3 xfs)
else
  default['filesystem_resize-test']['types_to_test'] = %w(ext3 ext4 xfs)
end
