# GoogleCalendar-MeetingsPerDay
Get an average of Calendar meetings per day of the week for your entire Google organization

## Pre-requisites
* A functional [GAMADV-XTD3](https://github.com/taers232c/GAMADV-XTD3/) setup
* A current build of Ruby and Ruby-Devel (I'm using 3.1.3)
* Ruby gems 'date' and 'csv'
* A text file with all users whose calendars you want to query

## How it works

1. Fetches calendars for all users defined in your Users.txt using GAM, over the specified window of dates
2. Iterates through every employee's calendar, counting the meeting hours on each day of the week
3. Averages them per day of the week, over the period of time specified, across all Users

Optional: You can choose to include or exclude meetings with <2 participants or externally created meetings.

## How to use

1. On Line 11, define the path to your Users.txt
2. On Lines 24 and 52, define the path where you want GAM to cache all of your user calendars
3. On Line 24, edit in the date ranges you want to query
4. [Optional] Comment out Lines 23-37 if you do NOT want GAM to fetch calendars. Useful if you've already fetched them
5. [Optional] Comment out Lines 66-70 if you want to INCLUDE meetings with <2 participants or geneated by external parties
6. Run with 'ruby gcal-meetingsPerDay.rb'

## Output

Results will look something like this:

`Mondays: 1100.2`

`Tuesdays: 1300.4`

`Wednesdays: 1400.3`

`Thursdays: 1410.1`

`Fridays: 1100.8`

You can then input these numbers into a spreadsheet and visualize it with a chart.
