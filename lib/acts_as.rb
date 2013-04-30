require "acts_as/version"

module ActsAs
  class ActsAs::ActiveRecordOnly < StandardError; end

  PREFIX = %w(id created_at updated_at)

  def self.included(base)
    base.extend ClassMethods
  end

  private

  def acts_as_field_match?(method)
    @association_match = self.class.acts_as_fields.select do |association, fields|
      fields.select { |f| method.to_s.include?(f) }.any?
    end.keys.first
    @association_match && send(@association_match).respond_to?(method)
  end

  module ClassMethods
    def acts_as(association, with: [], prefix: [], foreign_key: true, **options)
      foreign_key ? belongs_to(association, **options) : has_one(association, **options)
      define_method(association) { |*args| super(*args) || send("build_#{association}", *args) }

      if (association_class = new.send(association).class).table_exists?
        whitelist_and_delegate_fields(association_class, association, prefix, with)
        override_method_missing
      end
    end

    def acts_as_fields
      @acts_as_fields ||= {}
    end

    private

    def override_method_missing
      define_method :method_missing do |method, *args, &block|
        if acts_as_field_match?(method)
          send(@association_match).send(method, *args, &block)
        else
          super(method, *args, &block)
        end
      end

      define_method :respond_to? do |method, *args, &block|
        acts_as_field_match?(method) || super(method, *args, &block)
      end
    end

    def whitelist_and_delegate_fields(association_class, one_association, prefix, with)
      association_fields = association_class.columns.map(&:name) - PREFIX - prefix + with

      build_prefix_methods(one_association, prefix)

      attr_accessible *association_fields
      attr_accessible *prefix.map { |field| "#{one_association}_#{field}" }

      delegate(*(association_fields + association_fields.map { |field| "#{field}=" }), to: one_association)

      #TODO: This feels like a weird place to remember delegated fields
      acts_as_fields[one_association] = association_fields + prefix
    end

    def build_prefix_methods(one_association, prefix)
      prefix.each do |field|
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