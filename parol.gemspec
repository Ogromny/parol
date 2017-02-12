Gem::Specification.new do |s|
    s.name        = 'parol'
    s.version     = '3.5.1'
    s.date        = '2017-02-12'
    s.summary     = 'parol'
    s.description = 'A secure password manager'
    s.authors     = ['Ogromny']
    s.email       = 'ogromny@openmailbox.org'
    s.files       = %w(lib/parol.rb lib/parol/database.rb)
    s.homepage    = 'https://github.com/Ogromny/parol/'
    s.license     = 'MIT'
    s.add_dependency 'rbnacl-libsodium', '~> 0'
end