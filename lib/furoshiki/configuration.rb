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
    REMOTE_JAR_APP_TEMPLATE_URL = 'https://s3.amazonaws.com/net.wasnotrice.shoes/wrappers/shoes-app-template-0.0.1.zip'

    include Util

    # @param [Hash] config user options
    # @param [String] working_dir directory in which to do packaging work
    def initialize(config = {})
      defaults = {
        name: 'Ruby App',
        version: '0.0.0',
        release: 'Rookie',
        ignore: 'pkg',
        icons: {
          #osx: 'path/to/default/App.icns',
          #gtk: 'path/to/default/app.png',
          #win32: 'path/to/default/App.ico',
        },
        working_dir: Dir.pwd,
      }

      # Overwrite defaults with supplied config
      @config = deep_symbolize_keys(config, defaults)

      # Ensure these keys have workable values
      [:ignore, :gems].each { |k| @config[k] = Array(@config[k]) }
      @config[:working_dir] = Pathname.new(@config[:working_dir])

      # Define reader for each key (except those already defined explicitly)
      metaclass = class << self; self; end
      @config.keys.reject {|k| self.respond_to?(k) }.each do |k|
        metaclass.send(:define_method, k) do
          @config[k]
        end
      end
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
          specs = self.gems.map { |g| Gem::Specification.find_by_name(g) }
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
      @warbler_extensions_class ||= @config.fetch(:warbler_extensions) { Furoshiki::WarblerExtensions }
    end

    def validator_class
      @validator_class ||= @config.fetch(:validator) { Furoshiki::Validator }
    end
  end
end
