# Chef Maintenance Window Cookbook

This cookbook provides a helper method that allows one to define a timed maintenance window to control when resources converge.

## Requirements

### Platforms

- AIX 6+
- Clear Linux
- Debian
- Fedora
- FreeBSD
- Mac OS X
- openSUSE
- SLES 12+
- RHEL
- Solaris 10+
- Ubuntu
- Windows 2008 R2+

### Chef

- Chef 13.0+

See [USAGE](#usage).

## Attributes

The following attributes control how and when a maintenance window is created.

- `# default['maint_window']['interval']` - Options: Daily, Weekly, Monthly, Offset
- `# default['maint_window']['start_time']` - Format: HH:MM, leading zero required, 24hr format
- `# default['maint_window']['duration']` - Duration in hours
- `# default['maint_window']['week_day']` - # Day of week by name
- `# default['maint_window']['day']` - Options: 1-31 - Integer of day of the month
- `# default['maint_window']['offset']` - Options: 1-31 - Integer of days after Patch Tuesday

## Window Types

This cookbook provides 4 types of maintenance windows.

- Daily: Uses the `start_time` and `duration` attributes. Allows for activities to run at the same time each day.
- Weekly: Uses the `start_time`, `duration`, and `week_day` attributes. Allows for activities to run on the same day of the week, each week.
- Monthly: Uses the `start_time`, `duration`, and `day` attributes. Allows for activities to run on a certain day each month.
- Offset: Uses the `start_time`, `duration`, and `offset` attributes. Allows for activities to happen a number of days after Patch Tuesday. Helpful for Windows Patching as MS releases updates on the Second Tuesday of every month.

## Usage

``` ruby
file '/tmp/window' do
  content 'hi!'
  action :create
  only_if {in_maint_window}
end
```

## Examples

Daily 4 hour window at 2 AM for applying updates

``` ruby
# attributes/default.rb

default['maint_window']['interval'] = 'daily'
default['maint_window']['start_time'] = '02:00'
default['maint_window']['duration'] = 4

# recipes/default.rb
execute 'Install updates' do
  command 'apt-get -y update && apt-get -y upgrade'
  action :run
  only_if {in_maint_window}
end
```

Weekly 6 hour window at 1 AM on Saturday mornings

``` ruby
# attributes/default.rb

default['maint_window']['interval'] = 'weekly'
default['maint_window']['start_time'] = '01:00'
default['maint_window']['duration'] = 6
default['maint_window']['week_day'] = 'Saturday'

# recipes/default.rb
file '/etc/my-app/app.conf' do
  content 'setting: 1'
  action :create
  only_if {in_maint_window}
end
```

Monthly 2 hour window on the 19th at 10 PM

``` ruby
# attributes/default.rb

default['maint_window']['interval'] = 'monthly'
default['maint_window']['start_time'] = '22:00'
default['maint_window']['duration'] = 2
default['maint_window']['day'] = 19

# recipes/default.rb
execute 'Install updates' do
  command 'apt-get -y update && apt-get -y upgrade'
  action :run
  only_if {in_maint_window}
end
```

Offset 3 hour window for the first Saturday after Patch Tuesday starting at 3 AM

``` ruby
# attributes/default.rb

default['maint_window']['interval'] = 'offset'
default['maint_window']['start_time'] = '03:00'
default['maint_window']['duration'] = 3
default['maint_window']['offset'] = 4

# recipes/default.rb
wsus_client_update 'WSUS updates' do
  handle_reboot true
end
```