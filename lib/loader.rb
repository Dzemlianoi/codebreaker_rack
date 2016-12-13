module Codebreaker
  class Loader
    PATH = 'lib/data/'
    EXTENSION = '.yml'
    def self.load(file_name)
      file_name = PATH + file_name + EXTENSION.to_s
      return YAML.load(File.open(file_name)) if File.exist?(file_name)
      File.new(file_name, 'w')
      []
    end

    def self.save(file_name, data_object)
      full_path = PATH.to_s + file_name.to_s + EXTENSION
      data = YAML.dump(data_object)
      File.new(full_path, 'w') unless File.exist?(full_path)
      File.write(full_path, data)
    end
  end
end
