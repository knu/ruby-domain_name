class DomainName
  ETLD_DATA_DATE = '2015-04-29T23:56:05Z'

  @@cache = nil

  def self.etld_data
    load_cache unless @@cache
    @@cache
  end

  def self.etld_data_from_yaml
    YAML.load_file(datafile_path(%w(data etld.yaml)))
  end

  def self.write_marshall_cache_from_yaml
    File.open(datafile_path(%w(cache etld)), 'w+') do |file|
      file.write Marshal.dump(etld_data_from_yaml)
    end
  end

  private

  def self.datafile_path(file_array)
    File.join([File.dirname(__FILE__), '..'] + file_array)
  end

  def self.load_cache
    @@cache ||= Marshal.load(File.binread(datafile_path %w(cache etld)))
  end
end
