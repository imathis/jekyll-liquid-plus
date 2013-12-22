# encoding: UTF-8
require 'pathname'
require 'colorator'

has_failed = false

def test(path)
  path = Pathname.new path + '.html'
  failure = []
  start = 1
  tests = ''
  passed = 0
  failed = 0

  f = File.new("source/#{path}")
  # Get the starting line (after the YAML FM) for source map
  f.each do |line|
    if line =~ /---/ and f.lineno > 1
      break start = f.lineno + 1 
    end
  end
  total = f.read.count('→')

  Dir.chdir('_site') do
    File.readlines(path).each_with_index do |line, i|
      if line =~ /(.+?)→(.+)/
        if $1.strip != $2.strip
          failed += 1
          tests << 'F'.red
          failure << " - line #{i+start}: #{$1}!=#{$2}"
        else
          passed += 1
          tests << '.'.green
        end
      end
    end
  end
  if failed < 1 && passed < 1
    puts "missed".yellow + ": #{path} " + "0/#{total}".yellow
    has_failed = true
  elsif failure.size > 0
    puts "failed".red + ": #{path} #{tests} " + "#{passed}/#{total}".red
    puts failure.join "\n"
    has_failed = true
  else
    puts "passed".green + ": #{path} #{tests} " + "#{passed}/#{total}".green
  end
end

def test_layout(path)
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
    if path.read !~ /success/
      puts "failed".red + ": #{path} 1/1".red
      has_failed = true
    else
      puts "passed".green + ": #{path} " + "1/1".green
    end
  end
end


`rm -rf _site/; bundle exec jekyll build --trace`

# Test include

test 'include'
test 'render'
test 'wrap'
test 'assign'
test 'capture'
test 'return'
test_layout 'include_layout'
test_layout 'render_layout'


abort if has_failed
