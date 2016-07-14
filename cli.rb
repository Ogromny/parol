require_relative "core.rb"

cmd = String.new

puts "#####################"
puts "# PAROL CLI Version #"
puts "#####################"

def command cmd

    case cmd
    when ":info"
        info
    when ":exit"
        exit
    end

end

def info
    puts "Core::Parol     #{Parol::PAROL_VERSION}"
    puts "Core::Parols    #{Parol::PAROLS_VERSION}"
    puts "Core::Parols_IO #{Parol::PAROLS_IO_VERSION}"
end

while true

    puts ""
    puts "Commands:"
    puts "  :info     Get info"
    puts "  :exit     Exit"
    puts ""

    cmd = gets.chomp

    command cmd

end
