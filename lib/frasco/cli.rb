require "Find"
require "thor"
require "frasco/error"
require "frasco/snapshot"
require "frasco/simulator"

module Frasco

  class CLI < Thor

    @@STASH_NAME = "__stashed"

    def initialize(*args)
      super(*args)
    end


    desc "init", "Create '.frasco' directory in current location"
    def init
      FileUtils.mkdir(".frasco")
    end


    desc "versions", "Show exists simulator environment versions"
    def versions

      pattern = "#{_find_simulators_dir}/*"

      Dir.glob(pattern).sort.map do |path|
        puts File.basename(path)
      end
    end


    desc "list [IOS_VER]", "Show saved snapshots"
    def list(ios_ver="*")

      pattern = "#{_find_snapshots_dir}/#{ios_ver}/*"

      Dir.glob(pattern).sort.map do |path|
        snapshot = _get_snapshot(
          File.basename(File.dirname(path)),
          File.basename(path),
          true)

        puts snapshot

      end
    end


    desc "save <IOS_VER> <SNAPSHOT_NAME>", "Save specified version's and name snapshot"
    def save(ios_ver, name)

      simulator = _get_simulator(ios_ver)
      snapshot = _get_snapshot(ios_ver, name)

      raise FrascoError.simulator_notfound_error(simulator) \
        unless simulator.exists?

      raise FrascoError.snapshot_exists_error(snapshot) \
        if snapshot.exists?

      _mkdir_parents(snapshot.path)

      FileUtils.copy_entry(simulator.path, snapshot.path)
    end


    desc "stash <IOS_VER>", "Backup current environment to stash, and destroy environment"
    def stash(ios_ver)

      simulator = _get_simulator(ios_ver)
      stash = _get_snapshot(ios_ver, @@STASH_NAME)

      raise FrascoError.simulator_notfound_error(simulator) \
        unless simulator.exists?

      raise FrascoError.new("already stashed: ios_ver=#{ios_ver}") \
        if File.exists?(stash.path)

      _mkdir_parents(stash.path)

      FileUtils.move(simulator.path, stash.path)
    end


    desc "up <IOS_VER> <NAME>", "Backup current environment to stash, and restore snapshot"
    def up(ios_ver, name)

      snapshot = _get_snapshot(ios_ver, name)

      raise FrascoError.snapshot_notfound_error(snapshot) \
        unless snapshot.exists?

      stash(ios_ver)

      simulator = _get_simulator(ios_ver)

      FileUtils.copy_entry(snapshot.path, simulator.path)
    end


    desc "cleanup <IOS_VER>", "Destroy current simulator environment and restore stashed environment"
    def cleanup(ios_ver)

      snapshot = _get_snapshot(ios_ver, @@STASH_NAME)

      raise FrascoError.new("not stashed: ios_ver=#{ios_ver}") \
        unless snapshot.exists?

      simulator = _get_simulator(ios_ver)

      # nothing if not eixsts simulator dir
      FileUtils.remove_dir(simulator.path) \
        if simulator.exists?

      FileUtils.move(snapshot.path, simulator.path)

    end


    desc "rename <IOS_VER> <ORG_NAME> <NEW_NAME>", "Change snapshot name"
    def rename(ios_ver, org_name, new_name)

      org_snapshot = _get_snapshot(ios_ver, org_name)

      raise FrascoError.snapshot_notfound_error(org_snapshot) \
        unless File.exists?(org_snapshot.path)

      new_snapshot = _get_snapshot(ios_ver, new_name)

      raise FrascoError.snapshot_exists_error(new_snapshot) \
        if File.exists?(new_snapshot.path)

      FileUtils.move(org_snapshot.path, new_snapshot.path)
    end


    desc "remove <IOS_VER> <NAME>", "Remove snapshot"
    def remove(ios_ver, name)

      snapshot = _get_snapshot(ios_ver, name)

      raise FrascoError.snapshot_notfound_error(snapshot) \
        unless snapshot.exists?

      FileUtils.remove_dir(snapshot.path)
    end


    private
    def _get_snapshot(ios_ver, name, escaped=false)
      Snapshot.new(_find_snapshots_dir, ios_ver, name, escaped)
    end


    private
    def _get_simulator(ios_ver)
      Simulator.new(_find_simulators_dir, ios_ver)
    end


    # Create parent directories of specified path.
    private
    def _mkdir_parents(path)
      basedir = File.dirname(path)
      FileUtils.mkdir_p(basedir) unless File.exists?(basedir)
    end


    # Find .frasco directory from current dir to parent.
    private
    def _find_frasco_dir

      dir = Dir::pwd

      while !File::exists? frasco_dir = dir + "/.frasco"
        dir = File::expand_path("..", dir);
        raise FrascoError.new(".frasco directory not exists\nPlease execute 'frasco init' command.") if dir == "/"
      end

      frasco_dir
    end

    private
    def _find_snapshots_dir
      _find_snapshots_dir = "#{_find_frasco_dir}/snapshots"
    end

    private
    def _find_simulators_dir
      File.expand_path("~/Library/Application Support/iPhone Simulator");
    end

  end

end

