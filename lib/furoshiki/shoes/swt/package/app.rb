require 'furoshiki/shoes/configuration'
require 'furoshiki/shoes/zip_directory'
require 'furoshiki/shoes/swt/package/jar'
require 'fileutils'
require 'plist'
require 'open-uri'

module Shoes
  module Swt
    module Package
      class App
        include FileUtils

        # @param [Shoes::Package::Configuration] config user configuration
        def initialize(config)
          @config = config
          home = ENV['FUROSHIKI_HOME'] || Dir.home
          @cache_dir = Pathname.new(home).join('.furoshiki', 'cache')
          @default_package_dir = working_dir.join('pkg')
          @package_dir = default_package_dir
          @default_template_path = cache_dir.join(template_filename)
          @template_path = default_template_path
          @tmp = @package_dir.join('tmp')
        end

        # @return [Pathname] default package directory: ./pkg
        attr_reader :default_package_dir

        # @return [Pathname] package directory
        attr_accessor :package_dir

        # @return [Pathname] default path to .app template
        attr_reader :default_template_path

        # @return [Pathname] path to .app template
        attr_accessor :template_path

        # @return [Pathname] cache directory
        attr_reader :cache_dir

        attr_reader :config

        attr_reader :tmp

        def package
          remove_tmp
          create_tmp
          cache_template
          extract_template
          inject_icon
          inject_config
          jar_path = ensure_jar_exists
          inject_jar jar_path
          move_to_package_dir tmp_app_path
          tweak_permissions
        rescue => e
          raise e
        ensure
          remove_tmp
        end

        def create_tmp
          tmp.mkpath
        end

        def remove_tmp
          tmp.rmtree if tmp.exist?
        end

        def cache_template
          cache_dir.mkpath unless cache_dir.exist?
          download_template unless template_path.exist?
        end

        def template_basename
          'shoes-app-template'
        end

        def template_extension
          '.zip'
        end

        def template_filename
          "#{template_basename}#{template_extension}"
        end

        def latest_template_version
          '0.0.1'
        end

        def download_template
          puts "downloading #{remote_template_url} to #{template_path}..."
          open(template_path, 'wb') do |template|
            template.print open(remote_template_url, 'rb').read
          end
        end

        def downloads_url
          "http://shoesrb.com/downloads"
        end

        def remote_template_url
          "#{downloads_url}/#{template_basename}-#{latest_template_version}#{template_extension}"
        end

        def move_to_package_dir(path)
          dest = package_dir.join(path.basename)
          dest.rmtree if dest.exist?
          mv path.to_s, dest
        end

        def ensure_jar_exists
          jar = Jar.new(@config)
          path = tmp.join(jar.filename)
          jar.package(tmp) unless File.exist?(path)
          path
        end

        # Injects JAR into APP. The JAR should be the only item in the
        # Contents/Java directory. If this directory contains more than one
        # JAR, the "first" one gets run, which may not be what we want.
        #
        # @param [Pathname, String] jar_path the location of the JAR to inject
        def inject_jar(jar_path)
          jar_dir = tmp_app_path.join('Contents/Java')
          jar_dir.rmtree
          jar_dir.mkdir
          cp Pathname.new(jar_path), jar_dir
        end

        def extract_template
          raise IOError, "Couldn't find app template at #{template_path}." unless template_path.exist?
          extracted_app = nil
          Zip::ZipFile.new(template_path).each do |entry|
            # Fragile hack
            extracted_app = template_path.join(entry.name) if Pathname.new(entry.name).extname == '.app'
            p = tmp.join(entry.name)
            p.dirname.mkpath
            entry.extract(p)
          end
          mv tmp.join(extracted_app.basename.to_s), tmp_app_path
        end

        def inject_config
          plist = tmp_app_path.join 'Contents/Info.plist'
          template = Plist.parse_xml(plist)
          template['CFBundleIdentifier'] = "com.hackety.shoes.#{config.shortname}"
          template['CFBundleDisplayName'] = config.name
          template['CFBundleName'] = config.name
          template['CFBundleVersion'] = config.version
          template['CFBundleIconFile'] = Pathname.new(config.icons[:osx]).basename.to_s if config.icons[:osx]
          File.open(plist, 'w') { |f| f.write template.to_plist }
        end

        def inject_icon
          if config.icons[:osx]
            icon_path = working_dir.join(config.icons[:osx])
            raise IOError, "Couldn't find app icon at #{icon_path}" unless icon_path.exist?
            resources_dir = tmp_app_path.join('Contents/Resources')
            cp icon_path, resources_dir.join(icon_path.basename)
          end
        end

        def tweak_permissions
          executable_path.chmod 0755
        end

        def app_name
          "#{config.name}.app"
        end

        def tmp_app_path
          tmp.join app_name
        end

        def app_path
          package_dir.join app_name
        end

        def executable_path
          app_path.join('Contents/MacOS/JavaAppLauncher')
        end

        def working_dir
          config.working_dir
        end
      end
    end
  end
end
