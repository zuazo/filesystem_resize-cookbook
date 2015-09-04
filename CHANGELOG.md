CHANGELOG for filesystem_resize
===============================

This file is used to list changes made in each version of the `filesystem_resize` cookbook.

## v0.3.0 (2015-09-04)

* Update chef links to use *chef.io* domain.
* Update contact information and links after migration.
* Update RuboCop to version `0.33.0`.
* metadata: Add `source_url` and `issues_url` links.

* Documentation:
 * README: Improve description.

* Testing:
 * Update Gemfile dependencies and Kitchen platforms.
 * Move ChefSpec tests to *test/unit*.
 * Use `ChefSpec::SoloRunner` to make unit tests faster.
 * Integrate tests with `should_not` gem.

## v0.2.0 (2015-01-23)

* Fix always resize bug.
* Add `filesystem_resize` and `filesystem_resize_all` resources, big refactor.
* Update Gemfile deps, update RuboCop.

## v0.1.0 (2014-08-11)

* Initial release of `filesystem_resize`.
