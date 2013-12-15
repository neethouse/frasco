
module Frasco

  class Snapshot

    attr_reader :ios_ver, :name, :path

    def initialize(root_dir, ios_ver, name, escaped=false)
      @ios_ver = ios_ver
      @name = escaped ? self.class.unescape_name(name) : name

      @path = "#{root_dir}/#{@ios_ver}/#{escaped_name}"
    end

    def to_s
      '%6s/%s' % [@ios_ver, @name]
    end

    def escaped_name
      self.class.escape_name(@name)
    end

    def exists?
      File.exists?(@path)
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
