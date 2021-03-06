# encoding: utf-8
require 'eventmachine'
require_relative './collection'

module CartoDB
  module Synchronizer
    class Runner
      TICK_TIME_IN_SECS = 10
      RUN_FOREVER       = 0

      attr_reader :ticks

      def initialize(job_collection=Collection.new, options={})
        @job_collection     = job_collection
        @max_ticks          = options.fetch(:max_ticks, RUN_FOREVER)
        @tick_time_in_secs  = options.fetch(:tick_time_in_secs, TICK_TIME_IN_SECS)
        @ticks              = 0
        puts "max_ticks:#{@max_ticks} tick_time_in_secs:#{@tick_time_in_secs}"
      end #initialize

      def run
        EventMachine.run do
          EventMachine::PeriodicTimer.new(tick_time_in_secs) do
            stop_if_max_ticks_reached
            puts Time.now.utc.iso8601 + ': Fetching job_collection'
            job_collection.fetch
          end
        end
      end #run

      private

      def stop_if_max_ticks_reached
        return self if max_ticks == RUN_FOREVER

        self.ticks = ticks + 1
        if ticks >= max_ticks
          puts "Max ticks (#{max_ticks}) reached, stopping"
          EventMachine.stop
        end
      end #stop_if_max_ticks_reached

      attr_reader :max_ticks, :tick_time_in_secs, :job_collection
      attr_writer :ticks
    end # Runner
  end # Syncronizer
end # CartoDB

