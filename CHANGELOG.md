Wsus-client CHANGELOG
==============
This file is used to list changes made in each version of the wsus-client cookbook.

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
