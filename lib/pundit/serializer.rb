module Pundit
  module Serializer

    def to_h
      hash = Hash.new
      serialize_queries.each do |query|
        if self.respond_to?(query)
          hash[query.to_s.gsub('?','').to_sym] = self.public_send(query)
        end
      end
      hash
    end

    def serialize_queries
      @serialize_queries ||= self.public_methods.delete_if do |pm|
        not self.method(pm).owner.to_s.match(/.*Policy$/) or not pm.to_s.match(/.*\?$/)
      end.sort
    end

  end
end
