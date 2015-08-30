require_relative 'db_connection'

module Searchable
  def where(params)
    where_string = params.map { |name, value| "#{name} = ?" }.join(" AND ")
    params = params.map { |name, value| value }

    results = DBConnection.execute(<<-SQL, *params)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL

    results.map do |params|
      self.new(params)
    end
  end
end
