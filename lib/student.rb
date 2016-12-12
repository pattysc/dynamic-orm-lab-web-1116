require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert}
    (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    keyinfo = nil
    valueinfo = nil

    attr.each do |key, value|
      keyinfo = key
      valueinfo = value
    end

    sql = <<-SQL
      SELECT *
      FROM #{self.table_name}
      WHERE #{keyinfo} = ?
    SQL

    found = DB[:conn].execute(sql, valueinfo)
    found
  end
end
