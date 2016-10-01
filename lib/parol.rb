require 'thor'
require_relative 'database'
require_relative 'crypt'

module Parol

    class Command < Thor

        desc 'create', 'Create a new account.'
        def create
            app, usr, pwd, cmt = ask('App (or URL): '), ask('User: '), ask('Pass: '), ask('Comments: ')
            Parol.new(Crypt.encrypt(app, usr, pwd, cmt)).save
        end

        desc 'list <id>', 'List a particular id, or everything if id is omitted.'
        def list(id = nil)
            if Parol.exists?(id) # id
                parol = Parol.where(id: id).take
                decrypted = Crypt.decrypt(parol.app, parol.usr, parol.pwd, parol.cmt)

                puts 'App (or URL): ' + decrypted[:app]
                puts 'User: ' + decrypted[:usr]
                puts 'Pass: ' + decrypted[:pwd]
                puts 'Comments: ' + decrypted[:cmt]
            else # all
                Parol.all.each do |parol|
                    decrypted = Crypt.decrypt(parol.app, parol.usr, parol.pwd, parol.cmt)
                    puts "|#{parol.id.to_s.center(5)}|#{decrypted[:app].center(20)}|#{decrypted[:usr].center(20)}|#{decrypted[:pwd][0..5] + '...'}|"
                end
            end
        end

        desc 'delete <id>', 'Delete a particular id.'
        def delete(id)
            Parol.destroy(id) if Parol.exists?(id)
        end

    end

end