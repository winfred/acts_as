require "acts_as/version"

module ActsAs
  class ActsAs::ActiveRecordOnly < StandardError; end

  PREFIXED = %w(id created_at updated_at)
  ACTING_FOR = {}

  def self.included(base)
    base.extend ClassMethods
  end

  private

  def acts_as_field_match?(method)
    @association_match = ACTING_FOR.select do |association, fields|
      fields.select { |f| method.to_s.include?(f) }.any?
    end.keys.first
    @association_match && send(@association_match).respond_to?(method)
  end

  module ClassMethods
    def acts_as(one_association, prefixed: [])
      define_method(one_association) do |*args|
        super(*args) || send("build_#{one_association}", *args)
      end


      association_class = new.send(one_association).class
      if association_class.table_exists?

        whitelist_and_delegate_fields(association_class, one_association, prefixed)

        define_method :method_missing do |method, *args, &block|
          if acts_as_field_match?(method) then
            send(@association_match).send(method, *args, &block)
          else
            super(method, *args, &block)
          end
        end

        define_method :respond_to? do |method, *args, &block|
          acts_as_field_match?(method) || super(method, *args, &block)
        end
      end
    end


    private

    def whitelist_and_delegate_fields(association_class, one_association, prefixed)
      association_fields = association_class.columns.map(&:name) - PREFIXED - prefixed

      build_prefixed_methods(one_association, prefixed)

      attr_accessible *association_fields
      attr_accessible *prefixed.map { |field| "#{one_association}_#{field}" }

      delegate(*(association_fields + association_fields.map { |field| "#{field}=" }), to: one_association)

      #TODO: This feels like a weird place to remember delegated fields
      ACTING_FOR[one_association] = association_fields + prefixed
    end

    def build_prefixed_methods(one_association, prefixed)
      prefixed.each do |field|
        define_method("#{one_association}_#{field}") do |*args|
          send(one_association).send(field, *args)
        end

        define_method("#{one_association}_#{field}=") do |*args|
          send(one_association).send("#{field}=", *args)
        end
      end
    end
  end
end