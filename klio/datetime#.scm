(namespace
 ("datetime#"
  gambit:current-time
  time-tai
  time-utc
  time-monotonic
  time-thread
  time-process
  time-duration
  tm:locale-number-separator
  tm:locale-abbr-weekday-vector
  tm:locale-long-weekday-vector
  tm:locale-abbr-month-vector
  tm:locale-long-month-vector
  tm:locale-pm
  tm:locale-am
  tm:locale-date-time-format
  tm:locale-short-date-format
  tm:locale-time-format
  tm:iso-8601-date-time-format
  tm:nano
  tm:sid
  tm:sihd
  tm:tai-epoch-in-jd
  tm:time-error-types
  tm:time-error
  tm:read-tai-utc-data
  tm:leap-second-table
  read-leap-second-table
  tm:leap-second-delta
  tm:leap-second-neg-delta
  make-time
  time?
  time-type
  set-time-type!
  time-nanosecond
  set-time-nanosecond!
  time-second
  set-time-second!
  copy-time
  tm:get-time-of-day
  tm:current-time-utc
  tm:current-time-tai
  tm:current-time-ms-time
  tm:current-time-monotonic
  current-process-milliseconds
  tm:current-time-thread
  tm:current-time-process
  current-time
  time-resolution
  tm:time-compare-check
  time=?
  time>?
  time<?
  time>=?
  time<=?
  tm:time->nanoseconds
  tm:nanoseconds->time
  tm:nanoseconds->values
  tm:time-difference
  time-difference
  time-difference!
  tm:add-duration
  add-duration
  add-duration!
  tm:subtract-duration
  subtract-duration
  subtract-duration!
  tm:time-tai->time-utc!
  time-tai->time-utc
  time-tai->time-utc!
  tm:time-utc->time-tai!
  time-utc->time-tai
  time-utc->time-tai!
  time-monotonic->time-utc
  time-monotonic->time-utc!
  time-monotonic->time-tai
  time-monotonic->time-tai!
  time-utc->time-monotonic
  time-utc->time-monotonic!
  time-tai->time-monotonic
  time-tai->time-monotonic!
  make-date
  date?
  date-nanosecond
  tm:set-date-nanosecond!
  date-second
  tm:set-date-second!
  date-minute
  tm:set-date-minute!
  date-hour
  tm:set-date-hour!
  date-day
  tm:set-date-day!
  date-month
  tm:set-date-month!
  date-year
  tm:set-date-year!
  date-zone-offset
  tm:set-date-zone-offset!
  set-date-second!
  set-date-minute!
  set-date-day!
  set-date-month!
  set-date-year!
  set-date-zone-offset!
  tm:encode-julian-day-number
  tm:char-pos
  tm:fractional-part
  tm:decode-julian-day-number
  tm:local-tz-offset
  tm:time->julian-day-number
  tm:find
  tm:tai-before-leap-second?
  tm:time->date
  time-tai->date
  time-utc->date
  time-monotonic->date
  date->time-utc
  date->time-tai
  date->time-monotonic
  tm:leap-year?
  leap-year?
  tm:month-assoc
  tm:year-day
  date-year-day
  tm:week-day
  date-week-day
  tm:days-before-first-week
  date-week-number
  current-date
  tm:natural-year
  date->julian-day
  date->modified-julian-day
  time-utc->julian-day
  time-utc->modified-julian-day
  time-tai->julian-day
  time-tai->modified-julian-day
  time-monotonic->julian-day
  time-monotonic->modified-julian-day
  julian-day->time-utc
  julian-day->time-tai
  julian-day->time-monotonic
  julian-day->date
  modified-julian-day->date
  modified-julian-day->time-utc
  modified-julian-day->time-tai
  modified-julian-day->time-monotonic
  current-julian-day
  current-modified-julian-day
  tm:padding
  tm:last-n-digits
  tm:locale-abbr-weekday
  tm:locale-long-weekday
  tm:locale-abbr-month
  tm:locale-long-month
  tm:vector-find
  tm:locale-abbr-weekday->index
  tm:locale-long-weekday->index
  tm:locale-abbr-month->index
  tm:locale-long-month->index
  tm:locale-print-time-zone
  tm:locale-am/pm
  tm:tz-printer
  tm:directives
  tm:get-formatter
  tm:date-printer
  date->string
  tm:char->int
  tm:integer-reader
  tm:make-integer-reader
  tm:integer-reader-exact
  tm:make-integer-exact-reader
  tm:zone-reader
  tm:locale-reader
  tm:make-locale-reader
  tm:make-char-id-reader
  tm:read-directives
  tm:string->date
  string->date))
