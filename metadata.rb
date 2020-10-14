name 'maintenance_window'
maintainer 'James Massardo'
maintainer_email 'james@dxrf.com'
license 'Apache-2.0'
description 'Provides helper method to declare a maintenance window to control resource converge timing'
version '0.1.0'
chef_version '>= 13'

%w( aix amazon centos fedora freebsd debian oracle mac_os_x redhat suse opensuse opensuseleap ubuntu windows zlinux ).each do |os|
  supports os
end

issues_url 'https://github.com/jmassardo/maintenance_window/issues'
source_url 'https://github.com/jmassardo/maintenance_window'
