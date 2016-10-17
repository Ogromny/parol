require_relative 'database'
require 'thor'
require 'orpg'

module Parol
    class Command < Thor

        desc 'create', 'Create a new account.'
        def create
            app      = ask('1. Input the name of the app/url:')
            login    = ask('2. Input the login you use on this app/url:')
            password = yes?('3. Would you like parol to generate a strong random password for you ? [y/n]')

            if password
                password = ORPG::ORPG.generate(16, {number: true, lowercase: true, uppercase: true, special: true})
                say("pass = #{password}")
            else
                password = ask('3.1. Input the password related to this account:')
            end

            comments = yes?('4. Some notes about this account ? [y/n]')

            if comments
                comments = ask('notes:')
            else
                comments = ''
            end

            say("app: #{app}\nlogin: #{login}\npassword: #{password}\nnotes: #{comments}")

            data = Database.decrypt

            data << { app: app, login: login, password: password, comments: comments }

            Database.encrypt(data)
        end

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