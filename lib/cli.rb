require 'thor'
require_relative 'base_crypt'

module Parol

    class CLI < Thor

        desc "new", "Add a new account."
        long_desc "`parol new` Add a new account and save it in the database"
        def new
            application = ask "Application/URL: ", :magenta
            username    = ask "Username/Email:  ", :blue
            password    = ask "Password:        ", :yellow

            parol = Crypt.encrypt [application, username, password]

            Parol.create(parol)
        end

        desc "show id", "Display details for the account <id>"
        long_desc "`parol show id` Display the account from the database, where id = <id>."
        def show id
            parol = Parol.where(id: id).take

            exit unless parol

            separator = set_color '|', :cyan
            lines     = set_color ('-' * 70), :cyan

            parol_array = [parol.id, parol.application, parol.username, parol.password]

            parol_decrypted = Crypt.decrypt(parol_array)

            id = set_color parol_decrypted[0].center(5), :green
            au = set_color parol_decrypted[1].center(62), :magenta
            ue = set_color parol_decrypted[2].center(68), :blue
            pw = set_color parol_decrypted[3].center(68), :yellow

            say lines
            say "#{separator}#{id}#{separator}#{au}#{separator}"
            say lines
            say "#{separator}#{ue}#{separator}"
            say "#{separator}#{pw}#{separator}"
            say lines
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

                parol_decrypted = Crypt.decrypt(parol_array)

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