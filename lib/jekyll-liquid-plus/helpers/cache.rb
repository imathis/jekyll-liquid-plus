module LiquidPlus
  class Cache
    def self.exists(path)
      @exists ||= {}
      @exists[path] ||= File.exist? path
    end
  end
end
