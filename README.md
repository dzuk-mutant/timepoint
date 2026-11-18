# Timepoint

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
therefore it can't be used to deduce a calendar date/time.

While gleam_time offers the ability to produce a calendar date by
adding an offset to a Timestamp, there are many cases where it's useful
to carry an offset with a Timestamp as a type, such as when you want
to capture when a user did something, in the time circumstances that they did it.


```gleam
|> moment.system_time()
|> day.from_moment()
|> iso_date.from_day()

```

## Offsets

A lil type that supports the `Moment` type.


## Days

A `Day` is an abstract representation of a specific solar day on Earth. This could be from the perspective of one location or one person (if they are journeying around the world that day).

`Day` is roughly analogous to a Date type in other systems - a
Day carries the same information as `2026-04-19` does, but
with important distinctions:

- It's efficient.
- It's impossible to construct an invalid Day.
- There is no specific calendar representation attached, which means
you only need to work with the idiosyncracies of a particular
calendar system later rather than sooner.

```gleam
day.parse_iso8601("2026-04-20")
|> result.map(day.to_unix_days)
Ok(20_563)
```


## Examples

These added types not only creates a nice structure for holding localising info, it also creates this clean track of information from capturing the user's time circumstances to generating calendar-based outputs, with each step getting less precise or more difficult to handle:\*

```gleam
|> moment.system_time()
|> day.from_moment()
|> iso_date.from_day()

```

\* *(though, it's always possible to reconstruct Days from ISODates, as ISODates always contain the original Day.)*



---

# More detailed calendar functionality

- Day of Week (made back when gleam_time didn't have day of week stuff)
- Going backwards/forwards by days of the week
- Ordinal days


## ISO calendar

While Gregorian is a popular method of doing calendars, it's not standardised. For instance the starting day of the week can be different in different countries. I noticed that gtempo uses Sunday as the starting day, which is a US convention and not something shared in Europe. This took me by surprise when programming.

So for my Gregorian functionality, I aim to explicitly follow ISO 8601 standards to reduce surprises. Maybe this could be made more flexible in the future, but the app I'm making this for only needs an ISO calendar for very specific technical reasons.


## ISO weeks and week dates

They're a niche but useful way of arranging time depending on the situation. I needed them for my app!


---

## Intervals/windowing

Make, manipulate and compare intervals of time against each other. You can make these intervals out of Days, Moments or Intervals. You can compare MomentIntervals with Days and DayIntervals!.

Some of these Interval types help power functionality elsewhere in the package, such as ISO Weeks and versioning.

---

## Historical versioning

Hold and track historical changes to a type over time, with type-enforced intervals and type-enforced edit outcomes.

This might be very niche, and the naming conventions are weird right now, but it is a huge part of the app I'm working on, and I think it's quite neat.

```gleam
calendrical.new(
  with: "whatever",
  starting_at: day.testing_iso8601("2025-02-02"),
  equality_fn: eq_func,
)
|> calendrical.insert_new_current(
  with: "new thing",
  starting_at: day.testing_iso8601("2025-02-18"),
)
```

---

## JSON encode/decode

Each data type has functions for JSON encode/decode, since that's been a huge part of the app I'm working on. Is it a good idea for a package? Probably not, but it's in this bundle of code, and it's tightly integrated to the extent that it's worse to take it out at the moment...

----

# Future plans

- Make Interval constructors safe.
- Come up with neater and more consistent names for `Calendrical`, `Timelined` and related types.

-----

# Acknowledgements

- The RFC3339 parsing comes from [gleam_time](https://gleam-time.hexdocs.pm/index.html) with some altered intermediary code for capturing and using offsets to make Moments.
