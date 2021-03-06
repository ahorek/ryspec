require_relative 'init_rails'

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

RYSPEC_PERSISTANT_TABLES = ['settings', 'easy_settings', 'trackers', 'enumerations', 'issue_statuses', 'rys_features']
RESOLUTION = ENV['RESOLUTION'].to_s.split(',').presence || [1920, 1080]
JS_DRIVER = ENV['JS_DRIVER'].present? ? ENV['JS_DRIVER'].downcase.to_sym : :poltergeist

require_relative 'init_factory_bot'
require_relative 'init_capybara'
require_relative 'init_support'

RSpec.configure do |config|

  config.include Ryspec::Test::Rys
  config.include Ryspec::Test::Users
  config.include Ryspec::Test::Settings

  # Enables zero monkey patching mode for RSpec.
  config.disable_monkey_patching!

  # # Sets the expectation framework module(s) to be included in each example group.
  # config.expect_with :rspec do |expectations|
  #   expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  # endS

  # # Sets the mock framework adapter module.
  # config.mock_with :rspec do |mocks|
  #   mocks.verify_partial_doubles = true
  # end

  # # Configures how RSpec treats metadata passed as part of a shared example group definition.
  # config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    # DatabaseCleaner.clean_with(:truncation, except: RYSPEC_PERSISTANT_TABLES)
    DatabaseCleaner.clean_with(:deletion, except: RYSPEC_PERSISTANT_TABLES)
  end

  config.before(:each) do
    # DatabaseCleaner.strategy = :truncation, { except: RYSPEC_PERSISTANT_TABLES }
    DatabaseCleaner.strategy = :deletion, { except: RYSPEC_PERSISTANT_TABLES }
  end

  config.before(:each, transaction_strategy: true) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each, :logged) do |example|
    logged_user case example.metadata[:logged]
                when :admin
                  FactoryBot.create(:user, :admin)
                when :user, true
                  FactoryBot.create(:user)
                else
                  User.anonymous
                end
  end

end
