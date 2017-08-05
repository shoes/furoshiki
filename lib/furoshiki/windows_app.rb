require 'furoshiki/base_app'
require 'zip'

module Furoshiki
  class WindowsApp < BaseApp
    private

    def app_name
      "#{config.name}-windows"
    end

    def archive_name
      "#{app_name}.zip"
    end

    def template_basename
      'windows-app-template'
    end

    def latest_template_version
      '0.0.1'
    end

    def remote_template_url
      "https://github.com/shoes/windows-app-templates/releases/download/v#{latest_template_version}/windows-app-template-#{latest_template_version}.zip"
    end

    def inject_jar
      jar_path = ensure_jar_exists
      cp Pathname.new(jar_path), File.join(tmp_app_path, "app.jar")
    end

    def after_built
      mv File.join(tmp_app_path, "app.bat"), File.join(tmp_app_path, "#{config.name}.bat")
    end

    def tmp_app_path
      tmp.join "#{template_basename}"
    end

    def create_archive(source_path)
      dest = package_dir.join(archive_name)
      rm_f dest
      ::Zip::File.open(dest, ::Zip::File::CREATE) do |zipfile|
        tmp_files.each do |source_item|
          dest_item = source_item.sub(source_path.to_s, app_name)
          zipfile.add(dest_item, source_item)
        end
      end
    end
  end
end
