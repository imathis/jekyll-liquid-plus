# Title: Render Partial Tag for Jekyll
# Author: Brandon Mathis
# Description: Import files on your filesystem into any blog post and render them inline.
# Note: Paths are relative to the source directory, if you import a file with yaml front matter, the yaml will be stripped out.
#
# Syntax {% render_partial path/to/file %}
#
# Example 1:
# {% render_partial about/_bio.markdown %}
#
# This will import source/about/_bio.markdown and render it inline.
# In this example I used an underscore at the beginning of the filename to prevent Jekyll
# from generating an about/bio.html (Jekyll doesn't convert files beginning with underscores)
#
# Example 2:
# {% render_partial ../README.markdown %}
#
# You can use relative pathnames, to include files outside of the source directory.
# This might be useful if you want to have a page for a project's README without having
# to duplicated the contents
#
#

require File.join File.expand_path('../../', __FILE__), 'helpers/path'
require File.join File.expand_path('../../', __FILE__), 'helpers/include'
require 'jekyll'
require 'pathname'

module Jekyll

  # Create a new page class to allow partials to trigger Jekyll Page Hooks.
  class ConvertiblePage
    include Convertible
    
    attr_accessor :name, :content, :site, :ext, :output, :data
    
    def initialize(site, name, content)
      @site     = site
      @name     = name
      @ext      = File.extname(name)
      @content  = content
      @data     = { layout: "no_layout" } # hack
    end
    
    def render(payload, info)
      do_layout(payload, { no_layout: nil })
    end
  end
end

module LiquidPlus
  class RenderTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @markup = markup.strip
      super
    end

    def parse_markup
      # If raw, strip from the markup as not to confuse the Path syntax parsing
      if @markup =~ /(.+?)\sraw\s*$/
        @markup = $1.strip
        @raw = true
      end

      # Separate params from markup
      @markup, @params = Include.split_params(@markup)
    end

    def get_path(context)
      if file = Path.parse(@markup, context)
        path = Pathname.new Path.expand(file, context)
        @markup = file
        path
      end
    end

    def render(context)
      parse_markup
      path = get_path(context)
      if path and File.exist? path

        Dir.chdir(File.dirname(path)) do
          content = path.read
          
          # Strip out yaml header from partials
          content = $1.lstrip if content =~ /\A-{3}.+[^\A]-{3}\n(.+)/m

          if @raw
            content
          else
            content = parse_params(content, context) if @params

            p = Jekyll::ConvertiblePage.new(context.registers[:site], path, content)
            payload = { 'page' => context.registers[:page], 'site' => context.registers[:site] }
            p.render(payload, { registers: context.registers })
            p.output.strip
          end
        end
      elsif path
        name = File.basename(path)
        dir  = path.to_s.sub(context.registers[:site].source + '/', '')

        msg  = "From #{context.registers[:page]['path']}: "
        msg += "File '#{name}' not found"
        msg += " at '#{dir}'" unless name == dir

        puts msg.red
        return msg
      end
    end

    def parse_params(content, context)
      markup = @markup + @params
      partial = Liquid::Template.parse(content)

      context.stack do
        params = Jekyll::Tags::IncludeTag.new('', markup, []).parse_params(context) 
        context['render'] = params
        content = partial.render(context)
      end
      content
    end
  end
end

