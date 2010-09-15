module DataMapper
  module Adapters
    class NotSupportedError < Exception; end

    class FqlAdapter < AbstractAdapter
      
      def initialize(name, options={})
        super
        self.resource_naming_convention = DataMapper::NamingConventions::Resource::Underscored
      end
      
      def session
        @session ||= options[:session] || MiniFB::OAuthSession.new(options[:access_token], options[:locale] || 'en_US')
      end

      def compile(query)
        raise NotSupportedError, 'A query must contain at least one condition.' if query.conditions.empty?
        raise NotSupportedError, 'A query must include at least one indexed column in its conditions.' unless query.conditions.map(&:subject).any? { |property| property.index }
        statement = Select[query.fields.map(&:name)].from[query.model.storage_name(name).to_sym].where do
          query.conditions.each do |condition|
            column, value = condition.subject.name, condition.value
            case condition
            when Query::Conditions::EqualToComparison then equal column, value
            when Query::Conditions::GreaterThanComparison then greater_than column, value
            when Query::Conditions::GreaterThanOrEqualToComparison then greater_than_or_equal column, value
            when Query::Conditions::LessThanComparison then less_than column, value
            when Query::Conditions::LessThanOrEqualToComparison then less_than_or_equal column, value
            when Query::Conditions::InclusionComparison then is_in column, value
            when Query::Conditions::LikeComparison then raise NotSupportedError, 'Like comparisons are not supported in FQL.'
            when Query::Conditions::RegexpComparison then raise NotSupportedError, 'Regular expression comparisons are not supported in FQL.'
            end
          end
        end
        unless query.order.length == 1 && query.order.first.target.key?
          query.order.each do |direction|
            statement.order_by(direction.target.name)
          end
        end
        statement.to_sql
      end

      def read(query)
        DataMapper.logger.debug(statement = compile(query))
        session.fql(statement)
      end
      
      def select(fql)
        session.fql(fql)
      end
      
    end # class FqlAdapter
    
    const_added(:FqlAdapter)
  end # module Adapters
end # module DataMapper
