require 'PBRobot'
require './TodayExtractor.rb'
require './TodayDecisionMaker.rb'

class TodayFetcher < PBRobot::Fetcher

	def get_extractor(hash)
		TodayExtractor.new(hash)
	end

  def get_decision_maker(hash)
    TodayDecisionMaker.new(hash)
  end

	private :get_extractor, :get_decision_maker

end
