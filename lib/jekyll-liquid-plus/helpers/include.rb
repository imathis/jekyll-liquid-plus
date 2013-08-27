require File.join File.expand_path('../../', __FILE__), 'helpers/path'

module LiquidPlus
  class Include
    LOCALS = /(.*?)(([\w-]+)\s*=\s*(?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w\.-]+)))(.*)?/

    class << self

      def render(markup, context)

        markup, params = split_params markup
        markup = Path.parse(markup, context, '_includes')

        if markup
          markup += params if params
          tag = Jekyll::Tags::IncludeTag.new('', markup, [])
          tag.render(context)
        end
      end

      def split_params(markup)
        params = nil
        if markup =~ LOCALS
          params = ' ' + $2
          markup = $1 + $7
        end
        [markup, params]
      end

    end
  end
end

