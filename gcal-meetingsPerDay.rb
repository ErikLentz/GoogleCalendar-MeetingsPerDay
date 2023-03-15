#!/usr/bin/ruby
# This script will, given a list of users, and a good GAMADV-XTD3 setup,
# pull the averages of all meetings by day of the week

require 'date'
require 'CSV'

# Pull list of users from text file, into an array.
# Replace the path beow with the path to your text file containing
# full email addresses, one per line
users = File.readlines("/path/to/your/user-list.txt").map(&:chomp)

# Count the total number of users, which we will use to track progress later
@user_total = users.count

# Initialize the counter we will use to track progress on the GAM fetches
@gam_get_count = 0

# Comment this section if you DO NOT want to perform the GAM fetches
# Replace the CSV path at the end of the gam command to your preferred path
# Replace the date range below with the dates you want to query
#
 users.each do |user|
   system("gam calendar #{user} print events after 2021-07-01 before 2021-12-31 fields summary,starttime,attendees > /path/to/cache/user-calendars/#{user}.csv")
   puts "Got #{user}, #{@gam_get_count}/#{@user_total}"
   @gam_get_count += 1
 end

# Initialize the counters we'll use to track events per day
@mondays = 0
@tuesdays = 0
@wednesdays = 0
@thursdays = 0
@fridays = 0

# Initialize failure counter, we can add event IDs here and check them later
# as needed
@fails = []

# Initialize the counter for processing users
@user_count = 0

# Initialize the array to which we'll track all processed event IDs,
# which we will check on each iteration so we don't count events twice.
@event_ids = []

# Main event processing loop
users.each do |user|
  puts "Processing events for #{user}..."
  # Open the file from the dir you saved the CSVs to
  # Replace dir below with your dir
  datafile = File.open("/path/to/cache/user-calendars/#{user}.csv")
  # Parse the CSV into an array of hashes, where each row/hash is one event
  userdata = CSV.parse(File.read(datafile), headers: true, header_converters: :symbol).map(&:to_h)
  # Iterate over the events
  userdata.each do |event|
    # Set up error handling so we can catch failures gracefully
    begin
      # Check processed event IDs, skip if we've already done this one
      if @event_ids.include? event[:id]
        next
      end
      # This section will omit events with 1 or fewer attendees, as well as
      # events created by external parties (ID starts with "_").
      # Comment this section if you want to include those events.
      if event[:attendees].to_i < 2
        next
      elsif event[:id].start_with?("_")
        next
      end
      # Check to see if this event is a recurrence rather than a parent event.
      # Recurrences have a "_" followed by the DateTime
      if event[:id].start_with?("_")
        if event[:startdatetime]
          event_date = DateTime.strptime(event[:startdatetime], '%Y-%m-%d')
          day_of_week = event_date.wday
        elsif event[:startdate]
          event_date = DateTime.strptime(event[:startdate], '%Y-%m-%d')
          day_of_week = event_date.wday
        else
          next
        end
      elsif event[:id].include? "_" #and event[:startdatetime].nil?
        rawdate = event[:id].split('_')[1]
        if rawdate.start_with?("R")
          rawdate.slice!(0)
        end
        event_date = DateTime.strptime(rawdate, "%Y%m%d")
        day_of_week = event_date.wday
      elsif event[:startdatetime].nil?
        event_date = DateTime.strptime(event[:startdate], '%Y-%m-%d')
        day_of_week = event_date.wday
      else
        event_date = DateTime.strptime(event[:startdatetime], '%Y-%m-%d')
        day_of_week = event_date.wday
      end
      # Add this one to the list of processed IDs
      @event_ids << event[:id]
    rescue
      @fails << event[:id]
      next
    end
    case day_of_week
    when 1
      @mondays += 1
    when 2
      @tuesdays += 1
    when 3
      @wednesdays += 1
    when 4
      @thursdays += 1
    when 5
      @fridays += 1
      end
      rescue
        @fails << event[:id]
      end
    end
  end
  @user_count += 1
  puts "#{@user_count}/#{@user_total}"
end;0

report = ["Mondays: #{(@mondays.to_f / 26.0).round(1)}",
  "Tuesdays: #{(@tuesdays.to_f / 26.0).round(1)}",
  "Wednesdays: #{(@wednesdays.to_f / 26.0).round(1)}",
  "Thursdays: #{(@thursdays.to_f / 26.0).round(1)}",
  "Fridays: #{(@fridays.to_f / 26.0).round(1)}",

report.each do |dow|
  puts dow
end;0
