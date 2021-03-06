require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(hash={})
    hash.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
        column_names << column["name"]
    end

    column_names.compact
  end

end
