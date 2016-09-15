require 'active_record'
require 'rbnacl/libsodium'
require_relative 'config'

module Parol

    $config = Config.load
    $password = ''
    
    class Database

        ask = lambda do |message|
            print message
            STDIN.gets.chomp.to_s
        end

        ActiveRecord::Base.establish_connection(
            adapter: 'sqlite3',
            database: ENV['HOME'] + '/.config/parol/parol.sqlite3'
        )

        if ActiveRecord::Base.connection.data_sources.include? 'parols'

            if $config['password'] && $config['password'].length == 32
                $password = $config['password']
            else
                while $password.length != 32
                    $password = ask.call 'Password of the database: '
                end
            end

        else

            ActiveRecord::Schema.define do

                create_table :parols do |t|

                    t.binary :application
                    t.binary :username
                    t.binary :password

                end

            end

            while $password.length != 32
                $password = ask.call 'Password for the database (it must be 32 of length): '
            end

            puts 'Never forget this password: ' + $password

        end

    end


    class Parol < ActiveRecord::Base

    end

    class Crypt

        @@box = RbNaCl::SimpleBox.from_secret_key(String.new($password, encoding: 'BINARY'))

        def self.encrypt parol
            application = @@box.encrypt parol[0]
            username    = @@box.encrypt parol[1]
            password    = @@box.encrypt parol[2]
            { application: application, username: username, password: password }
        end

        def self.decrypt parol
            id          = parol[0].to_s
            application = @@box.decrypt parol[1]
            username    = @@box.decrypt parol[2]
            password    = @@box.decrypt parol[3]
            [id, application, username, password]
        end

    end

end