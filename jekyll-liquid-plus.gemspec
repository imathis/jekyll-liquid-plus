# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll-liquid-plus/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-liquid-plus"
  spec.version       = LiquidPlus::VERSION
  spec.authors       = ["Brandon Mathis"]
  spec.email         = ["brandon@imathis.com"]
  spec.description   = %q{Super powered Liquid tags for smarter Jekyll templating.}
  spec.summary       = %q{Do things easier with better versions of common liquid tags: include, capture, assign, and introducing: render, wrap, wrap_include, and more. }
  spec.homepage      = "https://github.com/imathis/jekyll-liquid-plus"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", "~> 1.3.0"
  spec.add_runtime_dependency "liquid", "~> 2.5.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
