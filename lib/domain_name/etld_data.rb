class DomainName
  @@cache = nil

  def self.etld_data
    load_cache unless @@cache
    @@cache['data']
  end

  def self.etld_data_date
    load_cache unless @@cache
    @@cache['data_date']
  end

  private

  def self.datafile_path(file_array)
    File.join([File.dirname(__FILE__), '..'] + file_array)
  end

  def self.load_cache
    return @@cache if @@cache

    if File.respond_to?(:binread)
      @@cache = Marshal.load(File.binread(datafile_path(%w(cache etld))))
    else
      @@cache = Marshal.load(File.open(datafile_path(%w(cache etld)), 'rb') { |f| f.read })
    end
  end
end
