require_relative "core.rb"
require "rainbow"

module Parol

    class CLI

        def initialize
            puts Rainbow("#####################").magenta
            puts Rainbow("#").magenta + Rainbow(" PAROL ").indianred + Rainbow("CLI Version ").green + Rainbow("#").magenta
            puts Rainbow("#####################").magenta

            @cmd = String.new
        end

        def main
            system "clear"

            while true
                puts Rainbow("\nCommands:").red.underline
                # puts Rainbow("  :read_only,  :ro").blue + "    Read a parol db file without modifying it"
                # puts Rainbow("  :read_write, :rw").blue + "    Read a parol db file and edit it"
                puts Rainbow("  :write,      :w ").blue  + "    Make a new parol db file"
                puts Rainbow("  :info,       :i ").blue  + "    Get info"
                puts Rainbow("  :github,     :gh").blue + "    Open Github page of Parol"
                puts Rainbow("  :exit,       :q ").blue  + "    Exit\n"

                @cmd = gets.chomp.to_s

                system "clear" # tmp

                case @cmd
                    when ":write", ":w"
                        CLI_W.new.main
                    when ":info", ":i"
                        info

                    when ":github", ":gh"
                        github

                    when ":exit", ":q"
                        exit
                end

            end
        end

        def info
            puts Rainbow("Core::Parol    ").yellow + Rainbow(" #{PAROL_VERSION}").silver
            puts Rainbow("Core::Parols   ").yellow + Rainbow(" #{PAROLS_VERSION}").silver
            puts Rainbow("Core::Parols_IO").yellow + Rainbow(" #{PAROLS_IO_VERSION}").silver
        end

        def github
            system "xdg-open https://github.com/Ogromny/parol"
        end

    end

    class CLI_W

        def initialize
            @parols = Parols.new
            @cmd    = String.new
        end

        def main
            while true
                puts Rainbow("\nCommands:").red.underline
                puts Rainbow("      :add,     :a").blue + "    Add"
                puts Rainbow("      :rm,      :r").blue + "    Remove"
                puts Rainbow("      :ls,      :l").blue + "    List"
                puts Rainbow("      :encrypt, :e").blue + "    Encrypt"
                puts Rainbow("      :save,    :s").blue + "    Save"
                puts Rainbow("      :exit,    :q").blue + "    Back to main menu\n"

                @cmd = gets.chomp.to_s

                system "clear" # tmp

                case @cmd
                    when ":add", ":a"
                        print Rainbow("Url, Link, Address: ").silver;        url      = gets.chomp.to_s
                        print Rainbow("Pseudo, User, Name, Email: ").silver; username = gets.chomp.to_s
                        print Rainbow("Password: ").silver;                  password = gets.chomp.to_s

                        @parols += Parol.new url, username, password

                    when ":rm", ":r"
                        print Rainbow("Index: ").silver; index = gets.chomp.to_i # need fix for nothing

                        @parols.rm index

                    when ":ls", ":l"
                        puts Rainbow(@parols.to_s).silver

                    when ":encrypt", ":e"
                        @parols.ncrypt!

                    when ":save", ":s"
                        print Rainbow("Enter the path for db: ").silver; path_db = gets.chomp.to_s
                        parols_io = Parols_IO.new path_db
                        parols_io.write @parols

                    when ":exit", ":q"
                        break
                end

            end

        end

    end

end

Parol::CLI.new.main
