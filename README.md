# Timepoint

An extension of gleam_time functionality.

## Days, Offsets and Moments

This package adds complimentary types to `Timestamp`:

- `Days` provide an epoch-based way to work in days. This lets you create, track or store abstract days without caring about what calendar system it is.
- `Moments` combine `Timestamp` and `Offset` to create the minimum amount of data required to derive `Days` and calendar date/times. They hold a similar amount of information as a traditional datetime, but in a calendar-agnostic way.
- `Offsets` provide a generic container for time offsets.

I find that this not only creates a nice structure for holding localising info, it also
creates this clean track of information from Timestamps to calendar.


```gleam
timestamp.from_unix_seconds(0)
|> moment.from_timestamp(with: offset.from_mins(60))
|> day.from_moment()
|> iso_date.from_day()

```

---

## Intervals

My app relies on storing and colliding intervals and points of time together for various features, so I created `DayInterval` and `MomentInterval` which store these intervals and provide various manipulation and collision features.

----

## Holding historical versions of a type

My app relies on holding and tracking historical changes to a type over time - either Moments or Days (This is the reason I made the interval types). 

The types (with interim names) `Calendrical` holds a type versioned by `Day`, and `Timelined` holds a type versioned by `Moment`.

---

## Specific calendars

While Gregorian is a popular method of doing calendars, it's not standardised. For instance the starting day of the week can be different in different countries. I noticed that gtempo uses Sunday as the starting day, which is a US convention and not something shared in Europe. This took me by surprise when programming.

So for my Gregorian functionality, I aim to explicitly follow ISO 8601 standards to reduce surprises.

---

## ISO Week Dates

ISO Week Dates are niche but an important part of how my app works with and frames time, so this code provides functionality for making ISO Weeks and ISO Week Dates.

----

# Plans

Right now, this is a little messy and borrows things from both gleam_time and gtempo.
In time I would like to...

- Be more self-sufficient from gtempo.
- Provide more error checking in certain type constructors (especially Intervals). My app relies on stuff coming from the browser to tell it certain things, and if they're wrong then it's a critical failure, and I didn't want to needlessly unwrap Results, so I checked JSON input for sanity but not constructors. I would like to fix this in the future.
- Come up with neater and more consistent names for `Calendrical`, `Timelined` and related types.
