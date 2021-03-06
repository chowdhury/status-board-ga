#!/usr/bin/env ruby

# status_board_ga.rb
# Hilton Lipschitz 
# Twitter/ADN: @hiltmon 
# Web: http://www.hiltmon.com
# Use and modify freely, attribution appreciated
#
# Script to generate @panic status board files for Google Analytics web stats.
#
# Run this regularly to update status board
#
# For how to set up, see http://www.hiltmon.com/blog/2013/04/10/google-analytics-for-status-board/

# Include the gems needed
require 'rubygems'
require 'gattica'
require 'date'
require 'json'

# Your Settings
google_email   = 'hiltmon@gmail.com'  # Your google login
google_pwd     = 'i_aint_sayin'   # Must be a single use password if 2 factor is set up
the_title      = "Hiltmon.Com Stats"  # The title of the Graph
file_name      = "hiltmondotcom"      # The file name to use (.CSV and .JSON)
dropbox_folder = "/Users/Hiltmon/Dropbox/Data" # The path to a folder on your local DropBox

# Configuration 
metrics = ['pageviews', 'visitors', 'newVisits']
colors = ['red', 'green', 'blue']
days_to_get = 7

# Login
ga = Gattica.new({ 
    :email => google_email, 
    :password => google_pwd
})

# Get a list of accounts
accounts = ga.accounts

# Choose the first account
ga.profile_id = accounts.first.profile_id
# ga.profile_id = accounts[1].profile_id # OR second account

# Get the data
data = ga.get({ 
    :start_date   => (Date.today - days_to_get).to_s.split('T')[0],
    :end_date     => Date.today.to_s.split('T')[0],
    :dimensions   => ['date'],
    :metrics      => metrics,
})

# Make the CSV file
File.open("#{dropbox_folder}/#{file_name}.csv", "w") do |f|
  f.write "#{the_title},#{metrics.join(',')}\n"
  data.to_h['points'].each do |point|
    the_date = Date.parse(point.to_h["dimensions"].first[:date]).to_s.split('T')[0]
    the_data = point.to_h["metrics"].map { |e| e.values.first }
    f.write the_date + "," + the_data.join(',') + "\n"
  end
end

# Make the JSON file
graph = Hash.new
graph[:title] = the_title
graph[:type] = 'bar'
index = 0
graph[:datasequences] = Array.new

metrics.each do |element|
  sequence = Hash.new
  sequence[:title] = element
  sequence_data = Array.new
  data.to_h['points'].each do |point|
    the_title = Date.parse(point.to_h["dimensions"].first[:date]).to_s.split('T')[0]
    the_value = point.to_h["metrics"][index][element.to_sym]
    sequence_data << { :title => the_title, :value => the_value }
  end
  sequence[:datapoints] = sequence_data
  sequence[:color] = colors[index]
  index += 1
  graph[:datasequences] << sequence
end

File.open("#{dropbox_folder}/#{file_name}.json", "w") do |f|
  wrapper = Hash.new
  wrapper[:graph] = graph
  f.write wrapper.to_json
end
