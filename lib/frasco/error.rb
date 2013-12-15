require 'Find'
require "thor"

module Frasco

  class FrascoError < StandardError

    def self.simulator_notfound_error
      self.new("simulator environment does not exists")
    end

    def self.snapshot_exists_error(snapshot)
      self.new("specified snapshot is already exists: #{snapshot.name}")
    end

    def self.snapshot_notfound_error(snapshot)
      self.new("no such snapshot: #{snapshot.name}")
    end
  
  end

end
