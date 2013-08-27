require File.join File.expand_path('../../', __FILE__), 'helpers/path'

module LiquidPlus
  class ExistsTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @file = markup.strip
      super
    end

    def render(context)
      File.exist? Path.expand(@file, context)
    end
  end
end

