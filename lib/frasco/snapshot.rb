
module Frasco

  class Snapshot

    attr_reader :name, :path

    def initialize(root_dir, name)
      @name = name
      @path = "#{root_dir}/#{escaped_name}"
    end

    def escaped_name
      self.class.escape_name(@name)
    end

    def exists?
      File.exists?(@path)
    end


    def find_versions
      Dir.glob("#{path}/*").map {|path| File.basename(path) }.sort
    end


    class << self

      def escape_name(name)
        name.gsub(%r(/), '-##-')
      end

      def unescape_name(name)
        name.gsub(/-##-/, '/')
      end

    end

  end

end
