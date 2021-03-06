#!/usr/bin/env ruby
require 'watir'
require 'pry-byebug'

# f=e=>e

gcp_cidr = [
'34.100.0.0/16',    '34.102.0.0/15',    '34.104.0.0/14',
'34.124.0.0/18',    '34.124.64.0/20',   '34.124.80.0/23',
'34.124.84.0/22',   '34.124.88.0/23',   '34.124.92.0/22',
'34.125.0.0/16',    '35.184.0.0/14',    '35.188.0.0/15',
'35.190.0.0/17',    '35.190.128.0/18',  '35.190.192.0/19',
'35.190.224.0/20',  '35.190.240.0/22',  '35.192.0.0/14',
'35.196.0.0/15',    '35.198.0.0/16',    '35.199.0.0/17',
'35.199.128.0/18',  '35.200.0.0/13',    '35.208.0.0/13',
'35.216.0.0/15',    '35.219.192.0/24',  '35.220.0.0/14',
'35.224.0.0/13',    '35.232.0.0/15',    '35.234.0.0/16',
'35.235.0.0/17',    '35.235.192.0/20',  '35.235.216.0/21',
'35.235.224.0/20',  '35.236.0.0/14',    '35.240.0.0/13',
'104.154.0.0/15',   '104.196.0.0/14',   '107.167.160.0/19',
'107.178.192.0/18', '108.170.192.0/20', '108.170.208.0/21',
'108.170.216.0/22', '108.170.220.0/23', '108.170.222.0/24',
'108.59.80.0/20',   '130.211.128.0/17', '130.211.16.0/20',
'130.211.32.0/19',  '130.211.4.0/22',   '130.211.64.0/18',
'130.211.8.0/21',   '146.148.16.0/20',  '146.148.2.0/23',
'146.148.32.0/19',  '146.148.4.0/22',   '146.148.64.0/18',
'146.148.8.0/21',   '162.216.148.0/22', '162.222.176.0/21',
'173.255.112.0/20', '192.158.28.0/22',  '199.192.112.0/22',
'199.223.232.0/22', '199.223.236.0/23', '208.68.108.0/23'
]

