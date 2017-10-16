name             'wsus-client'
maintainer       'Criteo'
maintainer_email 'b.courtois@criteo.com'
license          'Apache-2.0'
description      'Configures wsus client'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.0'

supports         'windows'

chef_version     '>= 12.6' if respond_to?(:chef_version)
source_url       'https://github.com/criteo-cookbooks/wsus-client' if respond_to?(:source_url)
issues_url       'https://github.com/criteo-cookbooks/wsus-client/issues' if respond_to?(:issues_url)
