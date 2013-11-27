# Title: Figure/image tag plugin for Jekyll
# Author: Oliver Pattison | http://oliverpattison.org
# Description: Create figure/img HTML blocks with optional classes and captions. This is a YAML-dependent Liquid tag plugin for Jekyll for those who fear link rot.
#
# Download/source/issues: https://github.com/opattison/jekyll-figure-image-tag
# Documentation: https://github.com/opattison/jekyll-figure-image-tag/blob/master/README.md
#
# Note: designed specifically for implementations with YAML front matter-based images, captions and alt text.
# Create simple YAML sequences (arrays) in the post's front matter like this:
#
#   image:
#     - path/to/image
#     - path/to/another-image
#   image_alt:
#     - 'alt text'
#     - 'more alt text'
#   image_caption:
#     - 'A photo from my trip to [the solar farm](http://example.com).'
#     - 'Another photo from my trip.'
#
# Make sure to have an image domain specified in the _config.yml file:
#
#   image_url: http://images.example.com
#
# Syntax:
# {% figure_img [class name(s)] integer [caption] %}
#
# Sample (typical use):
# {% figure_img left 0 caption %}
#
# Output:
# <figure class="left">
#   <img src="http://images.example.com/solar-farm.jpg" alt="Landscape view of solar farm">
#   <figcaption>
#     <p>A photo from my trip to <a href="http://example.com">the solar farm</a>.</p>
#   </figcaption>
# </figure>
#

require './_plugins/pygments_code'
require './_plugins/raw'
require 'kramdown'

module Jekyll

  class Figure < Liquid::Block
    include TemplateWrapper
    Caption = /(\S[\S\s]*)/
    def initialize(tag_name, markup, tokens)
      super
      @showCaption = true

      #creating regular expression that grabs the index $2 at minimum, but optionally class and caption
      if markup =~ /(\d)+\s?(true)?/i
        #entering at least one integer will validate the regular expression
        @index = Integer($1)-1
        @showCaption = ($2 != 'false')
      end

      if !@index
        raise "Missing 'index': "
      end
    end

    def render(context)
      # output = super
      # code = super
      # source = "#{@index}" + "#{Kramdown::Document.new(code).to_html}"
      # # source = safe_wrap(source)
      # source

      code = super
      caption = Liquid::Template.parse("{{ page.captions[#{@index}] | markdownify }}").render(context).gsub(/<p>/,'').gsub(/<\/p>/,'') if @showCaption
      content = "#{Kramdown::Document.new(code).to_html}"

      figure = "<figure>"
      # remove the outer <p> tag
      figure += content.gsub(/<p>/,'').gsub(/<\/p>/,'')
      if caption
        figure += "<figcaption id='figure-#{@index+1}'><b>Figure #{(@index + 1).to_s}.</b> #{caption}</figcaption>"
      end
      figure += "</figure>"
    end
  end
end

Liquid::Template.register_tag('figure', Jekyll::Figure)