aws_cidr = [
'18.208.0.0/13',     '52.95.245.0/24',    '54.196.0.0/15',
'176.32.125.226/31', '216.182.224.0/21',  '13.248.124.0/24',
'52.119.224.0/21',   '216.182.232.0/22',  '3.5.16.0/21',
'13.248.103.0/24',   '52.144.193.128/26', '107.20.0.0/14',
'52.94.224.0/20',    '99.77.128.0/24',    '150.222.71.0/24',
'67.202.0.0/18',     '205.251.246.0/24',  '199.127.232.0/22',
'52.93.249.0/24',    '207.171.160.0/20',  '150.222.223.0/24',
'176.32.124.128/25', '184.73.0.0/16',     '52.93.60.0/24',
'150.222.136.0/24',  '3.80.0.0/12',       '54.80.0.0/13',
'3.224.0.0/12',      '52.144.192.192/26', '54.221.0.0/16',
'54.240.202.0/24',   '54.156.0.0/14',     '54.236.0.0/15',
'150.222.222.0/24',  '52.93.76.0/24',     '52.144.194.0/26',
'54.226.0.0/15',     '162.250.237.0/24',  '52.90.0.0/15',
'100.24.0.0/13',     '52.95.216.0/22',    '52.119.232.0/21',
'54.231.244.0/22',   '150.222.99.0/24',   '176.32.125.250/31',
'205.251.244.0/23',  '54.231.0.0/17',     '52.144.192.0/26',
'54.210.0.0/15',     '150.222.76.0/24',   '52.46.250.0/23',
'150.222.205.0/24',  '54.198.0.0/16',     '52.93.64.0/24',
'52.20.0.0/14',      '52.94.201.0/26',    '52.200.0.0/13',
'13.248.116.0/24',   '52.95.48.0/22',     '54.240.232.0/22',
'150.222.143.0/24',  '99.82.171.0/24',    '54.240.228.0/23',
'176.32.120.0/22',   '54.160.0.0/13',     '54.239.108.0/22',
'150.222.227.0/24',  '52.94.192.0/22',    '162.250.238.0/23',
'54.239.112.0/24',   '205.251.247.0/24',  '35.153.0.0/16',
'52.144.195.0/26',   '176.32.125.192/27', '176.32.125.238/31',
'176.32.125.254/31', '52.46.166.0/23',    '52.94.124.0/22',
'52.70.0.0/15',      '52.94.248.0/28',    '52.119.212.0/23',
'52.95.62.0/24',     '99.77.254.0/24',    '99.83.64.0/21',
'52.93.1.0/24',      '52.54.0.0/15',      '52.93.3.0/24',
'54.152.0.0/16',     '176.32.125.240/31', '52.144.193.64/26',
'54.239.16.0/20',    '54.92.128.0/17',    '54.239.0.0/28',
'52.0.0.0/15',       '184.72.128.0/17',   '205.251.248.0/24',
'54.240.216.0/22',   '99.82.166.0/24',    '52.93.51.29/32',
'23.20.0.0/14',      '52.46.168.0/23',    '64.252.64.0/24',
'52.92.16.0/20',     '172.96.97.0/24',    '52.94.68.0/24',
'18.204.0.0/14',     '54.88.0.0/14',      '99.78.192.0/22',
'162.250.236.0/24',  '176.32.125.248/31', '52.144.200.128/26',
'54.240.196.0/24',   '150.222.66.0/24',   '99.77.129.0/24',
'52.119.196.0/22',   '176.32.125.252/31', '176.32.125.236/31',
'54.204.0.0/15',     '150.222.224.0/24',  '176.32.125.246/31',
'15.177.64.0/23',    '52.86.0.0/15',      '52.44.0.0/15',
'18.232.0.0/14',     '52.93.254.0/24',    '99.82.175.0/24',
'52.93.51.28/32',    '150.222.2.0/24',    '150.222.206.0/24',
'52.95.52.0/22',     '52.46.252.0/22',    '54.174.0.0/15',
'15.221.4.0/23',     '50.16.0.0/15',      '52.95.208.0/22',
'35.168.0.0/13',     '99.77.191.0/24',    '99.82.188.0/22',
'3.208.0.0/12',      '15.221.0.0/24',     '3.5.0.0/20',
'52.144.192.64/26',  '15.221.24.0/21',    '150.222.237.0/24',
'54.239.8.0/21',     '207.171.176.0/20',  '54.240.208.0/22',
'52.94.240.0/22',    '150.222.138.0/24',  '150.222.110.0/24',
'52.95.41.0/24',     '176.32.125.244/31', '174.129.0.0/16',
'72.44.32.0/19',     '34.224.0.0/12',     '52.94.0.0/22',
'205.251.240.0/22',  '52.93.4.0/24',      '52.93.59.0/24',
'54.224.0.0/15',     '52.46.128.0/19',    '176.32.125.242/31',
'75.101.128.0/17',   '176.32.125.234/31', '52.46.164.0/23',
'176.32.125.232/31', '72.21.192.0/19',    '52.95.63.0/24',
'52.94.252.0/23',    '34.192.0.0/12',     '54.208.0.0/15',
'54.242.0.0/15',     '216.182.238.0/23',  '54.234.0.0/15',
'99.82.167.0/24',    '52.94.254.0/23',    '52.46.170.0/23',
'176.32.125.224/31', '13.248.108.0/24',   '52.95.108.0/23',
'52.144.193.0/26',   '150.222.79.0/24',   '52.119.206.0/23',
'176.32.125.230/31', '54.144.0.0/14',     '150.222.236.0/24',
'52.2.0.0/15',       '176.32.96.0/21',    '184.72.64.0/18',
'52.94.244.0/22',    '205.251.224.0/22',  '54.239.104.0/23',
'99.82.176.0/21',    '204.236.192.0/18',  '52.144.192.128/26',
'52.216.0.0/15',     '52.93.236.0/24',    '54.239.98.0/24',
'176.32.125.228/31', '15.193.6.0/24',     '99.82.165.0/24',
'150.222.100.0/24',  '52.144.200.64/26',  '52.4.0.0/14',
'52.119.214.0/23',   '208.86.88.0/23',    '44.192.0.0/11',
'52.72.0.0/15',      '52.93.97.0/24',     '52.95.255.80/28',
'150.222.87.0/24',   '50.19.0.0/16',      '150.222.73.0/24',
'54.172.0.0/15',     '54.243.31.192/26',  '107.23.255.0/26',
'3.5.16.0/21',       '54.231.0.0/17',     '52.92.16.0/20',
'3.5.0.0/20',        '52.216.0.0/15',     '52.119.224.0/21',
'52.119.232.0/21',   '52.94.0.0/22',      '18.208.0.0/13',
'52.95.245.0/24',    '54.196.0.0/15',     '216.182.224.0/21',
'216.182.232.0/22',  '3.5.16.0/21',       '107.20.0.0/14',
'99.77.128.0/24',    '67.202.0.0/18',     '184.73.0.0/16',
'3.80.0.0/12',       '54.80.0.0/13',      '3.224.0.0/12',
'54.221.0.0/16',     '54.156.0.0/14',     '54.236.0.0/15',
'54.226.0.0/15',     '162.250.237.0/24',  '52.90.0.0/15',
'100.24.0.0/13',     '54.210.0.0/15',     '54.198.0.0/16',
'52.20.0.0/14',      '52.94.201.0/26',    '52.200.0.0/13',
'54.160.0.0/13',     '162.250.238.0/23',  '35.153.0.0/16',
'52.70.0.0/15',      '52.94.248.0/28',    '99.77.254.0/24',
'52.54.0.0/15',      '54.152.0.0/16',     '54.92.128.0/17',
'52.0.0.0/15',       '184.72.128.0/17',   '23.20.0.0/14',
'64.252.64.0/24',    '18.204.0.0/14',     '54.88.0.0/14',
'162.250.236.0/24',  '99.77.129.0/24',    '54.204.0.0/15',
'15.177.64.0/23',    '52.86.0.0/15',      '52.44.0.0/15',
'18.232.0.0/14',     '54.174.0.0/15',     '50.16.0.0/15',
'35.168.0.0/13',     '99.77.191.0/24',    '3.208.0.0/12',
'3.5.0.0/20',        '174.129.0.0/16',    '72.44.32.0/19',
'34.224.0.0/12',     '54.224.0.0/15',     '75.101.128.0/17',
'34.192.0.0/12',     '54.208.0.0/15',     '54.242.0.0/15',
'216.182.238.0/23',  '54.234.0.0/15',     '54.144.0.0/14',
'52.2.0.0/15',       '184.72.64.0/18',    '204.236.192.0/18',
'15.193.6.0/24',     '52.4.0.0/14',       '208.86.88.0/23',
'44.192.0.0/11',     '52.72.0.0/15',      '52.95.255.80/28',
'50.19.0.0/16',      '54.172.0.0/15',     '34.228.4.208/28',
'13.248.124.0/24',   '13.248.103.0/24',   '13.248.116.0/24',
'99.82.171.0/24',    '99.82.166.0/24',    '99.82.175.0/24',
'99.82.167.0/24',    '13.248.108.0/24',   '99.82.165.0/24',
'15.177.64.0/23',    '34.226.14.0/24',    '34.195.252.0/24',
'3.231.2.0/25',      '3.234.232.224/27',  '34.232.163.208/29',
'3.227.250.128/25',  '3.83.168.0/22',     '3.91.171.128/25',
'3.216.135.0/24',    '3.216.136.0/21',    '3.216.144.0/23',
'3.216.148.0/22',    '18.233.213.128/25', '52.55.191.224/27',
'35.172.155.192/27', '35.172.155.96/27',  '18.206.107.24/29',
'3.217.228.0/22',    '52.23.61.0/24',     '52.23.62.0/24'
]

