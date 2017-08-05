class ZipReader
  def initialize(file)
   @zip = ::Zip::File.open(file)
  end

  def includes?(pattern)
    @zip.any? do |file|
      File.fnmatch(pattern, file.name)
    end
  end
end
