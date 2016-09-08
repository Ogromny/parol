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
        parols_brut = Parol.all
        parols = Array.new

        parols_brut.each do |parol|
            application = parol.application
            application = application[0..20] + "..." if application.length > 20

            username = parol.username 
            username = username[0..15]  + "..." if username.length > 15

            password = parol.password
            password = password[0..5] + "..." if password.length > 5

            parols << [
                parol.id,
                application,
                username,
                password
            ]
        end

        parols.each do |parol|
            puts parol.join("|")
        end
    end

    desc "remove_all", "Supprimer tout les comptes"
    def remove_all
        Parol.destroy_all
    end

    desc "show id", "Voir en détail le compte ayant l'id 'id'"
    def show id
        parol = Parol.where(id: id).take
        puts "id:              " + parol.id.to_s
        puts "Application/URL: " + parol.application
        puts "Username/Email:  " + parol.username
        puts "Password:        " + parol.password
    end

    desc "remove id", "Supprimer le compte ayant l'id 'id'"
    def remove id
        Parol.where(id: id).destroy
    end

end

CLI.start ARGV