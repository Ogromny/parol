# This file is called core.rb
# It contains the module Parol

# Require aes for encrypt Parol class
require 'aes'

# Module Parol contains class: Parol, Parols, Parols_IO
module Parol

    # This class represents an entry
    class Parol

        # for future change of delimiter
        BEGIN_PAROL = "=begin"
        END_PAROL   = "=end"

        # Constructor
        #
        # @param url [String] the Url, Link, Address
        # @param username [string] the pseudo, user, name, email, ...
        # @param password [string] the password of username
        # @param encrypt_password [string] the password for the encryption
        # @param encrypted [Boolean] false if not encrypted, true if encrypted
        def initialize url = "", username = "", password = "", encrypt_password = "", encrypted = false
            @url              = url
            @username         = username
            @password         = password
            @encrypt_password = encrypt_password
            @encrypted        = encrypted
        end

        # ncrypt!
        #
        # If @encrypted is true nothing append
        # Else:
        #   Encrypt in AES @url, @username and @password with @encrypt_password
        #   Set @encrypted true to avoid second encryption
        def ncrypt!
            unless @encrypted
                @url       = AES.encrypt @url, @encrypt_password
                @username  = AES.encrypt @username, @encrypt_password
                @password  = AES.encrypt @password, @encrypt_password
                @encrypted = true
            end
        end

        # dcrypt!
        #
        # If @encrypted is false nothing append
        # Else:
        #   Decrypt @url, @username and @password with @encrypt_password
        #   Set @encrypt false to avoid second decryption
        def dcrypt!
            if @encrypted
                @url       = AES.decrypt @url, @encrypt_password
                @username  = AES.decrypt @username, @encrypt_password
                @password  = AES.decrypt @password, @encrypt_password
                @encrypted = false
            end
        end

        # to_s
        #
        # @return [String]
        def to_s
            "#{BEGIN_PAROL}" +
            "@url=#{@url}" +
            "@username=#{@username}" +
            "@password=#{@password}" +
            "#{END_PAROL}"
        end

        # is_ncrypted?
        #
        # @return [Boolean]
        def is_ncrypted?
            @encrypted
        end

    end

    # This class stock all Parol in 1
    class Parols

        # Constructor
        #
        # Make an array @parols
        def initialize
            @parols = Array.new
        end

        # +
        #
        # Add Parol instance in @parols
        #
        # @param parol [Parol] take an instance of Parol
        # @return [Parols, Boolean] false if parol is not Parol
        def + parol
            if parol.is_a? Parol
                @parols.push parol
            else
                return false
            end
            self
        end

        # to_s
        #
        # Check if all Parol in @parols is_ncrypted?
        #   If a Parol isn't ncrypted, ncrypt! it
        #
        # @return [String] of all Parol.to_s in one String
        def to_s
            @parols.each do |parol|
                unless parol.is_ncrypted?
                    parol.ncrypt!
                end
                parol.to_s
            end
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
        # @return [String, Boolean] content of @filename or false
        def read
            begin
                file = File.new @filename, "r"
                content = String.new

                while line = file.gets
                    content += line
                end

                file.close

                return content
            rescue Exception => error
                puts error
                return false
            end
        end

        # write
        #
        # @param [String] Parols.to_s generaly
        def write parols
            file = File.new @filename, "w"

            file.puts parols

            file.close
        end
    end

end
