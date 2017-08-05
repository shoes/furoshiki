class ZipReader
  def initialize(file)
   @zip = ::Zip::File.open(file)
  end

  def include?(pattern)
    @zip.any? do |file|
      File.fnmatch(pattern.to_s, file.name)
    end
  end
end
