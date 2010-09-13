module DataMapper
  module Adapters
    class FqlAdapter < AbstractAdapter
      
      def initialize(name, options={})
        super
        self.resource_naming_convention = DataMapper::NamingConventions::Resource::Underscored
      end
      
      def session
        @session ||= options[:session] || MiniFB::OAuthSession.new(options[:access_token], options[:locale] || 'en_US')
      end

      def compile(query)
        Select[query.fields.map(&:name)].from[query.model.storage_name(name).to_sym].where do
          query.conditions.each do |condition|
            case condition
            when Query::Conditions::EqualToComparison then equal condition.subject.name, condition.value
            end
          end
        end.to_sql
      end

      def read(query)
        DataMapper.logger.debug(statement = compile(query))
        session.fql(statement)
      end
      
    end # class FqlAdapter
    
    const_added(:FqlAdapter)
  end # module Adapters
end # module DataMapper
