require 'yaml'
require 'pathname'
require 'furoshiki/util'

shared_context 'generic furoshiki app' do
  let(:cache_dir) { Pathname.new(FUROSHIKI_SPEC_DIR).join('.furoshiki', 'cache') }

  before :all do
    @app_dir = Pathname.new(__FILE__).join('../../fixtures/test_app')
    @output_dir = @app_dir.join('pkg')

    @config_filename = Pathname.new(__FILE__).join('../../fixtures/test_app/app.yaml').cleanpath
    yaml = YAML.load(@config_filename.open)
    @custom_config = Object.new.extend(Furoshiki::Util).deep_symbolize_keys(yaml)
  end

  def create_package(clazz, app_name)
    @output_dir.rmtree if @output_dir.exist?
    @output_dir.mkpath

    @output_file = @output_dir.join app_name

    # Config picks up Dir.pwd
    Dir.chdir @app_dir do
      config = Furoshiki::Configuration.new(@custom_config)
      @subject = clazz.new(config)
      @subject.package
    end
  end

  def untar
    # For inspection, untar the archive where it belongs
    `cd '#{@subject.package_dir}' && tar xf '#{@subject.archive_path.to_s}'`
  end
end

