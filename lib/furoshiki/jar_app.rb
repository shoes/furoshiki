require 'furoshiki/base_app'
require 'plist'

module Furoshiki
  class JarApp < BaseApp
    private

    def app_name
      "#{config.name}.app"
    end

    def template_basename
      'shoes-app-template'
    end

    def latest_template_version
      '0.0.2'
    end

    def remote_template_url
      config.template_urls.fetch(:jar_app)
    end

    # Injects JAR into APP. The JAR should be the only item in the
    # Contents/Java directory. If this directory contains more than one
    # JAR, the "first" one gets run, which may not be what we want.
    def inject_jar
      jar_path = ensure_jar_exists

      jar_dir = tmp_app_path.join('Contents/Java')
      jar_dir.rmtree if File.exist?(jar_dir)
      jar_dir.mkdir
      cp Pathname.new(jar_path), jar_dir
    end

    # TODO: Extract to base after figuring the .app-finding move
    def extract_template
      raise IOError, "Couldn't find app template at #{template_path}." unless template_path.size?
      extracted_app = nil

      ::Zip::File.open(template_path) do |zip_file|
        zip_file.each do |entry|
          extracted_app = template_path.join(entry.name) if Pathname.new(entry.name).extname == '.app'
          p = tmp.join(entry.name)
          p.dirname.mkpath
          entry.extract(p)
        end
      end
      mv tmp.join(extracted_app.basename.to_s), tmp_app_path
    end

    def inject_files
      inject_icon
      inject_config
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

    def after_moved
      executable_path.chmod 0755
    end

    def executable_path
      app_path.join('Contents/MacOS/JavaAppLauncher')
    end
  end
end
