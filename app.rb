require 'active_record'
require 'sqlite3'
require 'thor'

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
    def add
        print "Application/URL: " 
        application = STDIN.gets.to_s.chomp
        print "Username/Email:  "
        username = STDIN.gets.to_s.chomp
        print "Password:        "
        password = STDIN.gets.to_s.chomp

        Parol.create( 
            application: application,
            username: username,
            password: password
        )
    end

    desc "show_all", "Montrer tout les comptes"
    def show_all

        sep   = "|"
        lines = "-" * (5 + 20 + 20 + 20 + 5) # id, application, username, password, sep 

        puts lines
        puts sep + "id".center(5) + sep + "Application/URL".center(20) + sep + "Username/Email".center(20) + sep + "Password".center(20) + sep
        puts lines

        Parol.all.each do |parol|

            shortcuts = -> (content, desired_length) {
                # desired_length -= 3
                content = content.length > desired_length ? content[0 ... desired_length] + "***" : content
                content.center 20
            }

            puts sep + parol.id.to_s.center(5) + sep + shortcuts.call(parol.application, 18) + sep + shortcuts.call(parol.username, 18) + sep + shortcuts.call(parol.password, 5) + sep
        end

        puts lines

    end

    desc "remove_all", "Supprimer tout les comptes"
    def remove_all
        Parol.destroy_all
    end

    desc "show id", "Voir en détail le compte ayant l'id 'id'"
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
    def remove id
        Parol.destroy(id)
    end

end

CLI.start ARGV