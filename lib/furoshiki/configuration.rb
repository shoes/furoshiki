require 'pathname'
require 'yaml'
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
      return @validator unless @validator.nil?
      return nil if @config[:validator].nil?
      @validator = @config[:validator].new(self)
    end

    def warbler_extensions
      return @warbler_extensions unless @warbler_extensions.nil?
      return nil if @config[:warbler_extensions].nil?
      @warbler_extensions = @config[:warbler_extensions].new(self)
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
      Warbler::Config.new do |config|
        Dir.chdir working_dir do
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
    end
  end
end