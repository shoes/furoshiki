require_relative 'spec_helper'
require 'furoshiki/shoes/configuration'

describe Furoshiki::Shoes::Configuration do
  context "defaults" do
    subject { Furoshiki::Shoes::Configuration.new }

    its(:name) { should eq('Shoes App') }
    its(:shortname) { should eq('shoesapp') }
    its(:ignore) { should eq(['pkg']) }
    its(:gems) { should include('shoes') }
    its(:version) { should eq('0.0.0') }
    its(:release) { should eq('Rookie') }
    its(:icons) { should be_an_instance_of(Hash) }
    its(:dmg) { should be_an_instance_of(Hash) }
    its(:run) { should be_nil }
    its(:working_dir) { should eq(Pathname.new(Dir.pwd)) }
    it { should_not be_valid } # no :run

    describe "#icons" do
      it 'osx is nil' do
        subject.icons[:osx].should be_nil
      end

      it 'gtk is nil' do
        subject.icons[:gtk].should be_nil
      end

      it 'win32 is nil' do
        subject.icons[:win32].should be_nil
      end
    end

    describe "#dmg" do
      it "has ds_store" do
        subject.dmg[:ds_store].should eq('path/to/default/.DS_Store')
      end

      it "has background" do
        subject.dmg[:background].should eq('path/to/default/background.png')
      end
    end

    describe "#to_hash" do
      it "round-trips" do
        Furoshiki::Shoes::Configuration.new(subject.to_hash).should eq(subject)
      end
    end
  end

  context "with options" do
    include_context 'config'
    subject { Furoshiki::Shoes::Configuration.load(@config_filename) }

    its(:name) { should eq('Sugar Clouds') }
    its(:shortname) { should eq('sweet-nebulae') }
    its(:ignore) { should include('pkg') }
    its(:run) { should eq('bin/hello_world') }
    its(:gems) { should include('rspec') }
    its(:gems) { should include('shoes') }
    its(:version) { should eq('0.0.1') }
    its(:release) { should eq('Mindfully') }
    its(:icons) { should be_an_instance_of(Hash) }
    its(:dmg) { should be_an_instance_of(Hash) }
    its(:working_dir) { should eq(@config_filename.dirname) }
    it { should be_valid }

    describe "#icons" do
      it 'has osx' do
        subject.icons[:osx].should eq('img/boots.icns')
      end

      it 'has gtk' do
        subject.icons[:gtk].should eq('img/boots_512x512x32.png')
      end

      it 'has win32' do
        subject.icons[:win32].should eq('img/boots.ico')
      end
    end

    describe "#dmg" do
      it "has ds_store" do
        subject.dmg[:ds_store].should eq('path/to/custom/.DS_Store')
      end

      it "has background" do
        subject.dmg[:background].should eq('path/to/custom/background.png')
      end
    end

    it "incorporates custom features" do
      subject.custom.should eq('my custom feature')
    end

    it "round-trips" do
      Furoshiki::Shoes::Configuration.new(subject.to_hash).should eq(subject)
    end
  end

  context "with name, but without explicit shortname" do
    let(:options) { {:name => "Sugar Clouds"} }
    subject { Furoshiki::Shoes::Configuration.new options }

    its(:name) { should eq("Sugar Clouds") }
    its(:shortname) { should eq("sugarclouds") }
  end

  context "when the file to run doens't exist" do
    let(:options) { {:run => "path/to/non-existent/file"} }
    subject { Furoshiki::Shoes::Configuration.new options }

    it { should_not be_valid }
  end

  context "when osx icon is not specified" do
    include_context 'config'
    let(:valid_config) { Furoshiki::Shoes::Configuration.load(@config_filename) }
    let(:options) { valid_config.to_hash.merge(:icons => {}) }
    subject { Furoshiki::Shoes::Configuration.new(options) }

    it "sets osx icon path to nil" do
      subject.icons[:osx].should be_nil
    end

    it "is valid" do
      subject.should be_valid
    end
  end

  context "when osx icon is specified, but doesn't exist" do
    let(:options) { ({:icons => {:osx => "path/to/non-existent/file"}}) }
    subject { Furoshiki::Shoes::Configuration.new options }

    it "sets osx icon path" do
      subject.icons[:osx].should eq("path/to/non-existent/file")
    end

    it { should_not be_valid }
  end

  context "auto-loading" do
    include_context 'config'

    context "without a path" do
      it "looks for 'app.yaml' in current directory" do
        Dir.chdir @config_filename.parent do
          config = Furoshiki::Shoes::Configuration.load
          config.shortname.should eq('sweet-nebulae')
        end
      end

      it "blows up if it can't find the file" do
        Dir.chdir File.dirname(__FILE__) do
          lambda { config = Furoshiki::Shoes::Configuration.load }.should raise_error
        end
      end
    end

    shared_examples "config with path" do
      it "finds the config" do
        Dir.chdir File.dirname(__FILE__) do
          config = Furoshiki::Shoes::Configuration.load(path)
          config.shortname.should eq('sweet-nebulae')
        end
      end
    end

    context "with an 'app.yaml'" do
      let(:path) { @config_filename }
      it_behaves_like "config with path"
    end

    context "with a path to a directory containing an 'app.yaml'" do
      let(:path) { @config_filename.parent }
      it_behaves_like "config with path"
    end

    context "with a path to a file that is siblings with an 'app.yaml'" do
      let(:path) { @config_filename.parent.join('sibling.rb') }
      it_behaves_like "config with path"
    end

    context "with a path that exists, but no 'app.yaml'" do
      let(:path) { @config_filename.parent.join('bin/hello_world') }
      subject { Furoshiki::Shoes::Configuration.load(path) }

      its(:name) { should eq('hello_world') }
      its(:shortname) { should eq('hello_world') }
    end

    context "when the file doesn't exist" do
      it "blows up" do
        lambda { Furoshiki::Shoes::Configuration.load('some/bogus/path') }.should raise_error
      end
    end
  end
end
