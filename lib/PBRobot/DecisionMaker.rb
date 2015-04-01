module PBRobot

  class DecisionMaker

    def initialize(hash)
      @config = hash
    end

    def should_stop_at(url)
      @config["link"][0] != nil && url == @config["link"][0] && 
      @config["link"][1] != nil && url == @config["link"][1] &&
      @config["link"][2] != nil && url == @config["link"][2]
    end

  end

end
