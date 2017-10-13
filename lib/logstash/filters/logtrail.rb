# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "json"
require 'logstash-filter-logtrail_jars.rb'

java_import "com.github.logtrail.tools.LogProcessor"

# Logtrail filter to add logtrail specific fields to event based on the patterns file
class LogStash::Filters::Logtrail < LogStash::Filters::Base

	config_name "logtrail"

	# Path to patterns file
	config :es_hosts,  :validate => :array, :default => ["http://localhost:9200"]
	config :message_field, :validate => :string, :default => "message"
	config :context_field, :validate => :string
	config :index_pattern, :validate => :string, :default => "logstash-*"

	public
	def register

		@processor = com.github.logtrail.tools.LogProcessor.new(es_hosts, index_pattern)
		@processor.init()

	end # def register

	public
	def filter(event)

		context = event.get(@context_field)
		message = event.get(@message_field)
		parsed_info = @processor.process(message,context)
		if parsed_info
			event.set('lt',parsed_info)
		end

		# filter_matched should go in the last line of our successful code
		filter_matched(event)
	end # def filter

end # class LogStash::Filters::Logtrail
