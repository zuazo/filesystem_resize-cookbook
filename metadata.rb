# encoding: UTF-8

name 'filesystem_resize'
maintainer 'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license 'Apache 2.0'
description <<-EOS
Resize the file system automatically when the underlying partition or disk
increases its size.
EOS
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

supports 'amazon', '>= 2012.03'
supports 'centos', '>= 6.0'
supports 'debian', '>= 7.0'
supports 'fedora'
supports 'redhat'
supports 'ubuntu', '>= 12.04'

recipe 'filesystem_resize::default', 'Resize mounted file systems.'

attribute 'filesystem_resize/compiletime',
          display_name: 'fs resize at compile time',
          description: 'Resize the file sistems at compile time.',
          choice: %w(true false),
          type: 'string',
          required: 'optional',
          default: 'false'
