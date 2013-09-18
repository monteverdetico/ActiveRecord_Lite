require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key

  def other_class
    @other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @other_class_name = params[:class_name] || name.to_s.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || (name.to_s.camelize + "_id").to_sym
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] || name.to_s.singularize.camelize
    @primary_key = params[:primary_key] || :id

    foreign_key_default = (self_class.to_s.underscore + "_id").to_sym
    @foreign_key = params[:foreign_key] || foreign_key_default
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {}
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    assoc_params[name] = aps

    define_method(name) do
      query = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.primary_key} = ?
      SQL

      results = DBConnection.execute(query, self.id)

      aps.other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self.class)

    define_method(name) do
      query = <<-SQL
        SELECT DISTINCT *
        FROM #{aps.other_table}
        WHERE #{aps.other_table}.#{aps.foreign_key} = ?
      SQL

      results = DBConnection.execute(query, self.id)
      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    define_method(name) do
      params1 = self.class.assoc_params[assoc1]
      params2 = params1.other_class.assoc_params[assoc2]

      fk1 = self.send(params1.foreign_key)
      query = <<-SQL
        SELECT #{params2.other_table}.*
        FROM #{params1.other_table}
        JOIN #{params2.other_table}
          ON #{params1.other_table}.#{params2.foreign_key}
                = #{params2.other_table}.#{params2.primary_key}
        WHERE #{params1.other_table}.#{params1.primary_key} = ?
      SQL

      results = DBConnection.execute(query, fk1)
      params2.other_class.parse_all(results).first
    end
  end
end
