require File.join File.expand_path('../../', __FILE__), 'helpers/conditional'

module LiquidPlus
  class Var
    SYNTAX = /(#{Liquid::VariableSignature}+)\s*(=|\+=|\|\|=)\s*(.*)\s*/o

    class << self
      def parse(markup, context)
        if markup = Conditional.parse(markup, context)
          if markup =~ SYNTAX
            @to = $1
            @operator = $2
            @from = $3

            value = get_value(@from, context)

            if @operator == '+=' and !context.scopes.last[@to].nil?
              context.scopes.last[@to] += value
            elsif @operator == '=' or (@operator == '||=' and context.scopes.last[@to].nil?)
              context.scopes.last[@to] = value
            end
            context
          else
            raise SyntaxError.new("Syntax Error in 'assign' - Valid syntax: assign [var] = [source]")
          end
        end
      end

      def determine_value(vars, context)
        vars.each do |var|
          rendered = var.render(context)
          return rendered unless rendered.nil?
        end
        nil
      end

      def get_value(vars, context)
        vars = vars.gsub(/ or /, ' || ')
        vars = vars.strip.split(/ \|\| /).map do |v|
          Liquid::Variable.new(v.strip)
        end
        determine_value(vars, context)
      end
    end
  end
end

