require_relative './db_connection'

module Searchable
  def where(params)
    where_clause = Array.new
    params.each_key { |param| where_clause << "#{param} = ?"}

    query = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{where_clause.join(" AND ")}
    SQL

    results = DBConnection.execute(query, *params.values)
    self.parse_all(results)
  end
end