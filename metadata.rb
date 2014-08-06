name 'partition_resize'
maintainer 'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license 'Apache 2.0'
description <<-EOS
Resize partitions automatically when the underlying disk increases its size.
EOS
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

supports 'amazon', '>= 2012.03'
supports 'centos', '>= 6.0'
supports 'debian', '>= 7.0'
supports 'fedora'
supports 'redhat'
supports 'ubuntu', '>= 12.04'

recipe 'partition_resize::default', 'Resize mounted partitions.'

attribute 'partition_resize/compiletime',
          display_name: 'partition resize at compile time',
          description: 'Resize the partitions at compile time.',
          choice: %w(true false),
          type: 'string',
          required: 'optional',
          default: 'false'
