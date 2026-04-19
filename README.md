# Timepoint

An extension of gleam_time functionality.

---

## An ecosystem of calendar-agnostic time types

This package adds complimentary types to `Timestamp`:

- `Days` provide an epoch-based way to work in days. This lets you create, track or store abstract days without caring about what calendar system it is.
- `Offsets` provide a generic container for time offsets.
- `Moments` combine `Timestamp` and `Offset` to create the minimum amount of data required to derive `Days` and calendar date/times. They hold a similar amount of information as a traditional datetime, but in a calendar-agnostic way.

This not only creates a nice structure for holding localising info, it also creates this clean track of information from Timestamps to calendar.


```gleam
timestamp.from_unix_seconds(0)
|> moment.from_timestamp(with: offset.from_mins(60))
|> day.from_moment()
|> iso_date.from_day()

```

---

## More detailed calendar functionality

- Day of Week
- Going backwards/forwards by days of the week
- Ordinal days

### ISO calendar

While Gregorian is a popular method of doing calendars, it's not standardised. For instance the starting day of the week can be different in different countries. I noticed that gtempo uses Sunday as the starting day, which is a US convention and not something shared in Europe. This took me by surprise when programming.

So for my Gregorian functionality, I aim to explicitly follow ISO 8601 standards to reduce surprises.

### ISO weeks and week dates

They're a niche but useful way of arranging time depending on the situation.

### Internet Time

This is super-niche but has a special place in my heart :)

---

## Intervals

Interval types for Days, Moments and Timestamps, providing storage, manipulation and collision detection between various types.

Some of these Interval types help power functionality elsewhere in the package, such as ISO Weeks and versioning.

---

## Historical versioning

Hold and track historical changes to a type over time, with type-enforced intervals and type-enforced edit outcomes.

---


# Plans

- Remove code that relies on gtempo for certain functions.
- Make Interval constructors safe.
- Come up with neater and more consistent names for `Calendrical`, `Timelined` and related types.
