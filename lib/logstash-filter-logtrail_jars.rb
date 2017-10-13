# this is a generated file, to avoid over-writing it just delete this comment
begin
  require 'jar_dependencies'
rescue LoadError
  require 'org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar'
  require 'com/github/logtrail/tools/logstash-filter/1.0-SNAPSHOT/logstash-filter-1.0-SNAPSHOT.jar'
  require 'org/slf4j/slf4j-simple/1.7.25/slf4j-simple-1.7.25.jar'
end

if defined? Jars
  require_jar( 'org.slf4j', 'slf4j-api', '1.7.25' )
  require_jar( 'com.github.logtrail.tools', 'logstash-filter', '1.0-SNAPSHOT' )
  require_jar( 'org.slf4j', 'slf4j-simple', '1.7.25' )
end
