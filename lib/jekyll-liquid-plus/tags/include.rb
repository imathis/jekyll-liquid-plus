require File.join File.expand_path('../../', __FILE__), 'helpers/include'

module LiquidPlus
  class IncludeTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @markup = markup.strip
      super
    end

    def render(context)
      Include.render(@markup, context)
    end
  end
end

