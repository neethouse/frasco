
module Frasco

  class Simulator

    attr_reader :ios_ver, :path

    def initialize(root_dir, ios_ver)
      @ios_ver = ios_ver

      @path = "#{root_dir}/#{@ios_ver}"
    end

    def exists?
      File.exists?(@path)
    end

  end

end

