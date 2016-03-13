require 'active_support'
require 'active_support/core_ext/hash/conversions'
require 'rest-client'

class WeatherForecast
  def initialize(pref_id)
    response     = RestClient.get "http://www.drk7.jp/weather/xml/#{pref_id}.xml"
    @hashed_body = Hash.from_xml(response.body)
  end

  def area_names
    @areas ||= hashed_body['weatherforecast']['pref']['area']
    areas.map { |area| area['id'] }
  end

  class Info
    def initialize(info)
      @info = info
    end

    # [ "00-06時の降水確率", ... , "18-24時の降水確率" ]
    def probabilities_of_rain
      info['rainfallchance']['period'].map(&:to_i)
    end

    def date
      Date.parse(info['date'])
    end

    private
    attr_reader :info
  end

  def infomations(area_name)
    @areas ||= hashed_body['weatherforecast']['pref']['area']
    area     = areas.find { |a| a['id'] == area_name }
    area['info'].map { |info| Info.new(info) }
  end

  private
  attr_reader :hashed_body, :areas
end
