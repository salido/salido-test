#!/usr/bin/env ruby

require 'csv'

# Find MONGODB URLs in Heroku
list = `heroku list --team salido`.split("\n")[1..-1]
results = list.map{|item| `heroku config -a #{item.split(" ").first}` }

csv = []
CSV.open("/Users/kshaikhr/Desktop/heroku.csv", "wb") do |csv|
  csv << ['Heroku App', 'MongoDB URL', :Staging, :Production]
  i=0
  list.each do |item|
    mongodb_url = results[i].split("\n").select{|line| line[/MONGODB/i]}
    staging = mongodb_url.find{|e| e[/sbx-stg/]} ? true : false
    production = mongodb_url.find{|e| e[/ds015978/]} ? true : false
     csv << [ 
       item,
       mongodb_url,
       staging,
       production 
     ]
    i+=1
  end
end

# f = e => e
# -> {}