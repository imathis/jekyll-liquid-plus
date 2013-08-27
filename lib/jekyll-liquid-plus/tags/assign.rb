require File.join File.expand_path('../../', __FILE__), 'helpers/var'

module LiquidPlus
  class AssignTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @markup = markup
      super
    end

    def render(context)
      if c = Var.parse(@markup, context)
        context = c
      end
      ''
    end
  end
end

