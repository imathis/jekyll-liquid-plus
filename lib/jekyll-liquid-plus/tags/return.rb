require File.join File.expand_path('../../', __FILE__), 'helpers/var'

module LiquidPlus
  class ReturnTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @markup = markup.strip
      super
    end

    def render(context)
      if parsed_markup = Conditional.parse(@markup, context)
        Var.get_value(parsed_markup, context)
      else
        ''
      end
    end
  end
end

