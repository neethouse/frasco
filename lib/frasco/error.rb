require 'Find'
require "thor"

module Frasco

  class FrascoError < StandardError

    def self.simulator_notfound_error(simulator)
      self.new("no such version's simulator environment: ios_ver=#{simulator.ios_ver}")
    end

    def self.snapshot_exists_error(snapshot)
      self.new("specified snapshot is already exists: #{snapshot.ios_ver}/#{snapshot.name}")
    end

    def self.snapshot_notfound_error(snapshot)
      self.new("no such snapshot: ios_ver=#{snapshot.ios_ver}, name=#{snapshot.name}")
    end
  
  end

end
