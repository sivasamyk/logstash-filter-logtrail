# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "json"

# Logtrail filter to add logtrail specific fields to event based on the patterns file
class LogStash::Filters::Logtrail < LogStash::Filters::Base

	config_name "logtrail"

	# Path to patterns file
	config :patterns_file, :validate => :string
	config :message_field, :validate => :string, :default => "message"
	config :context_field, :validate => :string
	config :pre_tag, :validate => :string, :default => "logtrail.pre"
	config :post_tag, :validate => :string, :default => "logtrail.post"

	public
	def register
		#read patterns 
		@patterns = Hash.new {|h,k| h[k] = Array.new}
		patterns_json = JSON.parse(File.read(@patterns_file))
		patterns_count = 0
		for pattern_json in patterns_json
			if (pattern_json['args'].length > 0 )
				if ( pattern_json['context'] ) 
					@patterns[pattern_json['context']].push pattern_json
					patterns_count = patterns_count + 1
				else 
					@logger.warn("Cannot find context key for #{pattern_json}")
				end
			end
		end
		@logger.info("Loaded #{patterns_count} patterns from #{@patterns_file}")
	end # def register

	public
	def filter(event)

		context = event.get(@context_field)
		message = event.get(@message_field)
		parsed_log = parse_message(context,message)
		if parsed_log
#			event.set('logtrail_message',parsed_log.pattern)
#			event.set('logtrail_message',parsed_log.encoded_message)
#			event.set('logtrail_messageId', parsed_log.messageId)
			event.set('logtrail_groups',parsed_log.groups)
			event.set('logtrail_pattern',parsed_log.pattern)
		end

		# filter_matched should go in the last line of our successful code
		filter_matched(event)
	end # def filter

  private
  def encode_log_message(message,match_data)
  	encoded_message = message.dup
		match_indices = []
		1.upto(match_data.size-1).to_a.map { |i| 
			match_index = MatchIndex.new(match_data.begin(i), match_data.end(i) -1)
			match_indices.push match_index
		}

		(1..match_indices.length).each do |m|
			match_index = match_indices.pop
			encoded_message.insert(match_index.end_index + 1, @post_tag)
			encoded_message.insert(match_index.begin_index, @pre_tag)
		end
		return encoded_message
  end 

  private
	def parse_message(context,message)
		patterns_for_context = @patterns[context]
		if !patterns_for_context
		  patterns_for_context = @patterns['default-conetxt']
		end
		if patterns_for_context
		  for pattern in patterns_for_context
		    match_data = message.match(pattern['messageRegEx'])
		    if match_data
		    	metric.increment(:matches)
		      @logger.debug("message |#{message}| pattern |#{pattern}| captures |#{match_data.captures}|")
		      if (match_data.captures.length == 0)
		        groups = nil
		        return nil
		      else
		        groups = Hash[ match_data.names.zip( match_data.captures ) ]
		        encoded_message = encode_log_message(message,match_data)
		        @logger.debug("encoded_message |#{encoded_message}| pattern |#{pattern}| groups |#{groups}|")
			      parsed_log = ParsedLog.new(pattern['messageId'],encoded_message,pattern['messageRegEx'],groups)
			      return parsed_log
		      end
		    end
		  end
		end
		return nil
	end

end # class LogStash::Filters::Logtrail

class MatchIndex 
	attr_reader :begin_index, :end_index
	def initialize(begin_index,end_index)
		@begin_index = begin_index
		@end_index = end_index
	end
end

class ParsedLog
	attr_reader :messageId, :encoded_message, :pattern, :groups
	def initialize(messageId,encoded_message,pattern,groups)
		@messageId = messageId
		@encoded_message = encoded_message
		@pattern = pattern
		@groups = groups
	end
end
