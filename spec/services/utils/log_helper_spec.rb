require 'rails_helper'


RSpec.describe Utils::LogHelper do
  let(:dummy_class) do
    Class.new do
      include Utils::LogHelper

      def log_context
        {  a: 1 }
      end
    end
  end

  let(:instance) { dummy_class.new }

  describe "#log_context" do
    it "returns a hash with the class name" do
      expect(instance.send(:log_context)).to eq({ a: 1 })
    end
  end

  describe "#log" do
    let(:logger) { double("Logger") }

    before do
      allow(Rails).to receive(:logger).and_return(logger)
    end

    it "logs with default severity (warn) and params" do
      expect(logger).to receive(:warn).with(/class:.*, a: 1, foo: \"bar\"}/)
      instance.send(:log, foo: "bar")
    end

    it "logs with specified severity" do
      expect(logger).to receive(:info).with(/{class:.*, a: 1, foo: \"blerg\"}/)
      instance.send(:log, severity: :info, foo: "blerg")
    end

    it "logs error details and sets severity to error if exception is given" do
      error = StandardError.new("ut oh")
      expect(logger).to receive(:error).with(
        /a: 1, error_class: "StandardError", error_message: "ut oh"/
      )
      instance.send(:log, e: error)
    end

    it "handles logging errors gracefully" do
      allow(logger).to receive(:warn).and_raise(StandardError.new("logger fail"))
      expect(logger).to receive(:error).with(/Logging error: logger fail/)
      expect { instance.send(:log, foo: "bar") }.not_to raise_error
    end
  end
end
