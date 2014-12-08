require 'furoshiki/shoes/configuration'
require 'warbler'
require 'warbler/traits/shoes'

module Furoshiki
  class Jar
    # @param [Furoshiki::Shoes::Configuration] config user configuration
    def initialize(config)
      @furoshiki_config = config

      unless config.valid?
        raise Furoshiki::ConfigurationError, "Invalid configuration.\n#{config.error_message_list}"
      end

      @config = @furoshiki_config.to_warbler_config
    end

    def package(dir = default_dir)
      Dir.chdir working_dir do
        jar = Warbler::Jar.new
        jar.apply @config
        package_dir = dir.relative_path_from(working_dir)
        package_dir.mkpath
        path = package_dir.join(filename).to_s
        jar.create path
        File.expand_path path
      end
    end

    def default_dir
      working_dir.join 'pkg'
    end

    def filename
      "#{@config.jar_name}.#{@config.jar_extension}"
    end

    def working_dir
      @furoshiki_config.working_dir
    end
  end
end
