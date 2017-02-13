Gem::Specification.new do |s|
    s.name        = 'parol'
    s.version     = '3.5.2'
    s.date        = '2017-02-13'
    s.summary     = 'parol'
    s.description = 'A secure password manager'
    s.authors     = ['Ogromny']
    s.email       = 'ogromny@openmailbox.org'
    s.files       = %w(lib/parol.rb lib/parol/database.rb)
    s.homepage    = 'https://github.com/Ogromny/parol/'
    s.license     = 'MIT'
    s.add_runtime_dependency 'rbnacl-libsodium', '~> 1.0', '>= 1.0.11'
end