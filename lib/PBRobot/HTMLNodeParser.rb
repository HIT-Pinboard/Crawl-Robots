require 'nokogiri'
require 'uri'

module PBRobot

  class HTMLNodeParser

    def initialize(root, base_url = "")
      @root = root
      @string = ""
      @imgs = []
      @base_url = base_url
    end

    def parse
      if @root.is_a?Nokogiri::XML::NodeSet
        iterativePreorder(@root.first)
      elsif @root.is_a?Nokogiri::XML::Element
        iterativePreorder(@root)
      else
        puts '[ERROR]: Unknown class, must be Nokogiri::XML::NodeSet or Nokogiri::XML::Element'
      end
    end

    def iterativePreorder(node)
      return if !node
      case node.name
      when "text"
        @string += node.text.strip if node.text.strip.length != 0
      when "img"
        @string += '#!-- Images['+@imgs.count.to_s+'] --!#\n'
        if node[:src] =~ URI::regexp
          @imgs << node[:src]
        else
          @imgs << @base_url+node[:src]
        end
      when /(table|tr|td)/
        element = $1.to_s
        @string += "<#{element}>"
        iterativeNext(node)
        @string += "</#{element}>"
        return
      when "a"
        @string += '<a'
        if url = node[:href]
          @string += ' href="'
          if url =~ URI::regexp
            @string += url
          else
            @string += @base_url+url
          end
          @string += '"'
        end
        @string += '>'
        iterativeNext(node)
        @string += '</a>'
        return
      when "p"
        @string += '\n'
      end
      iterativeNext(node)
    end

    def iterativeNext(node)
      node.children.each do |child|
        iterativePreorder(child)
      end
    end

    def string
      @string
    end

    def imgs
      @imgs
    end

    private :iterativePreorder

  end

end