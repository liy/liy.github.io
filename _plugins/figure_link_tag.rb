module Jekyll
  class FigureLinkTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      if markup =~ /(\d)+/i
        @index = Integer($1)-1
      end
    end

    def render(context)
      if !@index
        return "Error processing link, an index"
      end

      numStr = (@index+1).to_s
      link = "<a href='\#figure-#{numStr}'>Figure #{numStr}</a>"
    end
  end
end

Liquid::Template.register_tag('fig_to', Jekyll::FigureLinkTag)