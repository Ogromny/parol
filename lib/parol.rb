require 'active_record'
require 'thor'
require 'rainbow/ext/string'

module Parol
    ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: 'parol.sqlite3'
    )

    unless ActiveRecord::Base.connection.data_sources.include? 'parols'
        ActiveRecord::Schema.define do
            create_table :parols do |t|
                t.string :application
                t.string :username
                t.string :password
            end
        end
    end

    class Parol < ActiveRecord::Base

        self.table_name = "parols"

    end

    class CLI < Thor

        desc "add", "Ajouter un nouveau compte"
        long_desc <<-LONGDESC
            `parol add` Ajoute un nouveau compte et l'enregistre dans parol.sqlite3
        LONGDESC
        def add
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

        desc "show_all", "Montrer tout les comptes"
        long_desc <<-LONGDESC
            `parol show_all` Montre tout les comptes enregistrés dans parol.sqlite3
        LONGDESC
        def show_all

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

        desc "remove_all", "Supprimer tout les comptes"
        long_desc <<-LONGDESC
            `parol remove_all` Détruit de facon irrémediable tout les comptes enregistrés dans parol.sqlite3 
        LONGDESC
        def remove_all
            Parol.destroy_all
        end

        desc "show id", "Voir en détail le compte ayant l'id 'id'"
        long_desc <<-LONGDESC
            `parol show id` Montre en détail le compte avec l'id `id` enregistré dans parol.sqlite3
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

        desc "remove id", "Supprimer le compte ayant l'id 'id'"
        long_desc <<-LONGDESC
            `parol remove_all` Détruit de facon irrémediable le compte avec l'id `id` enregistré dans parol.sqlite3 
        LONGDESC
        def remove id
            Parol.destroy(id)
        end

    end
end
