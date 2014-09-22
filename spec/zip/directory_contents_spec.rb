require 'spec_helper'
require 'fileutils'
require 'furoshiki/zip'

describe Furoshiki::Zip::DirectoryContents do

  context "output file" do
    include_context 'zip'

    before :all do
      zip_directory_contents = Furoshiki::Zip::DirectoryContents.new input_dir, @output_file
      zip_directory_contents.write
      @zip = Zip::File.open @output_file
    end

    it "exists" do
      @output_file.should exist
    end

    it "does not include input directory without parents" do
      @zip.entries.map(&:name).should_not include(add_trailing_slash input_dir.basename)
    end

    relative_input_paths(input_dir).each do |path|
      it "includes all children of input directory" do
        @zip.entries.map(&:name).should include(path)
      end
    end
  end
end
