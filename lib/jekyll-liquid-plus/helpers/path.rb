require File.join File.expand_path('../../', __FILE__), 'helpers/conditional'

module LiquidPlus
  class Path
    class << self

      # 
      def parse(markup, context, path=nil)
        files = Conditional.parse(markup, context)
        if files
          select(files, context, path)
        end
      end

      # Allow paths to begin from the directory of the context page
      #
      # Input: 
      #  - file: "file.html"
      #  - context: A Jekyll context object
      #
      #  Returns the full path to a file
      #
      def expand(file, context)
        root = context.registers[:site].source
        if file =~ /^\.\/(.+)/
          local_dir = File.dirname context.registers[:page]['path']
          File.join root, local_dir, $1
        else
          File.join root, file
        end
      end
      
      # Find the first file which exists
      #
      # Input: 
      #  - file: "file.html || some_var || path/to/file.md" - a list of files
      #  - context: A Jekyll context object
      #  - path: e.g. "_includes" - a directory to prepend to the path
      #
      # Return the first file path which exists, or the last if none exist
      # If the last path is 'none' this returns false
      #
      def select(files, context, path)
        files = get_paths(files, context)
        files.each_with_index do |f, i|
          file = path ? File.join(path, f) : f
          if File.exist? expand(file, context)
            return f
          # If "file.html || none" is passed, fail gracefully
          elsif i == files.size - 1
            return f.downcase == 'none' ? false : f
          end
        end
      end

      # Read file paths from context variables if necessary
      #
      # Input: 
      #  - file: file.html || some_var || path/to/file.md
      #  - context: A Jekyll context object
      #
      # Returns a list of file paths
      #
      def get_paths(files, context)
        files = files.split("||").map do |file|
          file = file.strip
          context[file].nil? ? file : context[file]
        end
      end
    end
  end
end

