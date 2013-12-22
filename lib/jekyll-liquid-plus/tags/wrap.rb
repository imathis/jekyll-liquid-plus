require File.join File.expand_path('../../', __FILE__), 'helpers/include'

module LiquidPlus
  class WrapTag < Liquid::Block
    HAS_CONTENT = /(.*?)({=\s*yield\s*})(.*)/im

    def initialize(tag_name, markup, tokens)
      @tag = tag_name
      @markup = markup.strip
      super
    end

    def render(context)
      if super.strip =~ HAS_CONTENT
        front = $1
        back = $3

        partial = if @tag == 'wrap'
          tag = IncludeTag.new('render', @markup, [])
          tag.render(context)
        elsif @tag == 'wrap_include'
          Include.render(@markup, context)
        end

        if partial
          front + partial.strip + back
        else
          ''
        end
      else
        raise SyntaxError.new("Syntax Error in '#{@tag}' - Valid syntax: {% wrap_include template/file.html %}\n[<div>]{= yield }[</div>]\n{% end#{@tag} %}")
      end
    end
  end
end

