=begin
  Jekyll tag to include Markdown text from _includes directory preprocessing with Liquid.
  Automatically wraps formatted markdown in a <section> tag
  Usage:
    {% markdownsection <filename> %}
  Dependency:
    - kramdown
=end
module Jekyll
  class MarkdownSectionTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
    end
    require "kramdown"
    def render(context)
      tmpl = File.read File.join Dir.pwd, "_includes", @text
      site = context.registers[:site]
      tmpl = (Liquid::Template.parse tmpl).render context, site.site_payload
      html = Kramdown::Document.new(tmpl).to_html
      id = @text.gsub(/\.md/, '').gsub(/^[a-zA-Z0-9]/, '-')
      finalHtml = "<section id=\"#{id}\">#{html}</section>"
    end
  end
end

Liquid::Template.register_tag('markdownsection', Jekyll::MarkdownSectionTag)
