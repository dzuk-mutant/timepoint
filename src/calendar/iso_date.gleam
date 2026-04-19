import day.{type Day}
import duration_extra
import gleam/int
import gleam/time/calendar.{type Month}
import gleam/time/duration
import gleam/time/timestamp

/// Contains the details of the ISO Date, plus the
/// Day, preserving it for chained usage.
pub type ISODate {
  ISODate(year: Int, month: Month, day_number: Int, day: Day)
}

pub type DayOfWeek {
  Monday
  Tuesday
  Wednesday
  Thursday
  Friday
  Saturday
  Sunday
}

// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ------------------- CONVERSION ---------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// Gets a Date from a Day.
pub fn from_day(day: Day) -> ISODate {
  let gleam_date =
    day
    |> day.to_unix_days
    |> duration_extra.days
    |> duration.to_seconds_and_nanoseconds
    |> fn(x) { x.0 }
    |> timestamp.from_unix_seconds
    |> timestamp.to_calendar(duration.minutes(0))
    |> fn(c) { c.0 }

  ISODate(
    year: gleam_date.year,
    month: gleam_date.month,
    day_number: gleam_date.day,
    day:,
  )
}

/// Convenience function that gives the Day.
/// 
/// Useful for piping!
/// 
/// ## Examples
/// ```gleam
/// day
/// |> iso_date.from_day
/// |> iso_date.prev_day_of_week(Monday)
/// |> iso_date.to_day
/// ```
pub fn to_day(date: ISODate) -> Day {
  date.day
}

/// Convenience function that gives the year.
/// 
/// Useful for piping!
pub fn to_year(date: ISODate) -> Int {
  date.year
}

/// Convenience function that gives the day number (1-31).
/// 
/// Useful for piping!
pub fn to_day_number(date: ISODate) -> Int {
  date.day_number
}

// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------- EXTRAPOLATION --------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn to_day_of_week_number(date: ISODate) -> Int {
  case int.modulo(day.to_unix_days(date.day) + 3, 7) {
    Error(Nil) -> panic as "modulo broke in an unexpected way."
    Ok(n) -> n + 1
  }
}

/// Returns day of week number, to ISO standards.
/// 
/// (The first day is Monday, which equals 1.)
pub fn to_day_of_week(date: ISODate) -> DayOfWeek {
  date
  |> to_day_of_week_number
  |> int_to_dow
}

/// Gets a number representing the Ordinal Day of a year out of a Day.
pub fn to_ordinal_day(date: ISODate) -> Int {
  let start_of_month = case date.month, calendar.is_leap_year(date.year) {
    calendar.January, _ -> 0
    calendar.February, _ -> 31
    calendar.March, False -> 59
    calendar.March, True -> 60
    calendar.April, False -> 90
    calendar.April, True -> 91
    calendar.May, False -> 120
    calendar.May, True -> 121
    calendar.June, False -> 151
    calendar.June, True -> 152
    calendar.July, False -> 181
    calendar.July, True -> 182
    calendar.August, False -> 212
    calendar.August, True -> 213
    calendar.September, False -> 243
    calendar.September, True -> 244
    calendar.October, False -> 273
    calendar.October, True -> 274
    calendar.November, False -> 304
    calendar.November, True -> 305
    calendar.December, False -> 334
    calendar.December, True -> 335
  }

  start_of_month + date.day_number
}

pub fn to_month_number(date: ISODate) -> Int {
  case date.month {
    calendar.January -> 1
    calendar.February -> 2
    calendar.March -> 3
    calendar.April -> 4
    calendar.May -> 5
    calendar.June -> 6
    calendar.July -> 7
    calendar.August -> 8
    calendar.September -> 9
    calendar.October -> 10
    calendar.November -> 11
    calendar.December -> 12
  }
}

// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// -------------------- ADVANCING ---------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// Looks for the previous closest day of week
/// from the one given, excluding the current day.
pub fn prev_day_of_week(date: ISODate, day_of_week: DayOfWeek) -> ISODate {
  let diff = to_day_of_week_number(date) - dow_to_int(day_of_week)

  case diff {
    n if n <= 0 -> {
      day.subtract(date.day, 7 + n)
      |> from_day
    }
    _ -> {
      day.subtract(date.day, diff)
      |> from_day
    }
  }
}

/// Looks for the next closest day of week
/// from the one given, excluding the current day.
pub fn next_day_of_week(date: ISODate, day_of_week: DayOfWeek) -> ISODate {
  let diff = to_day_of_week_number(date) - dow_to_int(day_of_week)

  case diff {
    n if n <= 0 -> {
      day.add(date.day, 7 + n)
      |> from_day
    }
    _ -> {
      day.add(date.day, diff)
      |> from_day
    }
  }
}

/// Looks for the previous closest day of week
/// from the one given, including the current day.
pub fn closest_prev_day_of_week(
  date: ISODate,
  day_of_week: DayOfWeek,
) -> ISODate {
  let diff = to_day_of_week_number(date) - dow_to_int(day_of_week)

  case diff {
    n if n <= 0 -> {
      date
    }
    _ -> {
      day.subtract(date.day, diff)
      |> from_day
    }
  }
}

/// Looks for the next closest day of week
/// from the one given, including the current day.
pub fn closest_next_day_of_week(
  date: ISODate,
  day_of_week: DayOfWeek,
) -> ISODate {
  let diff = to_day_of_week_number(date) - dow_to_int(day_of_week)

  case diff {
    n if n <= 0 -> {
      date
    }
    _ -> {
      day.add(date.day, diff)
      |> from_day
    }
  }
}

/// Returns an ISODate at the end of the month from the current ISODate.
pub fn last_of_month(date: ISODate) -> ISODate {
  let month_days = to_amount_of_days_in_month(date)

  let advance = month_days - date.day_number

  day.add(date.day, advance)
  |> from_day
}

// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- QUERY ------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------------------------------------

// checks if the first date is exactly one day after the second.
pub fn is_one_day_after(a: Day, from b: Day) {
  day.difference(b, from: a) == 1
}

// ----------------------------------------------------
// ----------------------------------------------------
// ----------------- INTERNAL HELPER ------------------
// ----------------------------------------------------
// ----------------------------------------------------

fn to_amount_of_days_in_month(date: ISODate) -> Int {
  case date.month, calendar.is_leap_year(date.year) {
    calendar.January, _ -> 31
    calendar.February, False -> 28
    calendar.February, True -> 29
    calendar.March, _ -> 31
    calendar.April, _ -> 30
    calendar.May, _ -> 30
    calendar.June, _ -> 30
    calendar.July, _ -> 31
    calendar.August, _ -> 31
    calendar.September, _ -> 30
    calendar.October, _ -> 31
    calendar.November, _ -> 30
    calendar.December, _ -> 31
  }
}

fn int_to_dow(int: Int) -> DayOfWeek {
  case int {
    1 -> Monday
    2 -> Tuesday
    3 -> Wednesday
    4 -> Thursday
    5 -> Friday
    6 -> Saturday
    7 -> Sunday
    _ -> Sunday
    // should not be possible
  }
}

fn dow_to_int(dow: DayOfWeek) -> Int {
  case dow {
    Monday -> 1
    Tuesday -> 2
    Wednesday -> 3
    Thursday -> 4
    Friday -> 5
    Saturday -> 6
    Sunday -> 7
    // should not be possible
  }
}
