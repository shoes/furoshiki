require 'spec_helper'
require 'pathname'
require 'furoshiki/linux_app'

describe Furoshiki::LinuxApp do
  include PackageHelpers

  include_context 'generic furoshiki app'

  subject { Furoshiki::LinuxApp.new config }

  let(:config)   { Furoshiki::Configuration.new @custom_config }
  let(:app_dir)  { "Sugar Clouds-linux" }
  let(:launcher) { "#{app_dir}/Sugar Clouds" }
  let(:jar)      { "#{app_dir}/app.jar" }

  describe "default" do
    it "caches current version of template" do
      expect(subject.template_path).to eq(cache_dir.join('linux-app-template-0.0.1.zip'))
    end

    its(:remote_template_url) { should match(%r{https://github.com/.*/linux-app-templates/releases/download/.*/linux-app-template.*.zip}) }
  end

  describe "when creating an app" do
    before do
      create_package(Furoshiki::LinuxApp, app_dir)
    end

    subject { @subject }

    let(:archive) { TarGzReader.new(@subject.archive_path) }

    its(:template_path) { should exist }

    it "creates the archive" do
      expect(@subject.archive_path).to exist
    end

    it "includes launcher" do
      expect(archive.include?(launcher)).to be_truthy
    end

    it "makes launcher executable" do
      expect(archive.executable?(launcher)).to be_truthy
    end

    it "injects jar" do
      expect(archive.include?(jar)).to be_truthy
    end
  end
end
