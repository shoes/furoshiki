require 'pathname'
require 'zip'

module Furoshiki
  module Zip
    # Adapted from rubyzip's sample, ZipFileGenerator
    #
    # This is a utility class that uses rubyzip to recursively
    # generate a zip file containing the given entries and all of
    # their children.
    #
    # Best used through frontend classes Furoshiki::Zip::Directory or
    # Furoshiki::Zip::DirectoryContents
    #
    # @example
    # To zip the directory "/tmp/input" so that unarchiving
    # gives you a single directory "input":
    #
    #   output_file = '/tmp/out.zip'
    #
    #   zip = Furoshiki::Zip::Recursive(output_file)
    #   entries = Pathname.new("/tmp/input").entries
    #   zip_prefix = ''
    #   disk_prefix = '/tmp'
    #   zf.write(entries, disk_prefix, zip_prefix, output_file)
    class Recursive
      def initialize(output_file)
        @output_file = output_file.to_s
      end

      # @param [Array<Pathname>] entries the initial set of files to include
      # @param [Pathname] disk_prefix a path prefix for existing entries
      # @param [Pathname] zip_prefix a path prefix to add within archive
      def write(entries, disk_prefix, zip_prefix)
        io = ::Zip::File.open(@output_file, ::Zip::File::CREATE);
        write_entries(entries, disk_prefix, zip_prefix, io)
        io.close();
      end

      # A helper method to make the recursion work.
      private
      def write_entries(entries, disk_prefix, path, io)
        entries.each do |e|
          zip_path = path.to_s == "" ? e.basename : path.join(e.basename)
          disk_path = disk_prefix.join(zip_path)
          puts "Deflating #{disk_path}"
          if disk_path.directory?
            io.mkdir(zip_path)
            subdir = disk_path.children(false)
            write_entries(subdir, disk_prefix, zip_path, io)
          else
            io.get_output_stream(zip_path) { |f| f.puts(File.open(disk_path, "rb").read())}
          end
        end
      end
    end
  end
end
