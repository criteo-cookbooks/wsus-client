source 'https://rubygems.org'

gem 'berkshelf'
gem 'chefspec',   '>= 4.2'
gem 'fauxhai',    '>= 2.2'
gem 'foodcritic', '>= 4.0'
gem 'rake'

if RUBY_VERSION < '2.0'
  gem 'chef', '< 12.0'
  gem 'ohai', '< 8.0'
end

group :ec2 do
  gem 'test-kitchen'
  gem 'chef-zero-scheduled-task'
  gem 'kitchen-ec2', :git => 'https://github.com/criteo-forks/kitchen-ec2.git', :branch => 'criteo'
  gem 'winrm',      '~> 1.6'
  gem 'winrm-fs',   '~> 0.3'
end
