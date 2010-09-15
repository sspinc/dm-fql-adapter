require 'rubygems'
require 'bundler/setup'
require 'rake'

begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-fql-adapter'
    gem.summary     = 'FQL Adapter for DataMapper'
    gem.description = gem.summary
    gem.email       = 'gabor@secretsaucepartners.com'
    gem.homepage    = 'http://github.com/sspinc/%s' % gem.name
    gem.authors     = [ 'Gabor Ratky' ]
    gem.has_rdoc    = 'yard'

    gem.rubyforge_project = 'datamapper'

    gem.add_dependency 'dm-core', '~> 1.0.2'
    gem.add_dependency 'dm-types', '~> 1.0.2'
    gem.add_dependency 'sqldsl', '~> 1.4.6'
    gem.add_dependency 'mini_fb', '~> 1.1.3'
    
    gem.add_development_dependency 'rspec', '~> 1.3'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
