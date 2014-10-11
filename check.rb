#!/usr/bin/env ruby

require 'blink1'
require 'nokogiri'
require 'rest_client'

lights = {
   'SUCCESS' => [400, 0, 231, 0],
   'FAILURE' => [400, 255, 0, 0],
   'ERROR' => [400, 255, 184, 31]
}

indicator = "SUCCESS"

if ARGV.length < 2
   puts "Usage: check.rb <TEAMCITY_HOST> [<BUILD_ID1> <BUILD_ID2 ..]"
   exit -1
end

TEAMCITY_HOST = ARGV.first
BUILD_IDS = ARGV.drop(1)

BUILD_IDS.each do |build_id|
   # url = "#{TEAMCITY_HOST}/guestAuth/app/rest/buildTypes/id:#{build_id}/builds"
   url = "#{TEAMCITY_HOST}/#{build_id}.xml"
   response = RestClient.get url rescue begin
                 puts "CI server is not responding!"
                 exit -2
              end

   if response.code != 200
      puts "Something wrong with your CI: #{url}!"
      exit -3
   end

   doc = Nokogiri::XML(response.to_str)
   last = doc.css('builds > build').first
   status = last.attr 'status'
   puts "> Build #{build_id} is #{status} ..."

   indicator = status if status != "SUCCESS"
end

Blink1.open do |blink|
   blink.fade_to_rgb(*lights[indicator])

   # -- Other options --
   # blink.on
   # blink.off
   # blink.random(25)
   # blink.blink(255, 255, 0, 5)

   # blink.write_pattern_line(100, 255, 0, 0, 1)
   # blink.write_pattern_line(100, 0, 255, 0, 2)
   # blink.write_pattern_line(100, 0, 0, 255, 3)
   # blink.play(0)
end
