# encoding: UTF-8
require 'pathname'
require 'colorator'

def test(path)
  path = Pathname.new path + '.html'
  failure = []
  Dir.chdir('_site') do
    File.readlines(path).each_with_index do |line, i|
      if line =~ /(.+?)→(.+)/
        if $1.strip != $2.strip
          failure << " - line #{i+4}: #{$1}!=#{$2}"
        end
      end
    end
  end
  if failure.size > 0
    puts "failed".red + ": #{path}"
    puts failure.join "\n"
  else
    puts "passed".green + ": #{path}" 
  end
end

`bundle exec jekyll build --trace`

# Test include

test 'include'
test 'render'
test 'wrap'
test 'exists'
test 'assign'
test 'capture'
test 'return'
