# encoding: UTF-8
require 'pathname'
require 'colorator'

has_failed = false

def test(path)
  path = Pathname.new path + '.html'
  failure = []
  start = 0

  f = File.new("source/#{path}")
  # Get the starting line (after the YAML FM) for source map
  f.each do |line|
    if line =~ /---/ and f.lineno > 1
      break start = f.lineno + 1 
    end
  end

  Dir.chdir('_site') do
    File.readlines(path).each_with_index do |line, i|
      if line =~ /(.+?)→(.+)/
        if $1.strip != $2.strip
          failure << " - line #{i+start}: #{$1}!=#{$2}"
        end
      end
    end
  end
  if failure.size > 0
    puts "failed".red + ": #{path}"
    puts failure.join "\n"
    has_failed = true
  else
    puts "passed".green + ": #{path}" 
  end
end

`bundle exec jekyll build --trace`

# Test include

test 'include'
test 'render'
test 'wrap'
test 'assign'
test 'capture'
test 'return'

abort if has_failed
