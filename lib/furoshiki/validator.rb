module Furoshiki
  class Validator
    def initialize(config)
      @config = config
      @errors = []
    end

    attr_reader :config

    def valid?
      reset_and_validate
      return errors.empty?
    end

    def reset_and_validate
      @errors.clear
      validate if respond_to? :validate
    end

    def errors
      @errors.dup
    end

    def error_message_list
      @errors.map {|m| "  - #{m}"}.join("\n")
    end

    def working_dir
      @config.working_dir
    end

    private
    def add_error(message)
      @errors << message
    end

    def add_missing_file_error(value, description)
      message = "#{description} configured as '#{value}', but couldn't find file at #{working_dir.join(value.to_s)}"
      add_error(message)
    end
  end
end
