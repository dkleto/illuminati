require 'scheduler_helper'

describe Illuminati::Scheduler do
  let(:job1_hash) {
    {
      :command => 'command1',
      :transition_time => 2,
      :time => DateTime.now + 1,
      :repeat => true,
      :cron_minute => '30',
      :cron_hour => '*',
      :cron_day => '*',
      :cron_month => '*',
      :cron_weekday => '*'
    }
  }
  let(:job2_hash) {
    {
      :command => 'command2',
      :transition_time => 0,
      :time => DateTime.now + 1,
      :repeat => false
    }
  }
  let(:job3_hash) {
    {
      :command => 'command3',
      :transition_time => 0,
      :time => DateTime.now - 1,
      :repeat => true,
      :cron_minute => '30',
      :cron_hour => '17',
      :cron_day => '*',
      :cron_month => '*',
      :cron_weekday => '1,6'
    }
  }
  let(:job4_hash) {
    {
      :command => 'command4',
      :transition_time => 10,
      :time => DateTime.now - 1
    }
  }
  context 'with no schedule jobs' do
    it 'does not schedule any changes' do
      event_count_before = Rufus::Scheduler.singleton.at_jobs.count
      Illuminati::Scheduler.new(Rufus::Scheduler.singleton)
      event_count_after = Rufus::Scheduler.singleton.at_jobs.count
      expect(event_count_after).to eq(event_count_before)
    end
  end
  context 'with schedule jobs' do
    before do |each|
      @job1 = Illuminati::Models::Schedule.create!(job1_hash)
      @job2 = Illuminati::Models::Schedule.create!(job2_hash)
      @job3 = Illuminati::Models::Schedule.create!(job3_hash)
      @job4 = Illuminati::Models::Schedule.create!(job4_hash)
    end
    it 'schedules once-off jobs on initialisation' do
      event_count_before = Rufus::Scheduler.singleton.at_jobs.count
      Illuminati::Scheduler.new(Rufus::Scheduler.singleton)
      event_count_after = Rufus::Scheduler.singleton.at_jobs.count
      expect(event_count_after).to eq(event_count_before + 1)
    end
    it 'schedules repeat jobs on initialisation' do
      event_count_before = Rufus::Scheduler.singleton.cron_jobs.count
      Illuminati::Scheduler.new(Rufus::Scheduler.singleton)
      event_count_after = Rufus::Scheduler.singleton.cron_jobs.count
      expect(event_count_after).to eq(event_count_before + 1)
    end
  end
end
