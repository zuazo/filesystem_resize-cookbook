Description
===========
[![Cookbook Version](https://img.shields.io/cookbook/v/filesystem_resize.svg?style=flat)](https://supermarket.getchef.com/cookbooks/filesystem_resize)
[![Dependency Status](http://img.shields.io/gemnasium/onddo/filesystem_resize-cookbook.svg?style=flat)](https://gemnasium.com/onddo/filesystem_resize-cookbook)
[![Code Climate](http://img.shields.io/codeclimate/github/onddo/filesystem_resize-cookbook.svg?style=flat)](https://codeclimate.com/github/onddo/filesystem_resize-cookbook)
[![Build Status](http://img.shields.io/travis/onddo/filesystem_resize-cookbook.svg?style=flat)](https://travis-ci.org/onddo/filesystem_resize-cookbook)

This Chef cookbook resizes the file system automatically when the underlying partition or disk increases its size.

It is mainly oriented to work with cloud or virtual servers where it is common to change the disk size.

Requirements
============

## Platform Requirements

This cookbook has been tested on the following platforms:

* Amazon (>= 2012.03)
* CentOS (>= 6.0)
* Debian (>= 7.0)
* Fedora
* RedHat
* Ubuntu (>= 12.04)

Please, [let us know](https://github.com/onddo/filesystem_resize-cookbook/issues/new?title=I%20have%20used%20it%20successfully%20on%20...) if you use it successfully on any other platform.

## Application Requirements

* Ruby 1.9.3 or higher.

The other required applications usually come with the operating system:

* `lsblk`, `findmnt` and `losetup`: included inside **[util-linux](http://en.wikipedia.org/wiki/Util-linux) (&ge; 2.19)** package.
* `pgrep`: included inside [procps-ng](http://sourceforge.net/projects/procps-ng/) package.
* `e2fsck`, `dumpe2fs` and `resize2fs` for *ext3* and *ext4*: included inside [e2fsprogs](http://e2fsprogs.sourceforge.net/) package.
* `xfs_info` and `xfs_growfs` for *XFS*: included inside [xfsprogs](http://oss.sgi.com/projects/xfs/) package.

Attributes
==========

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>node['filesystem_resize']['compiletime']</code></td>
    <td>Resize the file systems at compile time.</td>
    <td><code>false</code></td>
  </tr>
</table>

Recipes
=======

## filesystem_resize::default

Resize mounted file systems.

Usage
=====

## Including in a Cookbook Recipe

You can simply include it in a recipe:

```ruby
# in your recipe
include_recipe 'filesystem_resize'
```

Don't forget to include the `filesystem_resize` cookbook as a dependency in the metadata:

```ruby
# metadata.rb
depends 'filesystem_resize'
```

## Including in the Run List

Another alternative is to include it in your Run List:

```json
{
  "name": "app001.onddo.com",
  [...]
  "run_list": [
    [...]
    "recipe[filesystem_resize]"
  ]
}
```

Testing
=======

See [TESTING.md](https://github.com/onddo/filesystem_resize-cookbook/blob/master/TESTING.md).

Contributing
============

Please do not hesitate to [open an issue](https://github.com/onddo/filesystem_resize-cookbook/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/onddo/filesystem_resize-cookbook/blob/master/CONTRIBUTING.md).

TODO
====

See [TODO.md](https://github.com/onddo/filesystem_resize-cookbook/blob/master/TODO.md).

License and Author
==================

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@onddo.com>)
| **Copyright:**       | Copyright (c) 2014, Onddo Labs, SL. (www.onddo.com)
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
