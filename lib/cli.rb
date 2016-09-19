require 'thor'
require_relative 'base_crypt'

module Parol

    class CLI < Thor

        desc 'new', 'Add a new account.'
        def new
            application = ask 'Application/URL: ', ($config['color'].downcase == 'on' ? :magenta : nil)
            username    = ask 'Username/Email:  ', ($config['color'].downcase == 'on' ? :blue    : nil)
            password    = ask 'Password:        ', ($config['color'].downcase == 'on' ? :yellow  : nil)

            parol = Crypt.encrypt [application, username, password]

            Parol.create(parol)
        end

        desc 'show id', 'Display details for the account <id>'
        def show id
            parol = Parol.where(id: id).take

            exit unless parol

            separator = set_color '|',  ($config['color'].downcase == 'on' ? :cyan : nil)
            lines     = set_color ('-' * 70),  ($config['color'].downcase == 'on' ? :cyan : nil)

            parol_array = [parol.id, parol.application, parol.username, parol.password]

            parol_decrypted = Crypt.decrypt(parol_array)

            id = set_color parol_decrypted[0].center(5),  ($config['color'].downcase == 'on' ? :green : nil)
            au = set_color parol_decrypted[1].center(62),  ($config['color'].downcase == 'on' ? :magenta : nil)
            ue = set_color parol_decrypted[2].center(68),  ($config['color'].downcase == 'on' ? :blue : nil)
            pw = set_color parol_decrypted[3].center(68),  ($config['color'].downcase == 'on' ? :yellow : nil)

            say lines
            say "#{separator}#{id}#{separator}#{au}#{separator}"
            say lines
            say "#{separator}#{ue}#{separator}"
            say "#{separator}#{pw}#{separator}"
            say lines
        end

        desc 'list', 'Display all the accounts.'
        def list
            shortcuts = lambda { |c, d| (c.length>d ? c[0...d]+'...' : c).center(20) }
            separator = set_color '|', ($config['color'].downcase == 'on' ? :cyan : nil)
            lines     = set_color ('-' * 70), ($config['color'].downcase == 'on' ? :cyan : nil)

            id = set_color 'id'.center(5), ($config['color'].downcase == 'on' ? :green : nil)
            au = set_color 'Application/URL'.center(20), ($config['color'].downcase == 'on' ? :magenta : nil)
            ue = set_color 'Username/Email'.center(20), ($config['color'].downcase == 'on' ? :blue : nil)
            pw = set_color 'Password'.center(20), ($config['color'].downcase == 'on' ? :yellow : nil)

            say lines
            say "#{separator}#{id}#{separator}#{au}#{separator}#{ue}#{separator}#{pw}#{separator}"
            say lines

            Parol.all.each do |parol|

                parol_array = [parol.id, parol.application, parol.username, parol.password]

                parol_decrypted = Crypt.decrypt(parol_array)

                parol_decrypted[0] = parol_decrypted[0].center 5
                parol_decrypted[1] = shortcuts.call parol_decrypted[1], 17
                parol_decrypted[2] = shortcuts.call parol_decrypted[2], 17
                parol_decrypted[3] = shortcuts.call parol_decrypted[3], 5

                parol_decrypted[0] = set_color parol_decrypted[0], ($config['color'].downcase == 'on' ? :green : nil)
                parol_decrypted[1] = set_color parol_decrypted[1], ($config['color'].downcase == 'on' ? :magenta : nil)
                parol_decrypted[2] = set_color parol_decrypted[2], ($config['color'].downcase == 'on' ? :blue : nil)
                parol_decrypted[3] = set_color parol_decrypted[3], ($config['color'].downcase == 'on' ? :yellow : nil)

                say "#{separator}#{parol_decrypted[0]}#{separator}#{parol_decrypted[1]}#{separator}#{parol_decrypted[2]}#{separator}#{parol_decrypted[3]}#{separator}"
                
            end

            say lines
        end

        desc 'delete id', 'Delete the account for <id>, or <all> for everything'
        def delete id
            if id.downcase == 'all'
                Parol.destroy_all
            else
                Parol.destroy(id)
            end
        end

        desc 'color on/off', 'Set the color <on> or <off>.'
        def color on_or_off
            if on_or_off.downcase == 'on'
                $config['color'] = 'on'
            else
                $config['color'] = 'off'
            end
            Config.save $config.to_yaml
        end

        desc 'password on/off', 'Save password <on> or <off>'
        def password on_or_off
            if on_or_off.downcase == 'on'
                $config['password'] = $password
            else
                $config['password'] = 'off'
            end
            Config.save $config.to_yaml
        end

        desc 'delete_db', 'Delete the database irreversible action !'
        def delete_db
            password_confirmation = ask 'Password: ', :red
            if $password == password_confirmation
                File.delete(ENV['HOME'] + '/.config/parol/parol.sqlite3')
            else
                say 'Aborted!'
            end
        end

        desc 'default_config', 'Set default config'
        def default_config
            $config = Hash.new
            $config['color'] = 'off'
            $config['password'] = 'off'
            Config.save $config.to_yaml
        end

        desc 'github', 'Open githut page of parol'
        def github
            link = 'https://github.com/Ogromny/parol'
            if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
                system "start #{link}"
            elsif RbConfig::CONFIG['host_os'] =~ /darwin/
                system "open #{link}"
            else
                system "xdg-open #{link}"
            end
        end

        desc 'backup_database', 'Make a backup of the database.'
        def backup_database
            FileUtils.copy ENV['HOME'] + '/.config/parol/parol.sqlite3', ENV['HOME'] + '/.config/parol/parol.backup.sqlite3'
            puts 'Backup to: ', ENV['HOME'] + '/.config/parol/parol.backup.sqlite3'
        end
    end
end