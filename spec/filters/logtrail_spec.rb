# encoding: utf-8
require_relative '../spec_helper'
require "logstash/filters/logtrail"

describe LogStash::Filters::Logtrail do
  describe "Test log message to pattern without groups" do
    subject(:event) {LogStash::Event.new({
      "message" => "This is a sample log without arguments",
      "clazz" => "SampleLogger"
    })}
    
    let(:plugin) {
      LogStash::Filters::Logtrail.new(
        "message_field" => "message",
        "context_field" => "clazz"
      )
    }

    before do
      plugin.register
      plugin.filter(event)
    end

    it "Should not extract any matchIndices" do
      logtrail_data = subject.get('logtrail')
      logtrail_data.should_not be_nil
      logtrail_data['patternId'].should_not be_nil
      logtrail_data['matchIndices'].should be_nil
    end
  end

  describe "Test match with groups. Should extact" do
    subject(:event) {LogStash::Event.new({
      "message" => "This is logger with string arguments Hello",
      "clazz" => "SampleLogger"
    })}
    
    let(:plugin) {
      LogStash::Filters::Logtrail.new(
        "message_field" => "message",
        "context_field" => "clazz"
      )
    }

    before do
      plugin.register
      plugin.filter(event)
    end

    it "should match pattern and extract groups" do
      logtrail_data = subject.get('logtrail')
      logtrail_data.should_not be_nil
      logtrail_data['patternId'].should_not be_nil
      logtrail_data['matchIndices'].should_not be_nil
      expect(logtrail_data['matchIndices']).to eq("37,42")
    end
  end

  describe "No match test" do
    subject(:event) {LogStash::Event.new({
      "message" => "This pattern is not present in patterns db",
      "clazz" => "SampleLogger"
    })}
    
    let(:plugin) {
      LogStash::Filters::Logtrail.new(
        "message_field" => "message",
        "context_field" => "clazz"
      )
    }

    before do
      plugin.register
      plugin.filter(event)
    end

    it "should not return any data" do
      logtrail_data = subject.get('logtrail')
      logtrail_data.should_not nil
    end
  end

end
