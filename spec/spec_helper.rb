require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  require 'rspec/core'
  require 'rspec/mocks'
  RSpec::Mocks::setup(Object)

  require 'active_support/all'
  require 'database_cleaner'
  require File.expand_path("../support/rails", __FILE__)
  require 'pry'

  Dir[File.expand_path('../support/*.rb', __FILE__)].each{|f| require f }

  RSpec.configure do |config|
    config.mock_with :rspec

    # Exclude broken tests
    config.filter_run_excluding :broken => true
    config.filter_run :focus => true
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true

    config.before(:suite) do
      CreateSchema.suppress_messages{ CreateSchema.migrate(:up) }
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
    
    config.after(:suite) do
      FileUtils.rm_rf(File.expand_path('../test.sqlite3', __FILE__))
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

end
