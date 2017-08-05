class TarGzReader
  def initialize(file)
    @file  = file
    @files = []
    File.open(file, "rb") do |file|
      Zlib::GzipReader.wrap(file) do |gz|
        Gem::Package::TarReader.new(gz) do |tar|
          tar.each do |entry|
            @files << [entry.full_name, entry.header.mode]
          end
        end
      end
    end
  end

  def match(pattern)
    @files.select do |(file, _)|
      File.fnmatch(pattern.to_s, file)
    end.map(&:first)
  end

  def include?(pattern)
    @files.any? do |(file, _)|
      File.fnmatch(pattern.to_s, file)
    end
  end

  def contents(path)
    File.open(@file, "rb") do |file|
      Zlib::GzipReader.wrap(file) do |gz|
        Gem::Package::TarReader.new(gz) do |tar|
          tar.each do |entry|
            return entry.read if entry.full_name == path
          end
        end
      end
    end
  end

  def executable?(path)
    _, mode = @files.find do |file|
      file == path
    end

    mode ||= 0
    mode & 0111
  end
end
