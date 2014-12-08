require 'yaml'
require 'pathname'
require 'furoshiki/util'

shared_context 'generic furoshiki config' do
  before :all do
    @config_filename = Pathname.new(__FILE__).join('../../fixtures/config.yaml').cleanpath
    yaml = YAML.load(@config_filename.open)
    @custom_config = Object.new.extend(Furoshiki::Util).deep_symbolize_keys(yaml)
  end
end

shared_context 'generic furoshiki project' do
  before :all do
    @app_dir = Pathname.new(__FILE__).join('../../fixtures/test_project')
    @output_dir = @app_dir.join('pkg')
  end
end

