module Pundit
  class Configuration
    def suffix
      @suffix ||= "Policy".freeze
    end

    def suffix=(suffix)
      @suffix = suffix.freeze
    end
  end
end
