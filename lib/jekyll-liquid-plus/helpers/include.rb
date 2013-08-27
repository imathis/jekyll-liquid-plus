require File.join File.expand_path('../../', __FILE__), 'helpers/path'

module LiquidPlus
  class Include
    LOCALS = /(.*?)(([\w-]+)\s*=\s*(?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w\.-]+)))(.*)?/

    class << self

      def render(markup, context)

        markup, params = split_params markup
        file = Path.parse(markup, context, '_includes')

        if file
          if File.exist? Path.expand(File.join('_includes', file), context)
            markup = file
            markup += params if params
            tag = Jekyll::Tags::IncludeTag.new('', markup, [])
            tag.render(context)
          else
            dir = '_includes'
            dir = File.join dir, File.dirname(file) unless File.dirname(file) == '.'

            msg  = "From #{context.registers[:page]['path']}: "
            msg += "File '#{file}' not found"
            msg += " in '#{dir}/' directory"

            puts msg.red
            return msg
          end
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

