require File.join File.expand_path('../../', __FILE__), 'helpers/conditional'

module LiquidPlus
  class CaptureTag < Liquid::Block
    WORD_REGEX = '[[:word:]]'
    SYNTAX = /(#{WORD_REGEX}+)\s*(\+=|\|\|=)?/o

    def initialize(tag_name, markup, tokens)
      @markup = markup
      super
    end

    def render(context)
      if @markup = Conditional.parse(@markup, context)
        if @markup.strip =~ SYNTAX
          @to = $1
          @operator = $2

          output = super
          if @operator == '+=' and !context.scopes.last[@to].nil?
            context.scopes.last[@to] += output.strip 
          elsif @operator.nil? or (@operator == '||=' and context.scopes.last[@to].nil?)
            context.scopes.last[@to] = output.strip
          end

        else
          raise SyntaxError.new("Syntax Error in 'capture' - Valid syntax: capture [var]")
        end
      end
      ''
    end
  end
end

