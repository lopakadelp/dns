# -*- mode: ruby -*-
# vi: set ft=ruby :
source 'https://rubygems.org'

gem 'rake'
gem 'chefspec'
gem 'berkshelf'
gem 'librarian-chef'
gem 'emeril', group: :release

group :development do
  gem 'guard-rspec'
end

group :style do
  gem 'inch'
end

group :test do
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'kitchen-docker'
  gem 'fog', '~> 1.20.0'
  gem 'rest_client', '~> 1.7.3'
end
