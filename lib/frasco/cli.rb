require "Find"
require "thor"
require "frasco/error"
require "frasco/snapshot"

module Frasco

  class CLI < Thor

    @@STASH_NAME = "__stashed"

    def initialize(*args)
      super(*args)

      @simulator_dir = File.expand_path("~/Library/Application Support/iPhone Simulator");
    end


    desc "init", "Create '.frasco' directory in current location"
    def init

      raise FrascoError.new("already initialized") \
        if File.exists?(".frasco")

      FileUtils.mkdir(".frasco")
    end


    desc "list", "Show saved snapshots"
    def list

      pattern = "#{_find_snapshots_dir}/*"

      Dir.glob(pattern).sort.map do |path|
        snapshot = _get_snapshot(Snapshot.unescape_name(File.basename(path)))

        puts "#{snapshot.name}\t(#{snapshot.find_versions.join(', ')})"

      end
    end


    desc "save <NAME>", "Save snapshot with specified snapshot"
    def save(name)

      raise FrascoError.simulator_notfound_error \
        unless File.exists?(@simulator_dir)

      snapshot = _get_snapshot(name)

      raise FrascoError.snapshot_exists_error(snapshot) \
        if snapshot.exists?

      _mkdir_parents(snapshot.path)

      FileUtils.copy_entry(@simulator_dir, snapshot.path)
    end


    desc "stash", "Backup current environment to stash, and destroy environment"
    def stash

      stash = _get_snapshot(@@STASH_NAME)

      raise FrascoError.simulator_notfound_error \
        unless File.exists?(@simulator_dir)

      raise FrascoError.new("already stashed") \
        if File.exists?(stash.path)

      _mkdir_parents(stash.path)

      FileUtils.move(@simulator_dir, stash.path)
    end


    desc "up <NAME>", "Backup current environment to stash, and restore snapshot"
    def up(name)

      snapshot = _get_snapshot(name)

      raise FrascoError.snapshot_notfound_error(snapshot) \
        unless snapshot.exists?

      stash

      FileUtils.copy_entry(snapshot.path, @simulator_dir)
    end


    desc "cleanup", "Destroy current simulator environment and restore stashed environment"
    def cleanup

      snapshot = _get_snapshot(@@STASH_NAME)

      raise FrascoError.new("not stashed") \
        unless snapshot.exists?

      # nothing if not eixsts simulator dir
      FileUtils.remove_dir(@simulator_dir) \
        if File.exists?(@simulator_dir)

      FileUtils.move(snapshot.path, @simulator_dir)

    end


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


    desc "remove <NAME>", "Remove snapshot"
    def remove(name)

      snapshot = _get_snapshot(name)

      raise FrascoError.snapshot_notfound_error(snapshot) \
        unless snapshot.exists?

      FileUtils.remove_dir(snapshot.path)
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

  end

end

