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

# store = PStore.new 'data.json'
# store.transaction do
#   store[:list] = list
#   store[:results] = results
# end

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
    # unless app_name[/ss-geoffrey|ss-gandalf/]
    # unless app_name[/test-review-app/]
    #   i+=1
    #   next
    # end

    mongodb_url = results[i].split("\n").select{|line| line[/mongodb\:\/\/|mongodb\+srv\:\/\//i]}
# p results[i]

    staging = mongodb_url.find{|e| e[/sbx-stg|sandbox-staging/]} ? true : false
    production = mongodb_url.find{|e| e[/ds015978/]} ? true : false
    production_storage = mongodb_url.find{|e| e[/ds125204/]} ? true : false
    # mongodb_url.reject!{|e| e[/sbx-stg|ds015978|ds125204/]}

    env = :production
    env = :staging
    mongodb_url.select!{|e| e[/ds015978|ds125204/]} if env == :production
    mongodb_url.select!{|e| e[/sbx-stg|sandbox-staging/i]} if env == :staging

    environment_variables = mongodb_url.map{|e| e.split(":").first}
    # p app_name, environment_variables.length
    # binding.pry if mongodb_url.length > 0

    # binding.pry
    # p app_name
    # p '**mongodb_url'
    # puts mongodb_url
    # p '**environment_variable'
    # puts environment_variables

    # heroku config -a ss-test-review-apps 
    # heroku config:set -a ss-test-review-apps a=2 b=3
    # heroku config:get -a ss-test-review-apps a b
    if environment_variables.length > 0
      # p app_name
      # p app_name
      # p environment_variables
      # p "heroku config:get -a #{app_name.split(" ").first} #{environment_variables.join(' ')}"
      output = `heroku config:get -a #{app_name.split(" ").first} #{environment_variables.join(' ')}`
      # puts output
      j=0
      output.split("\n").each do |line|
        # p line
        username = nil
        if line[/sally|itp-team|tim|platform|salido\:/]
          username = 'salido' 
          password = 'DMNqhIEti96SqxUy' if env == :production
          password = 'zjMu7GoNeYW3WZ8P' if env == :staging
        end
        if line[/readonly\:/]
          username = 'readonly'
          password = 'TuZLUp9jvuCuTAl4' if env == :production
          password = 'AxLJs32P4R3zw8vG' if env == :staging
        end
        # p '**line'
        # p line
        line[/\d+\/(.*)\?/] or line[/net\/(.*)\?/]
        database = $1 
        database = 'platform_staging' if database.empty?
        # p '**database'
        # p database
    
        server_name = "production-main" if line[/ds015978/]
        server_name = "production-storage" if line[/ds125204/]
        mongo_code = "yxjqz" if line[/ds015978|ds125204/]
        # server_name = "sbx-stg" if line[/sbx-stg/]
        if line[/sbx-stg|sandbox-staging/]
          server_name = "sandbox-staging"
          mongo_code = "jxu4y"
        end
        
        replica_set_name = server_name.to_s.upcase if env == :staging
        replica_set_name = server_name if env == :staging
        replica_set_name = server_name if env == :production

        connection_string = if app_name[/ss-geoffrey|ss-gandalf/]
          "mongodb+srv://#{username}:#{password}@#{server_name}-#{mongo_code}.mongodb.net/#{database}?retryWrites=true&w=majority"
        else
          "mongodb://#{username}:#{password}@#{server_name}-shard-00-00-#{mongo_code}.mongodb.net:27017,#{server_name}-shard-00-01-#{mongo_code}.mongodb.net:27017,#{server_name}-shard-00-02-#{mongo_code}.mongodb.net:27017/#{database}?ssl=true&replicaSet=#{replica_set_name}-shard-0&authSource=admin&retryWrites=true&w=majority"
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
