#!/usr/bin/env ruby
require 'axlsx'
require 'pry-byebug'
require 'yaml/store'

# Select the type of database that the user wishes to generate the new configuration string for
env = :staging or :production

store = YAML::Store.new 'data.yml'
heroku_list_of_application_environment_variables = store.transaction do
  store[:heroku_list_of_application_environment_variables]
end

unless heroku_list_of_application_environment_variables
  heroku_list_of_application_environment_variables ||= {}
  heroku_list_of_applications = `heroku list --team salido`.split("\n")[1..-1]
  heroku_list_of_applications.each do |application_name|
    application_name = application_name.split(' ').first
    heroku_list_of_application_environment_variables[application_name] = `heroku config -a #{application_name}`
  end

  store.transaction do
    store[:heroku_list_of_application_environment_variables] = heroku_list_of_application_environment_variables
  end
end

package = Axlsx::Package.new
package.workbook.add_worksheet do |worksheet|
  color = worksheet.styles.add_style bg_color: '00FF00'
  row = worksheet.add_row [
                              'Heroku App',
                              :Staging,
                              :Production,
                              'Production Storage',
                              :Environment,
                              :Count,
                          ]
  i = 0
  heroku_list_of_application_environment_variables.keys.each do |application_name|
    # Select only environment variables with mongodb:// in the string, case insensitive
    environment_variables_with_mongodb = heroku_list_of_application_environment_variables[application_name]
                                           .split("\n")
                                           .select { |environment_variable| environment_variable[/mongodb\:\/\/|mongodb\+srv\:\/\//i] }

    # Detect the type of MongoDB database
    staging = environment_variables_with_mongodb.find { |e| e[/sbx-stg|sandbox-staging/] } ? true : false
    production = environment_variables_with_mongodb.find { |e| e[/ds015978/] } ? true : false
    production_storage = environment_variables_with_mongodb.find { |e| e[/ds125204/] } ? true : false

    # Filter environment variables with MongoDB by production or staging
    environment_variables_with_mongodb.select! { |e| e[/ds015978|ds125204/] } if env == :production
    environment_variables_with_mongodb.select! { |e| e[/sbx-stg|sandbox-staging/i] } if env == :staging

    # environment_variables = environment_variables_with_mongodb.map { |e| e.split(":").first }
    environment_variables = environment_variables_with_mongodb.inject({}){|a,b|v=b.split(':'); a[v.first.strip] = v[1..-1].join(':').strip;a}

    # binding.pry
    # if environment_variables.length > 0

      # output = `heroku config:get -a #{application_name.split(" ").first} #{environment_variables.join(' ')}`
      j = 0

      environment_variables.keys.each do |name|
        value = environment_variables[name]
        username = nil
        if value[/sally|itp-team|tim|platform|salido\:/]
          username = 'salido'
          password = 'DMNqhIEti96SqxUy' if env == :production
          password = 'zjMu7GoNeYW3WZ8P' if env == :staging
        end
        if value[/readonly\:/]
          username = 'readonly'
          password = 'TuZLUp9jvuCuTAl4' if env == :production
          password = 'AxLJs32P4R3zw8vG' if env == :staging
        end

        # RegEx to capture name of the database from the legacy string
        value[/\d+\/(.*)\?/] or value[/net\/(.*)\?/]
        database = $1
        database = 'platform_staging' if database.empty?

        server_name = "production-main" if value[/ds015978/]
        server_name = "production-storage" if value[/ds125204/]
        mongo_code = "yxjqz" if value[/ds015978|ds125204/]

        if value[/sbx-stg|sandbox-staging/]
          server_name = "sandbox-staging"
          mongo_code = "jxu4y"
        end

        replica_set_name = server_name if[:staging, :production].include? env

        connection_string = if application_name[/ss-geoffrey|ss-gandalf/]
                              "mongodb+srv://#{username}:#{password}@#{server_name}-#{mongo_code}.mongodb.net/#{database}?retryWrites=true&w=majority"
                            else
                              "mongodb://#{username}:#{password}@#{server_name}-shard-00-00-#{mongo_code}.mongodb.net:27017,#{server_name}-shard-00-01-#{mongo_code}.mongodb.net:27017,#{server_name}-shard-00-02-#{mongo_code}.mongodb.net:27017/#{database}?ssl=true&replicaSet=#{replica_set_name}-shard-0&authSource=admin&retryWrites=true&w=majority"
                            end

        puts "heroku config:set -a #{application_name.split(" ").first} #{environment_variables[j]}=\"#{connection_string}\""
        j += 1
      end

    row = worksheet.add_row [
                                application_name,
                                staging,
                                production,
                                production_storage,
                                environment_variables,
                                environment_variables_with_mongodb.length,
                            ]
    row.style = color if production or production_storage
    i += 1
  end

end
package.serialize('worksheet.xlsx')