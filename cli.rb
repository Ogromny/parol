require_relative "core.rb"

cmd = String.new

puts "#####################"
puts "# PAROL CLI Version #"
puts "#####################"

def command cmd

    case cmd
    when ":read_only"; read_only
    when ":read_write"; read_write
    when ":write"; write
    when ":info"; info
    when ":github"; github
    when ":exit"; exit
    end

end

def write

    parols = Parol::Parols.new

    while true
        puts "      :add            Add"
        puts "      :rm             Remove"
        puts "      :ls             List"
        puts "      :encrypt        Encrypt"
        puts "      :save           Save"
        puts "      :exit           Back to main menu"
        puts ""

        cmd = gets.chomp

        case cmd
        when ":add"
            print "Url, Link, Address: "
            url = gets.chomp.to_s
            print "Pseudo, User, Name, Email: "
            username = gets.chomp.to_s
            print "Password: "
            password = gets.chomp.to_s

            parols += Parol::Parol.new url, username, password
        when ":rm"
            print "Index ?: "
            index = gets.chomp.to_i # fix nothing
            deleted = parols.rm index
            unless deleted == nil
                print "Deleted #{deleted}\n"
            else
                print "Not in range\n"
            end
        when ":ls"
            puts parols.to_s
        when ":encrypt"
            parols.ncrypt!
        when ":save"
            print "Enter the path for db: "
            path_db = gets.chomp.to_s
            parols_io = Parol::Parols_IO.new path_db
            parols_io.write parols
        when ":exit"; break
        end
    end

end

def read_write

end

def read_only
    puts "Please write the full path file (i.e /home/ogromny/parol.db): "
    db_pathname = gets.chomp.to_s

    print "Now I need the password (i.e SuperStrongPassword): "
    password    = gets.chomp.to_s

    print "#{db_pathname} :: #{password}"
end

def info
    puts "Core::Parol     #{Parol::PAROL_VERSION}"
    puts "Core::Parols    #{Parol::PAROLS_VERSION}"
    puts "Core::Parols_IO #{Parol::PAROLS_IO_VERSION}"
end

def github
    system "xdg-open https://github.com/Ogromny/parol"
end

while true

    puts ""
    puts "Commands:"
    puts "  :read_only      Read a parol db file without modifying it"
    puts "  :read_write     Read a parol db file and edit it"
    puts "  :write          Make a new parol db file"
    puts "  :info           Get info"
    puts "  :github         Open Github page of Parol"
    puts "  :exit           Exit"
    puts ""

    cmd = gets.chomp

    command cmd

end
