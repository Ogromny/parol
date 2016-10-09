Gem::Specification.new do |s|
    s.name        = 'parol'
    s.version     = '3.0.0'
    s.date        = '2016-10-10'
    s.summary     = 'parol'
    s.description = 'A simple and secure CLI password manager'
    s.authors     = ['Ogromny']
    s.email       = 'ogromny@openmailbox.org'
    s.files       = Dir.glob "{lib}/**/*"
    s.homepage    = 'https://github.com/Ogromny/parol/'
    s.license     = 'MIT'
    s.executables << 'parol'
    s.add_dependency 'activerecord', '~> 5.0', '>= 5.0.0'
    s.add_dependency 'thor', '~> 0.19', '>= 0.19.1'
    s.add_dependency 'rbnacl-libsodium', '~> 0'
end