require 'spec_helper'
require 'pathname'
require 'furoshiki/windows_app'

describe Furoshiki::WindowsApp do
  include PackageHelpers

  include_context 'generic furoshiki app'

  subject { Furoshiki::WindowsApp.new config }

  let(:config)   { Furoshiki::Configuration.new @custom_config }
  let(:app_dir)  { "Sugar Clouds-windows" }
  let(:launcher) { "#{app_dir}/Sugar Clouds.bat" }
  let(:jar)      { "#{app_dir}/app.jar" }

  describe "default" do
    it "caches current version of template" do
      expect(subject.template_path).to eq(cache_dir.join('windows-app-template-0.0.1.zip'))
    end

    its(:remote_template_url) { should match(%r{https://github.com/.*/windows-app-templates/releases/download/.*/windows-app-template.*.zip}) }
  end

  describe "when creating an app" do
    before do
      create_package(Furoshiki::WindowsApp, app_dir)
    end

    subject { @subject }

    let(:archive) { ZipReader.new(@subject.archive_path) }

    its(:template_path) { should exist }

    it "includes launcher" do
      expect(archive.include?(launcher)).to be_truthy
    end

    it "injects jar" do
      expect(archive.include?(jar)).to be_truthy
    end
  end
end
