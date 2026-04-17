# Timepoint

I've been writing an application in Gleam that relies heavily on time and calendar types and functionality and using gleam_time and gtempo, but I found myself wishing for various kinds of functionality not offered by either, things like...

### Days without calendars

Unix Time offered by gleam_time's `Timestamp` is really good and useful, but there's no analogous type for specific days. Counting days without needing to consider the calendar system is really useful and has similar benefits to tracking Unix Time.

To achieve this I created a `Day` type - the naming is a little weird but I avoided using `Date` so it wouldn't be confused for a Gregorian date, trying to create that shift in mentality.

### Casting Timestamps into Days

Relatedly, I wanted to cast Unix Time types into Days, but a Unix Time could be in multiple days without an offset to contextualise the time. So I created an `Offset` type and a new `Moment` type, which combines Unix Time and `Offset`. Moments can be cast into Days, Unix Time cannot.

### Intervals of time

My app relies on storing and colliding intervals and points of time together for various features, so I created `DayInterval` and `MomentInterval` which store these intervals and provide various manipulation and collision features.

### Holding historical versions of a type

My app relies on holding and tracking historical changes to a type over time - either Moments or Days (This is the reason I made the interval types). 

The types (with interim names) `Calendrical` holds a type versioned by `Day`, and `Timelined` holds a type versioned by `Moment`.

### Specifying Gregorian calendars

While Gregorian is a popular method of doing calendars, it's not standardised. For instance the starting day of the week can be different in different countries. I noticed that gtempo uses Sunday as the starting day, which is a US convention and not something shared in Europe. This took me by surprise when programming.

So for my Gregorian functionality, I aim to explicitly follow ISO 8601 standards to reduce surprises.

### ISO Week Dates

ISO Week Dates are niche but an important part of how my app works with and frames time, so this code provides functionality for making ISO Weeks and ISO Week Dates.

----

# Plans

Right now, this is a little messy and borrows things from both gleam_time and gtempo.
In time I would like to...

- Move functionality to gleam_time where it makes sense to.
- Be more self-sufficient from gtempo.
- Probably replace `UnixTime` with gleam_time's `Timestamp`.
- Come up with neater and more consistent names for `Calendrical`, `Timelined` and related types.
