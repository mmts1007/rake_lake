require 'active_support'
require 'active_support/core_ext'
require 'dotenv'
require 'rest-client'
require_relative '../../../../models/weather_forcast'

Dotenv.load

def get_env!(env_name)
  ENV[env_name] or raise("undefined environment variable '#{env_name}'")
end

PREF_ID         = get_env!('PREF_ID')
AREA_NAME       = get_env!('AREA_NAME')
NOTICE_MESSAGE  = get_env!('NOTICE_MESSAGE')
CAUTION_MESSAGE = get_env!('CAUTION_MESSAGE')
DANGER_MESSAGE  = get_env!('DANGER_MESSAGE')
WEBHOOK_URL     = get_env!('WEBHOOK_URL')

wf    = WeatherForecast.new(PREF_ID)
infos = wf.infomations(AREA_NAME)
today = infos.find { |i| i.date == Date.today }

text = case today.probabilities_of_rain.max
         when 50..100 # %
           DANGER_MESSAGE
         when 40..50 # %
           CAUTION_MESSAGE
         else
           NOTICE_MESSAGE
         end

res = RestClient.post(
  WEBHOOK_URL,
  { payload: { text: text }.to_json },
  content_type: :json
)

puts "INFO: status_code => #{res.code} body => #{res.body}"
