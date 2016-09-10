require 'active_record'
require 'thor'
require 'crypt_keeper'

module Parol

    ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: ENV['HOME'] + '/.config/parol/parol.sqlite3'
    )

    unless ActiveRecord::Base.connection.data_sources.include? 'parols'
        ActiveRecord::Schema.define do
            create_table :parols do |t|
                t.text :application
                t.text :username
                t.text :password
            end
        end
    end

    print "Master password: "
    $master_password = STDIN.gets.chomp

    class Parol < ActiveRecord::Base

        self.table_name = "parols"
        crypt_keeper :application, :username, :password, :encryptor => :aes_new, :key => $master_password, salt: 'parol_the_best_password_manager_!'

    end

    class CLI < Thor

        desc "new", "Add a new account."
        long_desc "`parol new` Add a new account and save it in the database"
        def new
            application = ask "Application/URL: ", :magenta
            username    = ask "Username/Email:  ", :blue
            password    = ask "Password:        ", :yellow

            puts application

            Parol.create( 
                application: application,
                username: username,
                password: password
            )
        end

        desc "list", "Display all the accounts."
        long_desc "`parol list` List all the accounts from the database."
        def list
            shortcuts = lambda { |c, d| (c.length>d ? c[0...d]+'***' : c).center(20) }
            separator = set_color '|', :cyan
            lines     = set_color ('-' * 70), :cyan

            say lines + "\n" + \
                separator + set_color('id'.center(5), :green) + separator + \
                set_color('Application/URL'.center(20), :magenta) + separator + \
                set_color('Username/Email'.center(20), :blue) + separator + \
                set_color('Password'.center(20), :yellow) + separator + "\n" + lines

            Parol.all.each do |parol|

                say separator + \
                    set_color(parol.id.to_s.center(5),               :green)   + separator + \
                    set_color(shortcuts.call(parol.application, 18), :magenta) + separator + \
                    set_color(shortcuts.call(parol.username   , 18), :blue)    + separator + \
                    set_color(shortcuts.call(parol.password   , 5),  :yellow)  + separator

            end

            say lines
        end

        desc "delete_all", "Delete all the accounts, this is not reversable."
        long_desc "`parol delete_all` Delete all the accounts from the database. This action is not reversable."
        def delete_all
            Parol.destroy_all
        end

        desc "show id", "Display details for the account <id>"
        long_desc "`parol show id` Display the account from the database, where id = <id>."
        def show id
            parol = Parol.where(id: id).take

            exit unless parol

            say "id:              #{parol.id.to_s}"
            say "Application/URL: #{parol.application}"
            say "Username/Email:  #{parol.username}"
            say "Password:        #{parol.password}"
        end

        desc "delete id", "Delete the account for <id>"
        long_desc "`parol delete <id>` Delete the account from the database, where id = <id>. This action is not reversable."
        def delete id
            Parol.destroy(id)
        end

    end
end