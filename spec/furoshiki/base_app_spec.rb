require 'spec_helper'
require 'pathname'
require 'furoshiki/base_app'

class TestApp < Furoshiki::BaseApp
  def template_filename
    "template"
  end

  def archive_name
    "base.tar.gaz"
  end
end

describe Furoshiki::BaseApp do
  include_context 'generic furoshiki app'

  subject { TestApp.new config }

  # $FUROSHIKI_HOME is set in spec_helper.rb for testing purposes,
  # but should default to $HOME
  describe "when not setting $FUROSHIKI_HOME" do
    before do
      @old_furoshiki_home = ENV['FUROSHIKI_HOME']
      ENV['FUROSHIKI_HOME'] = nil
    end

    its(:cache_dir) { should eq(Pathname.new(Dir.home).join('.furoshiki', 'cache')) }

    after do
      ENV['FUROSHIKI_HOME'] = @old_furoshiki_home
    end
  end

  describe "default" do
    let(:cache_dir) { Pathname.new(FUROSHIKI_SPEC_DIR).join('.furoshiki', 'cache') }
    its(:cache_dir) { should eq(cache_dir) }

    it "sets package dir to {pwd}/pkg" do
      Dir.chdir test_app_dir do
        expect(subject.default_package_dir).to eq(test_app_dir.join 'pkg')
      end
    end
  end

  describe "with an invalid configuration" do
    before do
      allow(config).to receive(:valid?) { false }
    end

    it "fails to initialize" do
      expect { subject }.to raise_error(Furoshiki::ConfigurationError)
    end
  end
end
