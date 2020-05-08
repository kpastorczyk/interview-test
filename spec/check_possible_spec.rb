require_relative '../check_possible'
require_relative '../database_helper'


RSpec.describe CheckPossible do
  include DatabaseHelper
  before(:all) do
    initialize_in_memory_database
    DatabaseHelper::Holiday.create day: Date.new(2019, 5, 12), kind: :non_working_sunday
  end

  subject { described_class.new(delivery_created_time, courier_delivery_time) }

  context 'order created at monday 08:29, for wednesday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 7, 8, 29, 0, '+02:00') }  # monday
    let(:courier_delivery_time) { Time.new(2019, 5, 9, 22, 29, 0, '+02:00') } # wednesday

    it { expect(subject.call).to be_truthy }
  end
  context 'order created at monday 08:29, for monday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 7, 8, 29, 0, '+02:00') }  # monday
    let(:courier_delivery_time) { Time.new(2019, 5, 7, 22, 29, 0, '+02:00') } # wednesday

    it { expect(subject.call).to be_truthy }
  end
  context 'order created at monday 22:29, for wednesday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 7, 8, 29, 0, '+02:00') }  # monday
    let(:courier_delivery_time) { Time.new(2019, 5, 9, 22, 29, 0, '+02:00') } # wednesday

    it { expect(subject.call).to be_truthy }
  end
  context 'order created at monday 20:29, for monday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 7, 20, 29, 0, '+02:00') } # monday
    let(:courier_delivery_time) { Time.new(2019, 5, 7, 22, 29, 0, '+02:00') } # wednesday

    it { expect(subject.call).to be_falsey }
  end
  context 'order created at monday 21:29, for monday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 7, 21, 29, 0, '+02:00') } # monday
    let(:courier_delivery_time) { Time.new(2019, 5, 7, 22, 29, 0, '+02:00') } # wednesday

    it { expect(subject.call).to be_falsey }
  end
  context 'order created at saturday 18:59, for sunday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 11, 18, 59, 0, '+02:00') } # saturday
    let(:courier_delivery_time) { Time.new(2019, 5, 12, 22, 29, 0, '+02:00') } # sunday, non-working

    it { expect(subject.call).to be_truthy }
  end
  context 'order created at saturday 19:01, for sunday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 11, 19, 1, 0, '+02:00') }  # saturday
    let(:courier_delivery_time) { Time.new(2019, 5, 12, 22, 29, 0, '+02:00') } # sunday, non-working

    it { expect(subject.call).to be_falsey }
  end
  context 'order created at sunday 08:01, for sunday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 12, 8, 0o1, 0, '+02:00') } # saturday
    let(:courier_delivery_time) { Time.new(2019, 5, 12, 22, 29, 0, '+02:00') } # sunday, non-working

    it { expect(subject.call).to be_falsey }
  end
  context 'order created at friday 16:59, for sunday 22:29' do
    let(:delivery_created_time) { Time.new(2019, 5, 10, 16, 59, 0, '+02:00') } # saturday
    let(:courier_delivery_time) { Time.new(2019, 5, 12, 22, 29, 0, '+02:00') } # sunday, non-working

    it { expect(subject.call).to be_truthy }
  end
  context 'order created at sunday 16:59, for monday 05:01' do
    let(:delivery_created_time) { Time.new(2020, 5, 3, 16, 59, 0, '+02:00') }
    let(:courier_delivery_time) { Time.new(2020, 5, 4, 5, 0o1, 0, '+02:00') }

    it { expect(subject.call).to be_falsey }
  end
end
