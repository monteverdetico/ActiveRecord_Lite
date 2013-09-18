require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable, Associatable

  def self.set_table_name(table_name)
    @table = table_name
  end

  def self.table_name
    @table
  end

  def self.all
    # returns an array of hashes
    rows = DBConnection.execute("SELECT * FROM #{self.table_name}")

    self.parse_all(rows)
  end

  def self.find(id)
    query = "SELECT * FROM #{self.table_name} WHERE id = ?"
    obj = DBConnection.execute(query, id)
    self.new(obj.first)
  end

  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  protected

  def attribute_values
    values = self.class.attributes.map { |attribute| send(attribute) }
  end

  def create

    columns = self.class.attributes.map { |attr| attr.to_s }.join(", ")
    num_attr = self.class.attributes.count
    question_marks = (['?'] * num_attr).join(", ")
    values = self.attribute_values

    query = <<-SQL
      INSERT INTO #{self.class.table_name} (#{columns})
      VALUES (#{question_marks})
    SQL

    DBConnection.execute(query, *values)

    id = DBConnection.last_insert_row_id
    self.id = id
  end

  def update
    set_attrs = self.class.attributes.map do |attribute|
      "#{attribute} = ?"
    end.join(", ")
    values = self.attribute_values

    query = <<-SQL
      UPDATE #{self.class.table_name}
      SET #{set_attrs}
      WHERE id = #{self.id}
    SQL

    DBConnection.execute(query, *values)
  end
end