# aws_cidr = aws_cidr.filter(e=>(parseInt(e.split("/").slice(-1)[0]) <= 23 ))
aws_cidr = aws_cidr.uniq.select{|a| a.split('/').last.to_i <= 23}

browser = Watir::Browser.new
browser.goto 'https://cloud.mongodb.com/v2/5e4d8035563307449157f8d2#security/network/whitelist'
binding.pry 

browser.link(text: 'Network Access').click

# NASDAQ: GOOG : Google
# NASDAQ: AMZN : Amazon

gcp_cidr.each do |cidr|
  browser.link(text: 'Add IP Address').click
  browser.text_field(name: 'whitelistEntry').set cidr
  browser.text_field(name: 'comment').set 'Google'
  browser.button(text: 'Confirm').click
end

aws_cidr.each do |cidr|
  browser.link(text: 'Add IP Address').click
  browser.text_field(name: 'whitelistEntry').set cidr
  browser.text_field(name: 'comment').set 'Amazon'
  browser.button(text: 'Confirm').click
  sleep 1e0
end; nil

# browser.button(text: 'Delete').click
# ((1e2)*2**1).to_i.times{ browser.button(text: 'Delete').click }

# aws_cidr = aws_cidr.select{|a| a.split('/').last.to_i <= 20}
# h={}; aws_cidr.map{|a| net=a.split('/').last; h[net] ||= 0; h[net] += 1}.sort

# kshaikhr@salido.com
# kshaikhr
# Spotted20309#
