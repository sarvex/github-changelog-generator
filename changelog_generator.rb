#!/usr/bin/env ruby
# encoding: UTF-8

require 'github_api'
require 'json'

@project_path = '/Users/petrkorolev/repo/ActionSheetPicker-3.0'

@github_user = 'skywinder'
@github_repo_name = 'ActionSheetPicker-3.0'

tag1 = '1.1.21'
tag2 = '1.2.0'

def print_json(json)
  puts JSON.pretty_generate(json)
end

def exec_command(cmd)
  %x[cd #{@project_path} && #{cmd}]
end

def findTagsDates(tag1, tag2)
  value1 =  exec_command "git log --tags --simplify-by-decoration --pretty=\"format:%ci %d\" | grep #{tag1}"
  unless value1
    puts 'not found this tag'
    exit
  end


  unless /(.*)\s\(.*\)/.match(value1)[1]
    puts 'Not found any versions'
    exit
  end

  time = Time.parse(/(.*)\s\(.*\)/.match(value1)[1])
end

def getAllClosedPullRequests
  github = Github.new oauth_token: '8587bb22f6bf125454768a4a19dbcc774ea68d48'
  issues = github.pull_requests.list 'skywinder', 'ActionSheetPicker-3.0', :state => 'closed'
  json = issues.body

  json.each { |dict|
    # print_json dict
    # puts "##{dict[:number]} - #{dict[:title]} (#{dict[:closed_at]})"
  }

  json
end


def compund_changelog (tag_time, pull_requests)
  log = ''
  last_tag = exec_command('git describe --abbrev=0 --tags').strip
  log += "## [#{last_tag}] (https://github.com/#{@github_user}/#{@github_repo_name}/tree/#{last_tag})\n"
  time_string = tag_time.strftime "%Y/%m/%d"
  log += "#### #{time_string}\n"

  pull_requests.each { |dict|
    merge = "#{dict[:title]} (##{dict[:number]})\n"
  log += "- #{merge}"
  }

  puts log
  File.open('output.txt', 'w') { |file| file.write(log) }

end

tag_time = findTagsDates tag1, tag2

pull_requests = getAllClosedPullRequests

pull_requests.delete_if { |req|
  t = Time.parse(req[:closed_at]).utc
  t < tag_time
}


compund_changelog(tag_time, pull_requests)