# To keep the Ruby 1.9 compatibility, we have to vendor String.constantize.
# This patch can be removed when dropping support for Ruby 1.9. (replace with .const_get)
module Pundit
  module Inflector
    def self.constantize(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          # Go down the ancestors to check it it's owned
          # directly before we reach Object or the end of ancestors.
          constant = constant.ancestors.inject do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end
  end
end

class String
  # vendored constantize method from activesupport/inflector
  # only defined if not already present on String
  def constantize
    Pundit::Inflector.constantize(self)
  end unless method_defined?(:constantize)
end
