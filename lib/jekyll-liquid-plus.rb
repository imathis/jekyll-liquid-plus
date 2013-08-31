require 'liquid'

$:.unshift File.dirname(__FILE__)

module LiquidPlus
  autoload :IncludeTag,    'jekyll-liquid-plus/tags/include'
  autoload :WrapTag,       'jekyll-liquid-plus/tags/wrap'
  autoload :RenderTag,     'jekyll-liquid-plus/tags/render'
  autoload :AssignTag,     'jekyll-liquid-plus/tags/assign'
  autoload :CaptureTag,    'jekyll-liquid-plus/tags/capture'
  autoload :ReturnTag,     'jekyll-liquid-plus/tags/return'
end

Liquid::Template.register_tag('include', LiquidPlus::IncludeTag)
Liquid::Template.register_tag('wrap', LiquidPlus::WrapTag)
Liquid::Template.register_tag('wrap_include', LiquidPlus::WrapTag)
Liquid::Template.register_tag('render', LiquidPlus::RenderTag)
Liquid::Template.register_tag('render_partial', LiquidPlus::RenderTag)
Liquid::Template.register_tag('assign', LiquidPlus::AssignTag)
Liquid::Template.register_tag('capture', LiquidPlus::CaptureTag)
Liquid::Template.register_tag('return', LiquidPlus::ReturnTag)

