# # encoding: utf-8

# Inspec test for recipe maintenance_window::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe file('/tmp/window') do
  it { should exist }
end
