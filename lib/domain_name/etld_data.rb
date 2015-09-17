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
    @@cache ||= YAML.load_file(datafile_path(%w(data etld.yaml)))
  end
end
