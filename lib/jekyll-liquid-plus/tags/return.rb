require File.join File.expand_path('../../', __FILE__), 'helpers/var'

module LiquidPlus
  class ReturnTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @markup = markup.strip
      super
    end

    def render(context)
      if @markup = Conditional.parse(@markup, context)
        Var.get_value(@markup, context)
      else
        ''
      end
    end
  end
end

