# Timepoint

**(Note: This was not vibe coded.)**

An extension of gleam_time functionality.

---

I really like the philosophy of gleam_time, but needed more detail and functionality, and I like the functionality of gtempo, but I was much more comfortable working with UNIX time as a base data type to derive everything from, and I wanted to work with ISO standards. So I decided to build up my own time functionality.

This bundle of code builds up from gleam_time to provide a bunch of extra features.

# New base types for time

UNIX timestamps are a really solid and excellent choice for timekeeping behind user-presenting information, but what if you want to do the same for localised datetimes? or days?

## Moments

A type that combines a Timestamp with an Offset.

A Timestamp is perfect for a non-ambiguous point in time, but without
an Offset, you can't tell what Day an event happened in,
therefore it can't be used to deduce a calendar datetime.

While gleam_time allows you to get the calendar day from a Timestamp through a function that lets you combine an offset, it would be really handy to be able to store the equivalent of a localised datetime already in a UNIX-ey format. That's what Moments are for.


```gleam
moment.system_time()
|> day.from_moment()
|> iso_date.from_day()

```

## Offsets

A lil type that supports the `Moment` type.


## Days

A `Day` is an representation of a specific solar day on Earth. This could be from the perspective of one location or one person (if they are journeying around the world that day, that day can be longer or shorter than 24 hours).

Under the hood, it is an epoch-based equivalent to a date in other datetime libraries. A Day type carries the same information as `2026-04-19` does, but with important distinctions:

- It's efficient.
- It's impossible to construct an invalid Day.
- There is no specific calendar representation attached, which means
you only need to work with the idiosyncracies of a particular
calendar system later rather than sooner.

```gleam
day.parse_iso8601("2026-04-20")
|> result.map(day.to_unix_days)
// Ok(20_563)
```


## Examples

These added types not only creates a nice structure for holding localising info, it also creates this clean track of information from capturing the user's time circumstances to generating calendar-based outputs, with each step getting less precise or generally more difficult to handle:

```gleam
moment.system_time()
|> day.from_moment()
|> iso_date.from_day()

```

With `Days` and the calendar handling in this bundle, you can dip into a calendar system, perform functions on that day, and then convert back out without committing to a fallible calendar system in storage, or to make it open to easy interpretation in other calendar systems:

```gleam
day_21st
|> iso_date.from_day
|> iso_date.closest_prev_day_of_week(iso_date.Monday)
|> iso_date.to_day
```


---

# More detailed calendar functionality


## ISO calendar

While the Gregorian calendar is a popular method of doing calendars, it's not standardised. For instance the starting day of the week can be different in different countries. I noticed that gtempo uses Sunday as the starting day, which is a US convention and not something shared in Europe. This took me by surprise when working with that library.

With that in mind my calendar functionality specifically follows ISO standards where applicable, and makes it clear in naming.


## ISO weeks and week dates

They're a niche but useful way of arranging time depending on the situation. I need them for my app!

```gleam
let week_days =
today
|> iso_week.from_day
|> iso_week.to_list
```

---

## Intervals/windowing

Make, manipulate and compare intervals of time against each other. You can make these intervals out of Days, Moments or Intervals.

Use intervals to check databases:

```gleam  
common_test.activity()
|> activity.slice(by: day_interval.new(start: this_day, final: next_day))
|> activity_slice.has_user_activity
|> should.equal(True)
```

Perform collision detection on intervals. You can compare Moment and Day-based types and intervals against each other:

```gleam
pub fn is_effective_in_moment_interval(
  variant: TLCurrentVariant(v),
  interval: MomentInterval,
) -> Bool {
  moment_interval.is_around_moment(interval, variant.start)
  || moment_interval.is_after_moment(interval, variant.start)
}

pub fn is_effective_in_day_interval(
  variant: TLCurrentVariant(v),
  interval: DayInterval,
) -> Bool {
  day_interval.is_around_moment(interval, variant.start)
  || day_interval.is_after_moment(interval, variant.start)
}

```

Turn DayIntervals into lists of days to build daily slices or views of data:

```gleam
activity_slice.interval
|> day_interval.to_list
```

Some of these Interval types help power functionality elsewhere in the package, such as ISO Weeks and versioning.

---

## JSON encode/decode

Each data type has functions for JSON encode/decode, since that's been a huge part of the app I'm working on. Is it a good idea for a package? Very likely not, and I'll probably remove it in a future commit.

----

# Future plans

- Make Interval constructors safe in a way that's not annoying to use.
- Find a nice way to say goodbye to the JSON code.
- Licensing! This uses some code from gleam_time, which is currently missing a license, so I don't feel comfortable licensing this code yet.

-----

# Acknowledgements

- The RFC3339 parsing comes from [gleam_time](https://gleam-time.hexdocs.pm/index.html) with some altered intermediary code for capturing and using offsets to make Moments.
