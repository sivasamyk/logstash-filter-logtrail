Gem::Specification.new do |s|
  s.name          = 'logstash-filter-logtrail'
  s.version       = '0.1.0'
  s.licenses      = ['MIT']
  s.summary       = 'Logtrail filter plugin'
  s.description   = 'Lookup for matches in pattern file'
  s.homepage      = 'http://www.github.com'
  s.authors       = ['skaliappan']
  s.email         = 'sivasamyk@gmail.com'
  s.require_paths = ['lib','vendor/jar-dependencies/runtime-jars']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"

  #jar
  s.requirements << "jar 'com.github.logtrail.tools:logstash-filter', '1.0-SNAPSHOT'"
  s.add_runtime_dependency 'jar-dependencies', "0.3.11"

  s.add_development_dependency 'logstash-devutils', "~> 1.3"

  s.platform = 'java'
end
