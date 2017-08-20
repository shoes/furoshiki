require 'rspec'
require 'rspec/its'
require 'pry'
require 'pathname'

# Packaging caches files in $HOME/.furoshiki/cache by default.
# For testing, we override $HOME using $FUROSHIKI_HOME
FUROSHIKI_SPEC_DIR = Pathname.new(__FILE__).dirname.expand_path.to_s
ENV['FUROSHIKI_HOME'] = FUROSHIKI_SPEC_DIR

spec_root = File.dirname(__FILE__)
Dir["#{spec_root}/support/**/*.rb"].each { |f| require f }
