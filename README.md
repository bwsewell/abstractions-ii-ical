# Abstractions II iCal feed

Parses [public JSON](https://codeandsupply.co/event_sessions/abstractions.json) of event sessions for [Abstractions II](https://abstractions.io) and transforms to an iCal format.

```
bundle exec rackup config.ru
```

The event.ical file can be accessed at:

```
http://localhost:9292/events.ical
```
