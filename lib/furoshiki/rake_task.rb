require 'rake'

module Furoshiki
  class RakeTask
    def initialize opts={}
      yield self if block_given?
      
      desc "Builds the package for distribution"
      task "build" do
        puts "You're going to build something!"
      end

      desc "Builds an installer"
      task "install" do
        puts "You're going to install something!"
      end
    end
  end
end
