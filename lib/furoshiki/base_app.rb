require 'furoshiki/configuration'
require 'furoshiki/exceptions'
require 'furoshiki/jar'
require 'fileutils'
require 'open-uri'
require 'net/http'
require 'rubygems/package'
require 'rubygems/package/tar_writer'

module Furoshiki
  class BaseApp
    include FileUtils

    # @param [Furoshiki::Shoes::Configuration] config user configuration
    def initialize(config)
      @config = config

      unless config.valid?
        raise Furoshiki::ConfigurationError, "Invalid configuration.\n#{config.error_message_list}"
      end

      home = ENV['FUROSHIKI_HOME'] || Dir.home
      @cache_dir = Pathname.new(home).join('.furoshiki', 'cache')
      @default_package_dir = working_dir.join('pkg')
      @package_dir = default_package_dir
      @default_template_path = cache_dir.join(template_filename)
      @template_path = default_template_path
      @archive_path = @package_dir.join(archive_name)
      @tmp = @package_dir.join('tmp')
    end

    def package
      remove_tmp
      create_tmp

      cache_template
      extract_template

      inject_files
      inject_jar
      after_built

      create_archive tmp_app_path
    ensure
      remove_tmp
    end

    # @return [Pathname] default package directory: ./pkg
    attr_reader :default_package_dir

    # @return [Pathname] package directory
    attr_accessor :package_dir

    # @return [Pathname] default path to app template
    attr_reader :default_template_path

    # @return [Pathname] path to resulting archive file
    attr_accessor :archive_path

    # @return [Pathname] path to app template
    attr_accessor :template_path

    # @return [Pathname] cache directory
    attr_reader :cache_dir

    # @param [Furoshiki::Shoes::Configuration] config user configuration
    attr_reader :config

    # @return [Pathname] app building temp directory
    attr_reader :tmp

    private

    # Locations and names
    def app_name
      raise NotImplementedError
    end

    def archive_name
      raise NotImplementedError
    end

    def template_basename
      raise NotImplementedError
    end

    def latest_template_version
      raise NotImplementedError
    end

    def remote_template_url
      raise NotImplementedError
    end

    def template_extension
      '.zip'
    end

    def template_filename
      "#{template_basename}-#{latest_template_version}#{template_extension}"
    end

    def tmp_app_path
      tmp.join app_name
    end

    def tmp_files
      Dir[tmp_app_path.join("**/*")]
    end

    def app_path
      package_dir.join app_name
    end

    def working_dir
      config.working_dir
    end

    def executable_path
      # Expected to be overridden on *nix systems
      ""
    end

    # Temp helpers
    def create_tmp
      tmp.mkpath
    end

    def remove_tmp
      tmp.rmtree if tmp.exist?
    end

    # Downloading
    def download_template
      download remote_template_url, template_path
    end

    def download(remote_url, local_path)
      download_following_redirects remote_url, local_path
    end

    def download_following_redirects(remote_url, local_path, redirect_limit = 5)
      if redirect_limit == 0
        raise Furoshiki::DownloadError,
              "Too many redirects trying to reach #{remote_url}"
      end

      uri = URI(remote_url)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request request do |response|
          case response
          when Net::HTTPSuccess then
            warn "Downloading #{remote_url} to #{local_path}"
            open(local_path, 'wb') do |file|
              response.read_body do |chunk|
                file.write chunk
              end
            end
          when Net::HTTPRedirection then
            location = response['location']
            warn "Redirected to #{location}"
            download_following_redirects(location, local_path, redirect_limit - 1)
          else
            raise Furoshiki::DownloadError, "Couldn't download app template at #{remote_url}. #{response.value}"
          end
        end
      end
    end

    # Template helpers
    def cache_template
      cache_dir.mkpath unless cache_dir.exist?
      download_template unless template_path.size?
    end

    def extract_template
      raise IOError, "Couldn't find app template at #{template_path}." unless template_path.size?
      extracted_app = nil

      ::Zip::File.open(template_path) do |zip_file|
        zip_file.each do |entry|
          p = tmp.join(entry.name)
          p.dirname.mkpath
          entry.extract(p)
        end
      end
    end

    # Packaging helpers
    def inject_files
      # Hook for allowing different app types to put there files in
    end

    def inject_jar
      raise NotImplementedError("Tell us where the jar is")
    end

    def after_built
    end

    def create_archive(source_path)
      dest = package_dir.join(archive_name)
      File.open(dest, "wb") do |file|
        Zlib::GzipWriter.wrap(file) do |gz|
          Gem::Package::TarWriter.new(gz) do |tar|
            tmp_files.each do |source_item|
              dest_item = source_item.sub(source_path.to_s, app_name)
              if File.directory?(source_item)
                tar.mkdir(dest_item, 0755)
              else
                contents = File.binread(source_item)
                mode = dest_mode(dest_item)
                tar.add_file_simple(dest_item, mode, contents.length) do |dest|
                  dest.write(contents)
                end
              end
            end
          end
        end
      end
    end

    def ensure_jar_exists
      jar = Jar.new(@config)
      path = tmp.join(jar.filename)
      jar.package(tmp) unless File.exist?(path)
      path
    end

    def dest_mode(dest_item)
      if executable_path.to_s.end_with?(dest_item)
        0755
      else
        0644
      end
    end
  end
end
