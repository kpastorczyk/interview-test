require_relative '../interview-test/database_helper'

class CheckPossible
  include DatabaseHelper
  MON_SAT_SHOP_WORKING_HOURS_START = (ENV['MON_SAT_SHOP_WORKING_HOURS_START'] || 7).to_i
  MON_SAT_SHOP_WORKING_HOURS_END = (ENV['MON_SAT_SHOP_WORKING_HOURS_END'] || 20).to_i
  SUN_SHOP_WORKING_HOURS_START = (ENV['MON_SUN_SHOP_WORKING_HOURS_START'] || 10).to_i
  SUN_SHOP_WORKING_HOURS_END = (ENV['MON_SUN_SHOP_WORKING_HOURS_END'] || 15).to_i
  TIME_FOR_COURIER_DELIVERY_IN_HOURS = (ENV['TIME_FOR_COURIER_DELIVERY_IN_HOURS'] || 1).to_i

  def initialize(delivery_created_time, courier_delivery_time)
    @delivery_created_time = delivery_created_time
    @courier_delivery_time = courier_delivery_time
  end

  def call
    # order is possible to realise when time to courier delivery intersection with shop open time hour ranges is non-empty
    order_delivery_range = (delivery_created_time + TIME_FOR_COURIER_DELIVERY_IN_HOURS.hours..courier_delivery_time.to_time)
    shop_days_open_range_enumerator = (delivery_created_time.to_i..(courier_delivery_time.to_date.to_time + 1.day).to_i).step(1.day).map { |t| ::Time.at(t).to_datetime }

    shop_working_ranges = [].tap do |array|
      shop_days_open_range_enumerator.each do |shop_working_day|
        unless DatabaseHelper::Holiday.present_on?(shop_working_day)
          if shop_working_day.sunday?
            start_time = set_hour_to_time(time_or_day: shop_working_day, hour: SUN_SHOP_WORKING_HOURS_START)
            end_time = set_hour_to_time(time_or_day: shop_working_day, hour: SUN_SHOP_WORKING_HOURS_END)
            array << (start_time..end_time)
          else
            start_time = set_hour_to_time(time_or_day: shop_working_day, hour: MON_SAT_SHOP_WORKING_HOURS_START)
            end_time = set_hour_to_time(time_or_day: shop_working_day, hour: MON_SAT_SHOP_WORKING_HOURS_END)
            array << (start_time..end_time)
          end
        end
      end
    end

    shop_working_ranges.any? { |shop_working_range| time_ranges_overlapped?(shop_working_range, order_delivery_range) }
  end

  private

  attr_accessor :delivery_created_time, :courier_delivery_time

  def time_ranges_overlapped?(range_a, range_b)
    start_a = range_a.first
    end_a = range_a.last
    start_b = range_b.first
    end_b = range_b.last
    (start_a <= end_b) && (end_a >= start_b)
  end

  def set_hour_to_time(time_or_day:, hour:)
    Time.new(time_or_day.year, time_or_day.month, time_or_day.day, hour, 0, 0, '+02:00')
  end
end
