require 'rbnacl/libsodium'

module Parol

    # noinspection RubyResolve
    class Database

        ## The path to the database
        @@database = "#{ENV['HOME']}/.config/parol/data"

        ## set +password+
        def self.password=(password)
            abort('Password must be 32 of length') unless password.length == 32

            ## The box that will be used to encrypt and decrypt the database
            @@box = RbNaCl::SimpleBox.from_secret_key(String.new(password, encoding: 'BINARY'))
        end

        ## Create an empty database
        def self.create
            File.open(@@database, 'wb') { |f| f.write @@box.encrypt(Marshal.dump(Array.new)) }
        end

        ## Return the database decrypted
        def self.decrypt
            create unless File.exists? @@database

            Marshal.load @@box.decrypt(File.binread(@@database)) rescue abort 'Invalid database password !'
        end

        ## Encrypt +data+ and write it to the database
        def self.encrypt(data)
            File.open(@@database, 'wb') { |f| f.write @@box.encrypt(Marshal.dump(data)) }
        end

        ## Remove account +index+ from the database
        def self.remove(index)
            index = Integer(index) rescue abort('index does not exists !')
            data = decrypt
            abort('index does not exists !') if data.delete_at(index).nil?
            Database.encrypt(data)
        end

    end

end