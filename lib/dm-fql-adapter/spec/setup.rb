require 'dm-fql-adapter'
require 'dm-core/spec/setup'

module DataMapper
  module Spec
    module Adapters

      class FqlAdapter < Adapter
        def connection_uri
          "https://graph.facebook.com"
        end
      end

      use FqlAdapter

    end
  end
end
