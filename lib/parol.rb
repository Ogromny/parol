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

            data << { app: app, login: login, password: password, comments: comments }

            Database.encrypt(data)
        end

        #[SkyzohKey] 1. Input the name of the app:
        #[SkyzohKey] 2. Input the login you use on this app
        #[SkyzohKey] 3. Would you like parol to generate a strong random password for you ? [Y/n]
        #[SkyzohKey] if Y → pass = random de 32
        #[SkyzohKey] if n → 3.1. Input the password related to this account:
        #[SkyzohKey] 4. Some notes about this account ?
        #[SkyzohKey] 5. Résumé du parol
        #[SkyzohKey] 6. Création + print l'id du parol

        desc 'list <index>', 'List a particular index, or everything if index is omitted.'
        def list(index = nil)
            if ! index.nil? # index is not nil
                index = Integer index rescue abort('please enter a number !')
                information = Database.decrypt[index] || abort('index does not exists !')
                say "[#{index}] #{information[:app]} -> #{information[:login]} : #{information[:password]} \t(#{information[:comments]})"
            else # list all
                Database.decrypt.each_with_index do |information, index|
                    say "[#{index}]" + information[:app] + ' -> ' + information[:login]
                end
            end
        end

        desc 'delete <index>', 'Delete a particular index.'
        def delete(index)
            index = Integer index rescue abort('index does not exists !')

            data = Database.decrypt

            data[index] || abort('index does not exists !')

            data.delete_at(index)

            Database.encrypt(data)
        end

    end
end