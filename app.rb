require 'active_support'
require 'active_support/core_ext'
require 'net/http'
require 'json'
require 'sinatra/base'
require 'icalendar'
require 'icalendar/tzinfo'

class App < Sinatra::Base

  CODE_AND_SUPPLY_URI = 'https://codeandsupply.co/event_sessions/abstractions.json'

  get '/events.ical' do
    uri = URI(CODE_AND_SUPPLY_URI)
    res = Net::HTTP.get_response(uri)
    events = JSON.parse(res.body)

    cal = Icalendar::Calendar.new
    tzid = "UTC"
    cal.timezone.tzid = tzid

    events.each do |event|
      ical_event = Icalendar::Event.new
      begin
        event_start = Time.parse(event['starts_at'])
        ical_event.dtstart = Icalendar::Values::DateTime.new(
          DateTime.civil(
            event_start.year,
            event_start.month,
            event_start.day,
            event_start.hour,
            event_start.min
          ),
          tzid: tzid,
        )
        event_end = Time.parse(event['ends_at'])
        ical_event.dtend = Icalendar::Values::DateTime.new(
          DateTime.civil(
            event_end.year,
            event_end.month,
            event_end.day,
            event_end.hour,
            event_end.min
          ),
          tzid: tzid,
        )
      rescue
        next
      end
      ical_event.summary = event['title']
      ical_event.description = <<~BODY
        #{event.dig('presenter','name')}

        #{event['body']}
      BODY
      ical_event.location = event['room']
      cal.add_event(ical_event)
    end

    cal.publish

    cal.to_ical
  end

end
