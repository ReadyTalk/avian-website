module Jekyll
  class FileSize < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
    end
    def render(context)
      file = File.join Dir.pwd, @text
      size = File.size(file)
      suffixes = [' bytes', 'K', 'M', 'G']
      suffix_index = 0

      while size >= 10 * 1024 and suffix_index < suffixes.length
        suffix_index += 1
        size /= 1024
      end

      "#{size}#{suffixes[suffix_index]}"
    end
  end
end

Liquid::Template.register_tag('filesize', Jekyll::FileSize)
