require 'active_record'
require 'thor'
require 'rainbow/ext/string'
require 'crypt_keeper'

module Parol
    $database_password = 'parol'

    ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: 'parol.sqlite3'
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

    class Parol < ActiveRecord::Base

        self.table_name = "parols"
        crypt_keeper :application, :username, :password, :encryptor => :aes_new, :key => $database_password, salt: 'parol_the_best_password_manager_!'

    end

    class CLI < Thor

        desc "new", "Add a new account."
        long_desc <<-LONGDESC
            `parol new` Add a new account and save it in the database
        LONGDESC
        def new
            print "Application/URL: ".color(:magenta) 
            application = STDIN.gets.to_s.chomp
            print "Username/Email:  ".color(:blue)
            username = STDIN.gets.to_s.chomp
            print "Password:        ".color(:yellow)
            password = STDIN.gets.to_s.chomp

            Parol.create( 
                application: application,
                username: username,
                password: password
            )
        end

        desc "list", "Display all the accounts."
        long_desc <<-LONGDESC
            `parol list` List all the accounts from the database.
        LONGDESC
        def list

            sep   = "|".color(:aqua)
            lines = "-" * (5 + 20 + 20 + 20 + 5) # id, application, username, password, sep 
            lines = lines.color(:aqua)

            puts lines
            puts sep + "id".center(5).color(:green) + sep + \
                "Application/URL".center(20).color(:magenta) + sep + \
                "Username/Email".center(20).color(:blue) + sep + \
                "Password".center(20).color(:yellow) + sep
            puts lines

            Parol.all.each do |parol|

                shortcuts = -> (content, desired_length) {
                    # desired_length -= 3
                    content = content.length > desired_length ? content[0 ... desired_length] + "***" : content
                    content.center 20
                }

                puts sep + parol.id.to_s.center(5).color(:green) + sep + \
                    shortcuts.call(parol.application, 18).color(:magenta) + sep + \
                    shortcuts.call(parol.username, 18).color(:blue) + sep + \
                    shortcuts.call(parol.password, 5).color(:yellow) + sep
            end

            puts lines

        end

        desc "delete_all", "Delete all the accounts, this is not reversable."
        long_desc <<-LONGDESC
            `parol delete_all` Delete all the accounts from the database. This action is not reversable.
        LONGDESC
        def delete_all
            Parol.destroy_all
        end

        desc "show id", "Display details for the account <id>"
        long_desc <<-LONGDESC
            `parol show id` Display the account from the database, where id = <id>. 
        LONGDESC
        def show id
            parol = Parol.where(id: id).take
            if parol
                puts "id:              " + parol.id.to_s
                puts "Application/URL: " + parol.application
                puts "Username/Email:  " + parol.username
                puts "Password:        " + parol.password
            end
        end

        desc "delete id", "Delete the account for <id>"
        long_desc <<-LONGDESC
            `parol delete <id>` Delete the account from the database, where id = <id>. This action is not reversable.
        LONGDESC
        def delete id
            Parol.destroy(id)
        end

    end
end
