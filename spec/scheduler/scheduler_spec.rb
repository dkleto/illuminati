require 'scheduler_helper'

describe Illuminati::Scheduler do
  let(:job1_hash) {
    {
      :on => true,
      :bri => 255,
      :hue => 10000,
      :sat => 100,
      :transitiontime => 0,
      :alert => 'none',
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
      :on => false,
      :transitiontime => 0,
      :time => DateTime.now + 2,
      :repeat => false
    }
  }
  let(:job3_hash) {
    {
      :on => true,
      :bri => 100,
      :xy => [0.5, 0.8],
      :transitiontime => 0,
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
      :on => false,
      :transitiontime => 10,
      :time => DateTime.now + 0.5
    }
  }
  context 'with no schedule events' do
    it 'does not schedule any changes' do
      event_count_before = Rufus::Scheduler.singleton.at_jobs.count
      Illuminati::Scheduler.new(Rufus::Scheduler.singleton)
      event_count_after = Rufus::Scheduler.singleton.at_jobs.count
      expect(event_count_after).to eq(event_count_before)
    end
  end
  context 'with schedule events' do
    before do |each|
      @s = Rufus::Scheduler.singleton
      @scheduler = Illuminati::Scheduler.new(@s)
      @job1 = Illuminati::Models::Schedule.create!(job1_hash)
      @job2 = Illuminati::Models::Schedule.create!(job2_hash)
      @job3 = Illuminati::Models::Schedule.create!(job3_hash)
      @job4 = Illuminati::Models::Schedule.create!(job4_hash)
      @f_string = "%F%H-%M%z"
    end
    it 'schedules once-off jobs' do
      event_count_before = @s.at_jobs.count
      @scheduler.sync
      event_count_after = @s.at_jobs.count
      expect(event_count_after).to eq(event_count_before + 2)
      # Both job2 and job4 should be scheduled.
      [@job2[:time], @job4[:time]].each do |time|
        expect(@s.at_jobs.find do |job|
                  job.time.strftime(@f_string) == time.strftime(@f_string)
               end
              ).to_not be_nil
      end
    end
    it 'schedules repeat jobs' do
      event_count_before = @s.cron_jobs.count
      @scheduler.sync
      event_count_after = @s.cron_jobs.count
      expect(event_count_after).to eq(event_count_before + 2)
      # The next scheduled cron job should be job1.
      [@job1[:time]].each do |time|
        expect(@s.cron_jobs.find do |job|
                  job.next_time.strftime(@f_string) == time.strftime(@f_string)
               end
              ).to_not be_nil
      end
    end
    it 'clears all jobs' do
      @s.at (DateTime.now + 1).to_s do
        puts 'test'
      end
      @s.cron "* * * * *", :first_at => (DateTime.now + 1).to_s do
        puts 'test'
      end
      @scheduler.clear
      expect(@s.jobs.count).to eq(0)
    end
  end
end
