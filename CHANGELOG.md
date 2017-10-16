Wsus-client CHANGELOG
==============
This file is used to list changes made in each version of the wsus-client cookbook.

2.0.0 (2017-10-17)
------------------
- [PR 35](https://github.com/criteo-cookbooks/wsus-client/pull/35) - **Breaking:** Changed attributes controlling the `wsus-client::update` recipe
- [PR 34](https://github.com/criteo-cookbooks/wsus-client/pull/34) - Add progress tracking support to `wsus_client_update` actions
- [PR 33](https://github.com/criteo-cookbooks/wsus-client/pull/33) - Rewrite `wsus_client_update` as a Custom resource
- Configure travis to test using ruby `2.3.0`

1.2.1 (2016-05-05)
------------------
- Configure travis to test using ruby 2.1.0
- [PR 21](https://github.com/criteo-cookbooks/wsus-client/pull/21) - Support chef-client running on ruby 64bits (chef >= 12.8.1)

1.2.0 (2015-08-07)
------------------
- [PR 17](https://github.com/criteo-cookbooks/wsus-client/pull/14) - Speed up LWRP by searching updates only once
- [PR 15](https://github.com/criteo-cookbooks/wsus-client/pull/15) - Log more information before downloading and installing updates

1.1.0 (2015-06-18)
------------------
- Expose new wsus_client_update LWRP to synchronously download or install updates
- [PR 9](https://github.com/criteo-cookbooks/wsus-client/pull/9) - Fix the client-side detection
- [PR 11](https://github.com/criteo-cookbooks/wsus-client/pull/11) - Allow string values for automatic_update_behavior and schedule_install_day
- Add chefspec and rspec tests!

1.0.1 (2015-06-03)
------------------
- Fix README.md for chef supermarket

1.0.0 (2015-06-03)
------------------
- Workaround foodcritic false positive
- Rename attribute `disable_windows_update_acces` to `disable_windows_update_access`
- Explicitly set attribute value of `detection_frequency` to 22 hours
- Force WU detection on configuration change
- Complete README.md

0.1.3 (2015-01-29)
------------------
- Fail chef run on guard failure
- Configure basic rake tasks and travis build

0.1.2 (2014-09-15)
------------------
-  Fix update script guard condition

0.1.1 (2014-09-15)
------------------
- Add windows supports in metadata

0.1.0 (2014-08-27)
------------------
- Initial release of wsus-client
- Client recipes do nothing on non-windows platform
- Add client recipes that configures automatic updates and initiates download and install
