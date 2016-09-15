require 'active_record'
require 'rbnacl/libsodium'
require_relative 'config'

module Parol

    $password = ""
    
    class Database

        ask = lambda { |a| print a; STDIN.gets.chomp.to_s }

        ActiveRecord::Base.establish_connection(
            adapter: 'sqlite3',
            database: ENV['HOME'] + '/.config/parol/parol.sqlite3'
        )

        if ActiveRecord::Base.connection.data_sources.include? 'parols'
            $password = ask.call 'Password of the database: ' while $password.length != 32
        else
            ActiveRecord::Schema.define {
                create_table(:parols) { |t| t.binary :application; t.binary :username; t.binary :password }
            }
            $password = ask.call 'Password for the database ( it must be 32 of length ): ' while $password.length != 32
            puts 'Never forget this password: ' + $password
        end

    end


    class Parol < ActiveRecord::Base

    end

    class Crypt

        @@box = RbNaCl::SimpleBox.from_secret_key(String.new($password, encoding: 'BINARY'))

        def self.encrypt(parol)
            application = @@box.encrypt(parol[0])
            username    = @@box.encrypt(parol[1])
            password    = @@box.encrypt(parol[2])
            { application: application, username: username, password: password }
        end

        def self.decrypt(parol)
            id          = parol[0].to_s
            application = @@box.decrypt(parol[1])
            username    = @@box.decrypt(parol[2])
            password    = @@box.decrypt(parol[3])
            [id, application, username, password]
        end

    end

end