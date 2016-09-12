require 'active_record'
require 'thor'
require 'rbnacl/libsodium'

module Parol

    $password = ""

    class Database

        ask = lambda { |a| print a; STDIN.gets.chomp.to_s }

        ActiveRecord::Base.establish_connection(
            adapter: 'sqlite3',
            database: ENV['HOME'] + '/.config/parol/parol.sqlite3'
        )

        if ActiveRecord::Base.connection.data_sources.include? 'parols'
            $password = ask.call "Password of the database: " while $password.length != 32
        else
            ActiveRecord::Schema.define {
                create_table(:parols) { |t| t.binary :application; t.binary :username; t.binary :password }
            }
            $password = ask.call "Password for the database ( it must be 32 of length ): " while $password.length != 32
            puts "Never forget this password: " + $password
        end

    end


    class Parol < ActiveRecord::Base

    end

    class Utils

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

    class CLI < Thor

        desc "new", "Add a new account."
        long_desc "`parol new` Add a new account and save it in the database"
        def new
            application = ask "Application/URL: ", :magenta
            username    = ask "Username/Email:  ", :blue
            password    = ask "Password:        ", :yellow

            parol = Utils.encrypt [application, username, password]

            Parol.create(parol)
        end

        desc "show id", "Display details for the account <id>"
        long_desc "`parol show id` Display the account from the database, where id = <id>."
        def show id
            parol = Parol.where(id: id).take

            unless parol
                exit
            end

            parol_array = [parol.id, parol.application, parol.username, parol.password]

            parol_decrypted = Utils.decrypt(parol_array)

            say "id:              #{parol_decrypted[0]}"
            say "Application/URL: #{parol_decrypted[1]}"
            say "Username/Email:  #{parol_decrypted[2]}"
            say "Password:        #{parol_decrypted[3]}"
        end

        desc "list", "Display all the accounts."
        long_desc "`parol list` List all the accounts from the database."
        def list
            shortcuts = lambda { |c, d| (c.length>d ? c[0...d]+'...' : c).center(20) }
            separator = set_color '|', :cyan
            lines     = set_color ('-' * 70), :cyan

            id = set_color 'id'.center(5), :green
            au = set_color 'Application/URL'.center(20), :magenta
            ue = set_color 'Username/Email'.center(20), :blue
            pw = set_color 'Password'.center(20), :yellow

            say lines
            say "#{separator}#{id}#{separator}#{au}#{separator}#{ue}#{separator}#{pw}#{separator}"
            say lines

            Parol.all.each do |parol|

                parol_array = [parol.id, parol.application, parol.username, parol.password]

                parol_decrypted = Utils.decrypt(parol_array)

                parol_decrypted[0] = set_color(parol_decrypted[0].center(5), :green)
                parol_decrypted[1] = set_color(shortcuts.call(parol_decrypted[1], 17), :magenta)
                parol_decrypted[2] = set_color(shortcuts.call(parol_decrypted[2], 17), :blue)
                parol_decrypted[3] = set_color(shortcuts.call(parol_decrypted[3], 5), :yellow)

                say "#{separator}#{parol_decrypted[0]}#{separator}#{parol_decrypted[1]}#{separator}#{parol_decrypted[2]}#{separator}#{parol_decrypted[3]}#{separator}"
                
            end

            say lines
        end

        desc "delete id", "Delete the account for <id>, or <all> for everything"
        long_desc "`parol delete <id>` Delete the account from the database, where id = <id>. This action is not reversable."
        def delete id
            if id == "all"
                Parol.destroy_all
            else
                Parol.destroy(id)
            end
        end

    end
end