MINIMUM_COVERAGE = 73.95

unless ENV['COVERAGE'] == 'off'
  require 'simplecov'
  require 'simplecov-rcov'
  require 'coveralls'
  Coveralls.wear!

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::RcovFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/vendor/'
    add_filter '/spec/'
    add_group 'lib', 'lib'
  end
  SimpleCov.at_exit do
    SimpleCov.result.format!
    percent = SimpleCov.result.covered_percent
    unless percent >= MINIMUM_COVERAGE
      puts "Coverage must be above #{MINIMUM_COVERAGE}%. It is #{"%.2f" % percent}%"
      Kernel.exit(1)
    end
  end
end
