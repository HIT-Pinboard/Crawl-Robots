require 'PBRobot'

class TodayDecisionMaker < PBRobot::DecisionMaker

  def should_stop_at(url)
    @config["link"] != nil && url[0..-6] == @config["link"][0..-6]
  end

end