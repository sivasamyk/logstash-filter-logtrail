# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/logtrail"

describe LogStash::Filters::Logtrail do
  describe "Test log message to pattern without groups" do
    subject(:event) {LogStash::Event.new({
      "message" => "Enabling CORS for HTTP endpoint",
      "clazz" => "org.graylog2.shared.initializers.AbstractJerseyService"
    })}
    
    let(:plugin) {
      LogStash::Filters::Logtrail.new(
        "patterns_file" => "/tmp/patterns.json",
        "message_field" => "message",
        "context_field" => "clazz"
      )
    }

    before do
      plugin.register
      plugin.filter(event)
    end

    it "Should not extract any patterns" do
      expect(subject.get('logtrail_pattern')).to eq(nil)
      expect(subject.get('logtrail_groups')).to eq(nil)
    end
  end

  describe "Test match with groups. Should extact" do
    subject(:event) {LogStash::Event.new({
      "message" => "Started REST API at <http://localhost:8000>",
      "clazz" => "org.graylog2.shared.initializers.RestApiService"
    })}
    
    let(:plugin) {
      LogStash::Filters::Logtrail.new(
        "patterns_file" => "/tmp/patterns.json",
        "message_field" => "message",
        "context_field" => "clazz"
      )
    }

    before do
      plugin.register
      plugin.filter(event)
    end

    it "should match pattern and extract groups" do
      expect(subject.get('logtrail_pattern')).to eq('Started REST API at \\<(?<arg1>[\\S]+)\\>')
      expect(subject.get('logtrail_message')).to eq('Started REST API at <<em>http://localhost:8000</em>>')
      expect(subject.get('logtrail_groups')).to eq({"arg1"=>"http://localhost:8000"})
    end
  end

end
