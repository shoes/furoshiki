require 'yaml'
require 'pathname'
require 'furoshiki/util'

shared_context 'generic furoshiki app' do
  let(:cache_dir)    { Pathname.new(FUROSHIKI_SPEC_DIR).join('.furoshiki', 'cache') }
  let(:test_app_dir) { @test_app_dir }

  let(:config) do
    Dir.chdir test_app_dir do
      yaml = YAML.load(test_app_dir.join("app.yaml").open)
      custom = Object.new.extend(Furoshiki::Util).deep_symbolize_keys(yaml)
      Furoshiki::Configuration.new(custom)
    end
  end

  subject do
    Dir.chdir test_app_dir do
      sub = packaging_class.new(config)
      sub.package
      sub
    end
  end

  before :all do
    @test_app_dir = Pathname.new(__FILE__).join('../../fixtures/test_app')

    output_dir = @test_app_dir.join("pkg")
    output_dir.rmtree if output_dir.exist?
    output_dir.mkpath
  end
end

