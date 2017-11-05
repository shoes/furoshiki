require 'furoshiki/base_app'
require 'plist'

module Furoshiki
  class MacApp < BaseApp
    private

    def app_name
      "#{config.name}.app"
    end

    def archive_name
      "#{config.name}-mac.tar.gz"
    end

    def template_basename
      'mac-app-template'
    end

    def latest_template_version
      '0.0.4'
    end

    def remote_template_url
      "https://github.com/shoes/mac-app-templates/releases/download/v#{latest_template_version}/mac-app-template-#{latest_template_version}.zip"
    end

    def inject_jar
      jar_path = ensure_jar_exists
      cp Pathname.new(jar_path), File.join(tmp_app_path, "Contents", "Java", "app.jar")
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

    def executable_path
      app_path.join('Contents/MacOS/app')
    end

    def tmp_app_path
      tmp.join "#{template_basename}"
    end
  end
end
