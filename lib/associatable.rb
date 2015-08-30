require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] || "#{name}".camelcase
    @foreign_key = options[:foreign_key] || "#{name}_id".underscore.to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || "#{name}".singularize.camelcase
    @foreign_key = options[:foreign_key] || "#{self_class_name.singularize.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]

      val = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => val).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]

      val = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => val)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      key_val = self.send(through_options.foreign_key)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{source_options.table_name}
        JOIN
          #{through_options.table_name}
        ON
          #{through_options.table_name}.#{source_options.foreign_key} =
            #{source_options.table_name}.#{source_options.primary_key}
        WHERE
          #{through_options.table_name}.#{through_options.primary_key} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      key_val = self.send(through_options.foreign_key)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{source_options.table_name}
        JOIN
          #{through_options.table_name}
        ON
          #{through_options.table_name}.#{source_options.foreign_key} =
            #{source_options.table_name}.#{source_options.primary_key}
        WHERE
          #{through_options.table_name}.#{through_options.primary_key} = ?
      SQL

      source_options.model_class.parse_all(results)
    end
  end
end
