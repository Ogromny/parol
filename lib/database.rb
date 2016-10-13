require 'rbnacl/libsodium'

module Parol

    # noinspection RubyResolve
    class Database
        # Executed once, permits to authenticate the actions done then this.

        # Ask for the password of the database
        puts 'Database password:'
        @@password = STDIN.gets.chomp
        abort('Password must be 32 of length') unless @@password.length == 32

        ## The box that will be used to encrypt and decrypt the database
        @@box = RbNaCl::SimpleBox.from_secret_key(String.new(@@password, encoding: 'BINARY'))
        ## The path to the database
        @@database = "#{ENV['HOME']}/.config/parol/data"

        ## Create an empty database
        def self.create
            File.open(@@database, 'wb') { |f| f.write @@box.encrypt(Marshal.dump(Array.new)) }
        end

        ## Return the database decrypted
        def self.decrypt
            create unless File.exists? @@database

            Marshal.load @@box.decrypt(File.binread(@@database)) rescue abort 'Invalid database password !'
        end

        # Encrypt data and write it to the database
        def self.encrypt data
            File.open(@@database, 'wb') { |f| f.write @@box.encrypt(Marshal.dump(data)) }
        end

    end

end