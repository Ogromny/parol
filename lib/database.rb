require 'rbnacl/libsodium'

module Parol

    class Database

        # Ask for the password of the database
        loop do
            print 'Database password: '
            @@password = STDIN.gets.chomp

            if @@password.length == 32
                break
            else
                puts 'Password must be 32 of length.'
            end
        end

        ## The box that will be used to encrypt and decrypt the database
        @@box = RbNaCl::SimpleBox.from_secret_key(String.new(@@password, encoding: 'BINARY'))
        ## The path to the database
        @@database = "#{ENV['HOME']}/.config/parol/data"

        ## Create an empty database and return it
        def self.create
            data = Array.new

            File.open(@@database, 'wb') do |file|
                file.write @@box.encrypt(Marshal.dump(data))
            end

            # noinspection RubyResolve
            Marshal.load @@box.decrypt(File.binread(@@database))
        end

        ## Return the database decrypted
        def self.decrypt
            unless File.exists? @@database
                return create
            end

            # noinspection RubyResolve
            Marshal.load @@box.decrypt(File.binread(@@database))
        end

        # Encrypt data and write it to the database
        def self.encrypt data
            File.open(@@database, 'wb') do |file|
                file.write @@box.encrypt(Marshal.dump(data))
            end
        end

    end

end