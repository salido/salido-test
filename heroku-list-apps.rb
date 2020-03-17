#!/usr/bin/env ruby

require 'axlsx'
require 'pry-byebug'
require 'yaml/store'


list = nil
results = nil
store = YAML::Store.new "data.yml"
store.transaction do 
  list = store[:list]
  results = store[:results]
end

unless list && results
  # Find MONGODB URLs in Heroku
  list = `heroku list --team salido`.split("\n")[1..-1] 
  results = list.map{|item| `heroku config -a #{item.split(" ").first}` }

  store.transaction do 
    store[:list] = list
    store[:results] = results
  end  
end

###

p = Axlsx::Package.new
p.workbook.add_worksheet do |sheet|
  # fg_color: '0000FF', 
  color = sheet.styles.add_style bg_color: '00FF00'
  row = sheet.add_row [
    'Heroku App', 
    :Staging, 
    :Production,
    'Production Storage',
    :Environment,
    :Count,
    # 'MongoDB URL', 
  ]

  environment = nil
  i=0
  list.each do |app_name|
    mongodb_url = results[i].split("\n").select{|line| line[/MONGODB\:\/\//i]}

    staging = mongodb_url.find{|e| e[/sbx-stg/]} ? true : false
    production = mongodb_url.find{|e| e[/ds015978/]} ? true : false
    production_storage = mongodb_url.find{|e| e[/ds125204/]} ? true : false
    # mongodb_url.reject!{|e| e[/sbx-stg|ds015978|ds125204/]}
    mongodb_url.select!{|e| e[/ds015978|ds125204/]}

    environment_variables = mongodb_url.map{|e| e.split(":").first}
    # binding.pry if mongodb_url.length > 0

    # heroku config -a ss-test-review-apps 
    # heroku config:set -a ss-test-review-apps a=2 b=3
    # heroku config:get -a ss-test-review-apps a b

    if environment_variables.length > 0
      # p app_name
      # p environment_variables
      # p "heroku config:get -a #{app_name.split(" ").first} #{environment_variables.join(' ')}"
      output = `heroku config:get -a #{app_name.split(" ").first} #{environment_variables.join(' ')}`
      # puts output
      j=0
      output.split("\n").each do |line|
        username = nil
        username = 'salido' if line[/sally|itp-team|tim|platform\:/]
        username = 'readonly' if line[/readonly\:/]
        password = 'password'
        line[/\d+\/(.*)\?/]
        database = $1
    
        server_name = "production-main" if line[/ds015978/]
        server_name = "production-storage" if line[/ds125204/]

        connection_string = if app_name == 'ss-geoffrey-pro'
          "mongodb+srv://#{username}:#{password}@#{server_name}-jxu4y.mongodb.net/#{database}?retryWrites=true&w=majority"
        else
          "mongodb://#{username}:#{password}@#{server_name}-00-00-jxu4y.mongodb.net:27017,prod-shard-00-01-jxu4y.mongodb.net:27017,prod-shard-00-02-jxu4y.mongodb.net:27017/#{database}?ssl=true&replicaSet=prod-shard-0&authSource=admin&retryWrites=true&w=majority"
        end

        puts "heroku config:set -a #{app_name.split(" ").first} #{environment_variables[j]}=\"#{connection_string}\""
        j+=1
      end
    end    

    row = sheet.add_row [ 
      app_name,
      staging,
      production,
      production_storage,
      environment_variables,
      mongodb_url.length,
      # mongodb_url,
    ]
    # row.cells[1].style = color if staging
    # row.cells[2].style = color if production
    # row.cells[3].style = color if production_storage
    row.style = color if production or production_storage
    i+=1
  end

end
p.serialize('worksheet.xlsx')
