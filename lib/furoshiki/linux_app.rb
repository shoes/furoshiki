require 'furoshiki/base_app'

module Furoshiki
  class LinuxApp < BaseApp
    private

    def app_name
      "#{config.name}-linux"
    end

    def archive_name
      "#{app_name}.tar.gz"
    end

    def template_basename
      'linux-app-template'
    end

    def latest_template_version
      '0.0.1'
    end

    def remote_template_url
      "https://github.com/shoes/linux-app-templates/releases/download/v#{latest_template_version}/linux-app-template-#{latest_template_version}.zip"
    end

    def inject_jar
      jar_path = ensure_jar_exists
      cp Pathname.new(jar_path), File.join(tmp_app_path, "app.jar")
    end

    def after_built
      mv File.join(tmp_app_path, "app"), File.join(tmp_app_path, config.name)
    end

    def executable_path
      app_path.join(config.name)
    end

    def tmp_app_path
      tmp.join "#{template_basename}"
    end
  end
end
