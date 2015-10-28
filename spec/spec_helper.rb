require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault/test_fixtures'
ChefSpec::Coverage.start! if ENV['COVERAGE']

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  config.file_cache_path = '/var/chef/cache'

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  else
    config.default_formatter = 'progress'
  end

  config.order = :random
  Kernel.srand config.seed
end
