require 'active_record'
require 'sqlite3'

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