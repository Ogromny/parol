# This file is called core.rb
# It contains the module Parol

# Require aes for encrypt Parol class
require 'aes'

# Module Parol contains class: Parol, Parols, Parols_IO
module Parol

    PAROL_VERSION = "1.8.5"
    PAROLS_VERSION = "1.8.5"
    PAROLS_IO_VERSION = "1.8.5"

    # This class represents an entry
    class Parol

        attr_accessor :url, :username, :password, :encrypted

        # for future change of delimiter
        BEGIN_PAROL = "=begin"

        # Constructor
        #
        # @param url [String] the Url, Link, Address
        # @param username [string] the pseudo, user, name, email, ...
        # @param password [string] the password of username
        # @param encrypted [Boolean] false if not encrypted, true if encrypted
        def initialize url = "", username = "", password = "",  encrypted = false
            @url              = url
            @username         = username
            @password         = password
            @encrypted        = encrypted
        end

        # to_s
        #
        # @return [String]
        def to_s
            "#{BEGIN_PAROL}@url=#{@url}@username=#{@username}@password=#{@password}"
        end

    end

    # This class stock all Parol in 1
    class Parols

        attr_accessor :encrypt_password

        # Constructor
        #
        # Make an array @parols
        # @param encrypt_password [string] the password for the encryption
        def initialize encrypt_password = ""
            @parols           = Array.new
            @encrypt_password = encrypt_password
        end

        # +
        #
        # Add Parol instance in @parols
        #
        # @param parol [Parol] take an instance of Parol
        # @return [Parols, Boolean] false if parol is not Parol
        def + parol
            @parols.push parol; self
        end

        # ncrypt!
        #
        # Crypt all Parol in @parols
        #
        # @return [Parols] self
        def ncrypt!
            @parols.each do |parol|
                unless parol.encrypted
                    parol.url       = AES.encrypt parol.url, @encrypt_password
                    parol.username  = AES.encrypt parol.username, @encrypt_password
                    parol.password  = AES.encrypt parol.password, @encrypt_password
                    parol.encrypted = true
                end
            end
            self
        end

        # dcrypt!
        #
        # Decrypt all Parol in @parols
        #
        # @return [Parols] self
        def dcrypt!
            @parols.each do |parol|
                if parol.encrypted
                    parol.url       = AES.decrypt parol.url, @encrypt_password
                    parol.username  = AES.decrypt parol.username, @encrypt_password
                    parol.password  = AES.decrypt parol.password, @encrypt_password
                    parol.encrypted = false
                end
            end
            self
        end

        # to_s
        #
        # Check if all Parol in @parols is_ncrypted?
        #   If a Parol isn't ncrypted, ncrypt! it
        #
        # @return [String] of all Parol.to_s in one String
        def to_s ls_mod = false
            if ls_mod
                i = 0
                s = String.new; @parols.each { |parol| s += "[#{i}] #{parol.to_s}\n"; i += 1 }; s
            else
                s = String.new; @parols.each { |parol| s += parol.to_s }; s
            end
        end

        # rm
        #
        # Delete Parol in @parols at index
        # @param [Integer] index
        # @return [Parols] self
        def rm index
            @parols.delete_at index; self
        end

        # from_db
        #
        # Add all Parol from db_content with +
        # @param [String] the content of the db file
        # @return [Parols] self
        def from_db db_content
            db_content = db_content.split "=begin"; db_content.delete_at 0

            data_of_db = Array.new(db_content.length) { Array.new 3 }

            db_content.each_index do |index|
                db_content[index], data_of_db[index][2] = db_content[index].split ("@password=")
                db_content[index], data_of_db[index][1] = db_content[index].split ("@username=")
                db_content[index], data_of_db[index][0] = db_content[index].split ("@url=")

                self.+ Parol.new(data_of_db[index][0], data_of_db[index][1], data_of_db[index][2], true)
            end

            self
        end

    end

    # this class if used for write/read parols database
    class Parols_IO

        attr_accessor :filename

        # Constructor
        #
        # @param [String] the path of the parols database
        def initialize filename = ""
            @filename = filename
        end

        # read
        #
        # @return [String] content of @filename
        def read
            file = File.new @filename, "r"; content = String.new

            while line = file.gets; content += line; end

            file.close; content
        end

        # write
        #
        # @param [String] Parols.to_s generaly
        def write parols
            # file = File.new @filename, "w"; file.puts parols; file.close
            file = File.new @filename, "w+"
            file.puts parols
            file.close
            true
        end
    end

end
