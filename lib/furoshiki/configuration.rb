require 'pathname'
require 'yaml'
require 'furoshiki/validator'
require 'furoshiki/warbler_extensions'
require 'furoshiki/util'

module Furoshiki
  # Configuration for Furoshiki packagers.
  #
  # If your configuration uses hashes, the keys will always be
  # symbols, even if you have created it with string keys. It's just
  # easier that way.
  #
  # This is a value object. If you need to modify your configuration
  # after initialization, dump it with #to_hash, make your changes,
  # and instantiate a new object.
  class Configuration
    JAR_APP_TEMPLATE_URL = 'https://s3.amazonaws.com/net.wasnotrice.shoes/wrappers/shoes-app-template-0.0.2.zip'

    include Util

    # @param [Hash] config user options
    # @param [String] working_dir directory in which to do packaging work
    def initialize(config = {})
      merge_config config
      sanitize_config
      define_readers
    end

    def shortname
      @config[:shortname] || name.downcase.gsub(/\W+/, '')
    end

    def validator
      @validator ||= validator_class.new(self)
    end

    def warbler_extensions
      @warbler_extensions ||= warbler_extensions_class.new(self)
    end

    def to_hash
      @config
    end

    def valid?
      validator.valid?
    end

    def validate
      return unless validator.respond_to? :reset_and_validate
      validator.reset_and_validate
    end

    def error_message_list
      validator.error_message_list
    end

    def ==(other)
      super unless other.class == self.class && other.respond_to?(:to_hash)
      @config == other.to_hash && working_dir == other.working_dir
    end

    def to_warbler_config
      warbler_config = nil
      Dir.chdir working_dir do
        warbler_config = Warbler::Config.new do |config|
          config.jar_name = self.shortname
          specs = self.gems.map do |gem|
            # This is rather a hack as  Gem::Specification.find_by_name(gem)
            # seems to break Travis.
            # See: https://github.com/shoes/shoes4/pull/989#issuecomment-68170746
            Gem::Specification.find_all_by_name(gem).first
          end
          dependencies = specs.map { |s| s.runtime_dependencies }.flatten
          (specs + dependencies).uniq.each { |g| config.gems << g }
          ignore = self.ignore.map do |f|
            path = f.to_s
            children = Dir.glob("#{path}/**/*") if File.directory?(path)
            [path, *children]
          end.flatten
          config.excludes.add FileList.new(ignore.flatten).pathmap(config.pathmaps.application.first)
          config.gem_excludes += [/^samples/, /^examples/, /^test/, /^spec/]

          warbler_extensions.customize(config) if warbler_extensions.respond_to? :customize
        end
      end
      warbler_config
    end

    private
    def warbler_extensions_class
      @warbler_extensions_class ||= @config.fetch(:warbler_extensions)
    end

    def validator_class
      @validator_class ||= @config.fetch(:validator)
    end

    # Overwrite defaults with supplied config
    def merge_config(config)
      defaults = {
        name: 'Ruby App',
        version: '0.0.0',
        release: 'Rookie',
        ignore: 'pkg',
        # TODO: Establish these default icons and paths. These would be
        # default icons for generic Ruby apps.
        icons: {
          #osx: 'path/to/default/App.icns',
          #gtk: 'path/to/default/app.png',
          #win32: 'path/to/default/App.ico',
        },
        template_urls: {
          jar_app: JAR_APP_TEMPLATE_URL,
        },
        validator: Furoshiki::Validator,
        warbler_extensions: Furoshiki::WarblerExtensions,
        working_dir: Dir.pwd,
      }

      @config = merge_with_symbolized_keys(defaults, config)
    end

    # Ensure these keys have workable values
    def sanitize_config
      [:ignore, :gems].each { |k| @config[k] = Array(@config[k]) }
      @config[:working_dir] = Pathname.new(@config[:working_dir])
    end

    # Define reader for each top-level config key (except those already defined
    # explicitly)
    def define_readers
      metaclass = class << self; self; end
      @config.keys.reject {|k| self.respond_to?(k) }.each do |k|
        metaclass.send(:define_method, k) do
          @config[k]
        end
      end
    end
  end
end
