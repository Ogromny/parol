require 'active_record'

module Parol

    class Database

        ActiveRecord::Base.establish_connection(
            adapter: 'sqlite3',
            database: (ENV['HOME'] + '/.config/parol/parol.sqlite3')
        )

        if ! ActiveRecord::Base.connection.data_sources.include? 'parols'
            ActiveRecord::Schema.define do
                create_table :parols do |table|
                    table.binary :app
                    table.binary :usr
                    table.binary :pwd
                    table.binary :cmt
                end
            end
            puts 'Enter password for the database, and remember it !!! ( must be 32 of length ): '
        else
            puts 'Password of the database: '
        end

    end

    class Parol < ActiveRecord::Base; end

end