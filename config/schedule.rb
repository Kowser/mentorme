# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Example
# every 1.day, at: '1:30 am' do
#   runner "User.do_something"
# 

require File.expand_path(File.dirname(__FILE__) + "/environment")
set :environment, Rails.env 
set :output, Rails.root.join('log','cron.log')

# every 1.minute do
# 	runner "Organization.send_dashboard_metrics"
# end
