require "Find"
require "thor"
require "frasco/version"
require "frasco/error"
require "frasco/snapshot"
require "frasco/simulator"

module Frasco

  module PresetMethodOption

    def preset_method_option(*options)

      if options.include?(:quit)
        method_option :quit,
          :type => :boolean,
          :aliases => "-q",
          :desc => "Quit simulator before execute command."
      end

    end

  end


  class CLI < Thor

    extend PresetMethodOption

    package_name :frasco

    @@STASH_NAME = "__stashed"

    def initialize(*args)
      super(*args)

      @simulator_dir = File.expand_path("~/Library/Application Support/iPhone Simulator");
    end


    #######################################

    desc "setup", "Create '.frasco' directory in home directory"
    def setup

      raise FrascoError.new("already initialized") \
        if File.exists?(_default_frasco_dir)

      FileUtils.mkdir(_default_frasco_dir)
    end


    #######################################

    desc "list", "Show saved snapshots"

    def list

      pattern = "#{_find_snapshots_dir}/*"

      Dir.glob(pattern).sort.map do |path|
        snapshot = _get_snapshot(Snapshot.unescape_name(File.basename(path)))

        puts "#{snapshot.name}\t(#{snapshot.find_versions.join(', ')})"

      end
    end


    #######################################

    desc "save <NAME>", "Save snapshot with specified snapshot"

    preset_method_option :quit

    def save(name)

      _before_bang_command

      raise FrascoError.simulator_notfound_error \
        unless File.exists?(@simulator_dir)

      snapshot = _get_snapshot(name)

      raise FrascoError.snapshot_exists_error(snapshot) \
        if snapshot.exists?

      _mkdir_parents(snapshot.path)

      FileUtils.copy_entry(@simulator_dir, snapshot.path)
    end


    #######################################

    desc "stash", "Backup current environment to stash, and destroy environment"

    preset_method_option :quit

    def stash

      _before_bang_command

      stash = _get_snapshot(@@STASH_NAME)

      raise FrascoError.simulator_notfound_error \
        unless File.exists?(@simulator_dir)

      raise FrascoError.new("already stashed") \
        if File.exists?(stash.path)

      _mkdir_parents(stash.path)

      FileUtils.move(@simulator_dir, stash.path)
    end


    #######################################

    desc "up <NAME>", "Backup current environment to stash, and restore snapshot"

    preset_method_option :quit

    def up(name)

      _before_bang_command

      snapshot = _get_snapshot(name)

      raise FrascoError.snapshot_notfound_error(snapshot) \
        unless snapshot.exists?

      stash

      FileUtils.copy_entry(snapshot.path, @simulator_dir)
    end


    #######################################

    desc "cleanup", "Destroy current simulator environment and restore stashed environment"

    preset_method_option :quit

    def cleanup

      _before_bang_command

      snapshot = _get_snapshot(@@STASH_NAME)

      raise FrascoError.new("not stashed") \
        unless snapshot.exists?

      # nothing if not eixsts simulator dir
      FileUtils.remove_dir(@simulator_dir) \
        if File.exists?(@simulator_dir)

      FileUtils.move(snapshot.path, @simulator_dir)

    end


    #######################################

    desc "rename <ORG_NAME> <NEW_NAME>", "Change snapshot name"
    def rename(org_name, new_name)

      org_snapshot = _get_snapshot(org_name)

      raise FrascoError.snapshot_notfound_error(org_snapshot) \
        unless File.exists?(org_snapshot.path)

      new_snapshot = _get_snapshot(new_name)

      raise FrascoError.snapshot_exists_error(new_snapshot) \
        if File.exists?(new_snapshot.path)

      FileUtils.move(org_snapshot.path, new_snapshot.path)
    end


    #######################################

    desc "remove <NAME>", "Remove snapshot"
    def remove(name)

      snapshot = _get_snapshot(name)

      raise FrascoError.snapshot_notfound_error(snapshot) \
        unless snapshot.exists?

      FileUtils.remove_dir(snapshot.path)
    end


    #######################################

    desc "archive <NAME> <ARCHIVE-FILE>", "Archive snapshot of tar.gz"

      method_option :overwrite,
        :type => :boolean,
        :aliases => "-f",
        :desc => "Overwrite exists archive file"

    def archive(name, archive_path)

      snapshot = _get_snapshot(name)

      raise FrascoError.snapshot_notfound_error(snapshot) \
        unless snapshot.exists?

      raise FrascoError.new("speficied archive file is already exists: #{archive_path}\nOverwrite with -f/--overwrite option.") \
        if File.exists?(archive_path) && !options["overwrite"]

      archive_path = File.absolute_path(archive_path)

      system("cd '#{snapshot.path}' && tar czf '#{archive_path}' .")

    end


    #######################################

    desc "up-archive <ARCHIVE-FILE>", "Backup current environment to stash, and restore archived snapshot"

    preset_method_option :quit

    def up_archive(archive_path)

      _before_bang_command

      raise FrascoError.new("no such file: #{archive_path}") \
        unless File.exists?(archive_path)

      stash

      system("mkdir '#{@simulator_dir}' && tar xzf '#{archive_path}' -C '#{@simulator_dir}'")

    end


    #######################################
    
    desc "simulator [COMMAND]", SimulatorCLI::DESC

    def simulator(*args)
      Frasco::SimulatorCLI.start(args)
    end

    
    #######################################

    desc "version", "Show version"

    def version
      @shell.say("frasco version #{Frasco::VERSION} (c) 2013 neethouse.org")
    end


    #######################################

    # Raise error if simulator is already running.
    # Quit simulator if specified --quit option, and continue.
    private
    def _before_bang_command

      simulator = Simulator.new

      if simulator.is_running?
        if options[:quit]
          simulator.quit
        else
          raise FrascoError.new("Simulator is running. Quit with --quit option.")
        end
      end
    end


    private
    def _get_snapshot(name)
      Snapshot.new(_find_snapshots_dir, name)
    end


    # Create parent directories of specified path.
    private
    def _mkdir_parents(path)
      basedir = File.dirname(path)
      FileUtils.mkdir_p(basedir) unless File.exists?(basedir)
    end


    # Returns $FRASCO_DIR or $HOME/.frasco
    # Raise an error when .frasco dir is not exists.
    private
    def _find_frasco_dir

      dir = ENV["FRASCO_DIR"] || _default_frasco_dir

      raise FrascoError.new("frasco is not setup\nPlease execute 'frasco setup' command.") \
        unless File.exists?(dir)

      dir
    end

    private
    def _default_frasco_dir
      "#{Dir::home}/.frasco"
    end

    private
    def _find_snapshots_dir
      _find_snapshots_dir = "#{_find_frasco_dir}/snapshots"
    end

  end

end

