require 'yaml'

module Parol

    class Config

        @@config_filename = ENV['HOME'] + '/.config/parol/parol.yml'

        def self.load
            if File.exist? @@config_filename
                YAML.load_file @@config_filename 
            else

                nil
            end
        end

        def self.save config
            File.write @@config_filename, config   
        end

    end

end