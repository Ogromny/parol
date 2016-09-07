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
        puts "Application/URL" 
        application = STDIN.gets.to_s.chomp
        puts "Username/Email"
        username = STDIN.gets.to_s.chomp
        puts "Password"
        password = STDIN.gets.to_s.chomp

        Parol.create( 
            application: application,
            username: username,
            password: password
        )
    end

end

CLI.start ARGV