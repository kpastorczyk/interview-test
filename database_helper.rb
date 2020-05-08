require 'active_record'
require 'enumerize'

module DatabaseHelper

  def initialize_in_memory_database
    # don't output all the migration activity
    ActiveRecord::Migration.verbose = false

    # switch the active database connection to an SQLite, in-memory database
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:', host: 'localhost')

    # execute the migration, creating a table (dirty_items) and columns (body, email, name)
    ActiveRecord::Schema.define(version: 1) do
      create_table :holidays do |t|
        t.date :day
        t.integer :kind
      end
    end
  end

  class Holiday < ActiveRecord::Base
    extend Enumerize

    validates :day, presence: true
    validate :check_day_is_sunday

    enumerize :kind, in: { custom: 0, non_working_sunday: 1 }

    def self.present_on?(day)
      Holiday.any? { |holiday| holiday.day == day.to_date }
    end

    private

    def check_day_is_sunday
      errors.add(:day, :invalid) unless day.sunday?
    end
  end
end


