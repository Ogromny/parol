# This file is called core.rb
# It contains the module Parol

# Require aes for encrypt Parol class
require 'aes'

# Module Parol contains class: Parol, Parols, Parols_IO
module Parol

    PAROL_VERSION = "1.2.0"
    PAROLS_VERSION = "1.2.0"
    PAROLS_IO_VERSION = "1.2.0"

    # This class represents an entry
    class Parol

        attr_accessor :url, :username, :password, :encrypted

        # for future change of delimiter
        BEGIN_PAROL = "=begin"
        END_PAROL   = "=end"

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
            "#{BEGIN_PAROL}" +
            "@url=#{@url}" +
            "@username=#{@username}" +
            "@password=#{@password}" +
            "#{END_PAROL}"
        end

    end

    # This class stock all Parol in 1
    class Parols

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
            if parol.is_a? Parol
                @parols.push parol
            else
                return false
            end
            self
        end

        # RW NEEDED
        def ncrypt!
            @parols.each do |parol|
                unless parol.encrypted
                    parol.url       = AES.encrypt parol.url, @encrypt_password
                    parol.username  = AES.encrypt parol.username, @encrypt_password
                    parol.password  = AES.encrypt parol.password, @encrypt_password
                    parol.encrypted = true
                end
            end
        end

        # RW NEEDED
        def dcrypt!
            @parols.each do |parol|
                if parol.encrypted
                    parol.url       = AES.decrypt parol.url, @encrypt_password
                    parol.username  = AES.decrypt parol.username, @encrypt_password
                    parol.password  = AES.decrypt parol.password, @encrypt_password
                    parol.encrypted = false
                end
            end
        end

        # to_s
        #
        # Check if all Parol in @parols is_ncrypted?
        #   If a Parol isn't ncrypted, ncrypt! it
        #
        # @return [String] of all Parol.to_s in one String
        def to_s
            s = String.new
            i = 0
            @parols.each do |parol|
                # unless parol.encrypted; ncrypt!; end
                s +=  "[#{i}] #{parol.to_s}\n"
                i += 1
            end
            return s
        end

        def rm index
            @parols.delete_at index
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
        # @return [Boolean] true if succed, false if failed
        def write parols
            begin
                file = File.new @filename, "w"
                file.puts parols
                file.close
                return true
            rescue Exception => error
                puts error
                return false
            end
        end
    end

end
