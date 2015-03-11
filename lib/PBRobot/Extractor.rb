module PBRobot

  class Extractor

    def initialize(conf_hash)
      @conf_hash = conf_hash
      @base_url = ''
    end

    def base_url=(base_url)
      @base_url = base_url
    end

    def cell=(cell)
      @cell = cell
    end

    def detail_page=(page)
      @detail_page = page
    end

    def title

    end

    def link

    end

    def date

    end

    def tags

    end

    def content

    end

    def imgs

    end

    def router
      if !@router
        @router = get_router
        @router.page=@detail_page
        @router.base_url=@base_url
      end
      @router
    end

    def get_router

    end

    private :router, :get_router
    
  end

end