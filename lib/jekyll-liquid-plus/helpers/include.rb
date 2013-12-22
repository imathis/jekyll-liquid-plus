require File.join File.expand_path('../../', __FILE__), 'helpers/path'

module LiquidPlus
  class Include
    LOCALS = /(.*?)(([\w-]+)\s*=\s*(?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w\.-]+)))(.*)?/
    class << self

      def render(markup, context)
        tag = IncludeTag.new('include', markup, [])
        tag.render(context)
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

