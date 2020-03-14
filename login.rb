#!/usr/bin/env ruby

require 'watir'
require 'benchmark'
require 'pry-byebug'

while true
  
  [:stg, :pro].each do |environment|
    
    real = Benchmark.measure do
      browser = Watir::Browser.new
      browser.goto "https://ss-platform-#{environment}.herokuapp.com/"
      browser.title == "SALIDO"
      browser.text_field(id: 'session_email').set 'kshaikhr@salido.com'
      browser.text_field(id: 'session_password').set '11e2fb77e302a24cb990ea8f0ee601d4'
      browser.button(text: 'sign in').click
      browser.title == "SALIDO Bridge"
      # browser.goto "https://ss-platform-#{environment}.herokuapp.com/"
      browser.close
    end.real
    puts "#{Time.now} #{environment} #{real}"
    sleep 30
  end

end
