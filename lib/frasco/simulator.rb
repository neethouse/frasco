require "thor"
require "frasco/error"

module Frasco

  class Simulator

    @@SIMULATOR_PATH = "/Applications/Xcode.app/Contents/Applications/iPhone Simulator.app"

    def run

      raise FrascoError.new("Simulator not installed at '#{path}'") \
        unless File.exists?(@@SIMULATOR_PATH)

      `open "#{@@SIMULATOR_PATH}"`
    end


    def quit

      `killall 'iPhone Simulator'`

      while is_running?
        sleep(0.2)
      end
    end


    def is_running?
      !`ps x | grep "[i]Phone Simulator.app"`.empty?
    end

  end


  class SimulatorCLI < Thor

    DESC = "Operate simulator. Available subcommands: run/quit/state"

    def initialize(*args)
      super(*args)

      @simulator = Simulator.new
    end


    #######################################
    
    desc "run", "Run or activate simulator"

    def run_simulator
      @simulator.run
    end


    #######################################

    desc "quit", "Quit simulator"

    def quit

      raise FrascoError.new("Simulator is not running.") \
        unless @simulator.is_running?

      @simulator.quit
    end


    #######################################
    
    desc "state", "Show simulator state ('running' or 'not running')"

    def state
      if @simulator.is_running?
        puts "running"
      else
        puts "not running"
      end
    end

  end

end

