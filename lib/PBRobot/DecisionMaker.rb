module PBRobot

  class DecisionMaker

    def initialize(hash)
      @config = hash
    end

    def should_stop_at(url)
      @config["link"] != nil && url == @config["link"]
    end

  end

end