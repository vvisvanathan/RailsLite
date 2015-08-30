require_relative 'db_connection'
require_relative './searchable'
require_relative './associatable'
require 'active_support/inflector'

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    column_names = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    .first.map(&:to_sym)

    column_names
  end

  def self.finalize!
    self.columns.each do |column_name|

      define_method(column_name) { attributes[column_name] }

      define_method("#{column_name}=") do |val|
        attributes[column_name] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute2(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    SQL

    self.parse_all(results.drop(1))
  end

  def self.parse_all(results)
    results.map do |params|
      self.new(params)
    end
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    WHERE
      id = ?
    SQL

    return nil if results.length < 1

    self.new(results.first)
  end

  def initialize(params = {})
    params.each do |name, value|
      raise "unknown attribute '#{name}'" unless self.class.columns.include?(name.to_sym)
      self.send("#{name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |name| self.send("#{name}") }
  end

  def insert
    col_names = self.class.columns
    col_values = attribute_values
    question_marks = (["?"] * col_values.length).join(',')

    DBConnection.execute(<<-SQL, *col_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names.join(',')})
      VALUES
        (#{question_marks})
    SQL

    self.send('id=', DBConnection.last_insert_row_id)
  end

  def update
    col_row = self.class.columns.map { |col_name| "#{col_name} = ?" }.join(',')
    col_values = attribute_values

    DBConnection.execute(<<-SQL, *col_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_row}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.send("id").nil?
      insert
    else
      update
    end
  end
end
