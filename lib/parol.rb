require_relative 'database'
require 'thor'

module Parol
    class Command < Thor

        desc 'create', 'Create a new account.'
        def create
            app      = ask('App (or URL):')
            login    = ask('Login:')
            password = ask('Password:')
            comments = ask('Comments:')

            data = Database.decrypt

            data <<
                {
                    app: app,
                    login: login,
                    password: password,
                    comments: comments
                }

            Database.encrypt data
        end

        #[SkyzohKey] 1. Input the name of the app:
        #[SkyzohKey] 2. Input the login you use on this app
        #[SkyzohKey] 3. Would you like parol to generate a strong random password for you ? [Y/n]
        #[SkyzohKey] if Y → pass = random de 32
        #[SkyzohKey] if n → 3.1. Input the password related to this account:
        #[SkyzohKey] 4. Some notes about this account ?
        #[SkyzohKey] 5. Résumé du parol
        #[SkyzohKey] 6. Création + print l'id du parol

        desc 'list <id>', 'List a particular id, or everything if id is omitted.'
        def list(id = nil)
            data = Database.decrypt

            # no id is transmitted
            if id.nil?
                data.each_with_index do |information, index|
                    say "[#{index}] #{information[:app]} -> #{information[:login]}"
                end
            # id exist
            elsif ! data[id.to_i].nil?
                id = id.to_i
                say "[#{id}] #{data[id][:app]} -> #{data[id][:login]} : #{data[id][:password]} (#{data[id][:comments]})"
            # id does not exist
            else
                say 'id does not exist!'
            end
        end

        desc 'delete <id>', 'Delete a particular id.'
        def delete(id)
            data = Database.decrypt

            # id exist
            unless data.nil? && ! data[id.to_i].nil?
                data.delete_at id.to_i
            end

            Database.encrypt data
        end

    end
end