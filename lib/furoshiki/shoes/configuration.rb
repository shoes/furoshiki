require 'pathname'
require 'yaml'

module Furoshiki
  module Shoes
    # Configuration for Shoes packagers.
    #
    # @example
    #   config_file = '/path/to/app.yaml'
    #   config = Shoes::Package::Configuration.load(config_file)
    #
    # If your configuration uses hashes, the keys will always be
    # symbols, even if you have created it with string keys. It's just
    # easier that way.
    #
    # This is a value object. If you need to modify your configuration
    # after initialization, dump it with #to_hash, make your changes,
    # and instantiate a new object.
    class Configuration
      # Convenience method for loading config from a file. Note that you
      # can pass four kinds of paths to the loader. Given the following
      # file structure:
      #  
      #   ├── a
      #   │   ├── app.yaml
      #   │   └── shoes-app-a.rb
      #   └── b
      #   └── shoes-app-b.rb
      #
      # To package an app that has an `app.yaml`, like `shoes-app-a.rb`,
      # you can call the loader with any of:
      #
      # - a/app.yaml
      # - a
      # - a/shoes-app-a.rb
      #
      # These will all find and use your configuration in `a/app.yaml`.
      # To package an app that does not have an `app.yaml`, like
      # `b/shoes-app-b.rb`, you must call the loader with the path of
      # the script itself. Note that without an `app.yaml`, you will
      # only bundle a single file, and your app will simply use the
      # Shoes app icon.
      #
      # @overload load(path)
      #   @param [String] path location of the app's 'app.yaml'
      # @overload load(path)
      #   @param [String] path location of the directory that
      #      contains the app's 'app.yaml'
      # @overload load(path)
      #   @param [String] path location of the app
      def self.load(path = 'app.yaml')
        pathname = Pathname.new(path)
        app_yaml = Pathname.new('app.yaml')

        dummy_file = Struct.new(:read)

        if pathname.basename == app_yaml
          file, dir = pathname, pathname.dirname
        elsif pathname.directory?
          file, dir = pathname.join(app_yaml), pathname
        elsif pathname.file? && pathname.parent.children.include?(pathname.parent.join app_yaml)
          file, dir = pathname.parent.join(app_yaml), pathname.parent
        else
          # Can't find any 'app.yaml', so assume we just want to wrap
          # this file. If it exists, load default options. If not, let
          # the filesystem raise an error.
          default_options = {
            run: pathname.basename.to_s,
            name: pathname.basename(pathname.extname).to_s.gsub(/\W/, '-')
          }.to_yaml
          options = pathname.exist? ? default_options : pathname
          file = dummy_file.new(options)
          dir = pathname.parent
        end
        config = YAML.load(file.read)
        config[:working_dir] = dir
        new(config)
      end

      # @param [Hash] config user options
      # @param [String] working_dir directory in which do packaging work
      def initialize(config = {})
        defaults = {
          name: 'Shoes App',
          version: '0.0.0',
          release: 'Rookie',
          run: nil,
          ignore: 'pkg',
          icons: {
            #osx: 'path/to/default/App.icns',
            #gtk: 'path/to/default/app.png',
            #win32: 'path/to/default/App.ico',
          },
          dmg: {
            ds_store: 'path/to/default/.DS_Store',
            background: 'path/to/default/background.png'
          },
          working_dir: Dir.pwd
        }

        # Overwrite defaults with supplied config
        @config = config.inject(defaults) { |c, (k, v)| set_symbol_key c, k, v }

        # Ensure that we always have what we need
        [:ignore, :gems].each { |k| @config[k] = Array(@config[k]) }
        @config[:gems] << 'shoes-core'
        @config[:gems] << 'shoes-swt'
        @config[:working_dir] = Pathname.new(@config[:working_dir])

        # Define reader for each key (#shortname defined below)
        metaclass = class << self; self; end
        @config.keys.reject {|k| k == :shortname}.each do |k|
          metaclass.send(:define_method, k) do
            @config[k]
          end
        end

        @errors = []
      end

      def shortname
        @config[:shortname] || @config[:name].downcase.gsub(/\W+/, '')
      end

      def to_hash
        @config
      end

      def validate
        unless @config[:run] && working_dir.join(@config[:run]).exist?
          add_missing_file_error(@config[:run], "Run file")
        end

        if @config[:icons][:osx] && !working_dir.join(@config[:icons][:osx]).exist?
          add_missing_file_error(@config[:icons][:osx], "OS X icon file")
        end
      end

      def valid?
        validate
        return errors.empty?
      end

      def errors
        @errors.dup
      end

      def error_message_list
        @errors.map {|m| "  - #{m}"}.join("\n")
      end

      def ==(other)
        super unless other.class == self.class && other.respond_to?(:to_hash)
        @config == other.to_hash &&
          working_dir == other.working_dir &&
          errors == other.errors
      end

      private
      # Ensure symbol keys, even in nested hashes
      #
      # @param [Hash] config the hash to set (key: value) on
      # @param [#to_sym] k the key
      # @param [Object] v the value
      # @return [Hash] an updated hash
      def set_symbol_key(config, k, v)
        if v.kind_of? Hash
          config[k.to_sym] = v.inject({}) { |hash, (k, v)| set_symbol_key(hash, k, v) }
        else
          config[k.to_sym] = v
        end
        config
      end

      def add_error(message)
        @errors << message
      end

      def add_missing_file_error(value, description)
        message = "#{description} configured as '#{value}', but couldn't find file at #{working_dir.join(value.to_s)}"
        add_error(message)
      end
    end
  end
end
