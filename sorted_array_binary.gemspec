Gem::Specification.new do |s|
  s.name        = 'sorted_array_binary'
  s.version     = '0.0.2'
  s.date        = '2014-01-29'
  s.summary     = 'Sorted array'
  s.description = 'Sorted array using binary search'
  s.authors     = ['Dmitry Maksyoma']
  s.email       = 'ledestin@gmail.com'
  s.files       = `git ls-files`.split($\)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
  s.homepage    = 'https://github.com/ledestin/sorted_array_binary'

  s.add_development_dependency 'rspec', '>= 2.13'
  s.add_development_dependency 'hitimes', '~> 1.2'
end
