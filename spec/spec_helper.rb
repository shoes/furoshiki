require 'rspec'
require 'rspec/its'
require 'pry'
require 'pathname'

# Packaging caches files in $HOME/.furoshiki/cache by default.
# For testing, we override $HOME using $FUROSHIKI_HOME
FUROSHIKI_SPEC_DIR = Pathname.new(__FILE__).dirname.expand_path.to_s
ENV['FUROSHIKI_HOME'] = FUROSHIKI_SPEC_DIR

# Guards for running or not running specs. Specs in the guarded block only
# run if the guard conditions are met.
#
module Guard
  # Runs specs only if platform matches
  #
  # @example
  # platform_is :windows do
  #   it "does something only on windows" do
  #     # specification
  #   end
  # end
  def platform_is(platform)
    yield if self.send "platform_is_#{platform.to_s}"
  end

  # Runs specs only if platform does not match
  #
  # @example
  # platform_is_not :windows do
  #   it "does something only on posix systems" do
  #     # specification
  #   end
  # end
  def platform_is_not(platform)
    yield unless self.send "platform_is_#{platform.to_s}"
  end

  def platform_is_windows
    return RbConfig::CONFIG['host_os'] =~ /windows|mswin/i
  end

  def platform_is_linux
    return RbConfig::CONFIG['host_os'] =~ /linux/i
  end

  def platform_is_osx
    return RbConfig::CONFIG['host_os'] =~ /darwin/i
  end
end

include Guard

module PackageHelpers
  # need these values from a context block, so let doesn't work
  def spec_dir
    Pathname.new(__FILE__).join('..').cleanpath
  end

  def input_dir
    spec_dir.join 'support', 'zip'
  end
end

module ZipHelpers
  include PackageHelpers
  # dir = Pathname.new('spec/support/zip')
  # add_trailing_slash(dir) #=> '/path/to/spec/support/zip/'
  def add_trailing_slash(dir)
    dir.to_s + "/"
  end

  def relative_input_paths(from_dir)
    Pathname.glob(input_dir + "**/*").map do |p|
      directory = true if p.directory?
      relative_path = p.relative_path_from(from_dir).to_s
      relative_path = add_trailing_slash(relative_path) if directory
      relative_path
    end
  end
end

spec_root = File.dirname(__FILE__)
Dir["#{spec_root}/support/**/*.rb"].each { |f| require f }

