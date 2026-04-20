import day.{type Day}
import duration_extra
import gleam/int
import gleam/string
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

/// Returns an ISO 8601-formatted string.
/// 
/// ## Examples
/// ```gleam
/// day.parse_iso8601("2026-04-19")
/// |> result.unwrap(day.from_unix_days(0))
/// |> iso_date.from_day
/// |> iso_date.to_string
/// // "2026-04-19"
/// ```
pub fn to_string(date: ISODate) -> String {
  string.pad_start(to_year(date) |> int.to_string, to: 4, with: "0")
  <> "-"
  <> string.pad_start(to_month_number(date) |> int.to_string, to: 2, with: "0")
  <> "-"
  <> string.pad_start(to_day_number(date) |> int.to_string, to: 2, with: "0")
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

/// Returns the day number (1-31).
pub fn to_day_number(date: ISODate) -> Int {
  date.day_number
}

/// Returns the month (January - December).
pub fn to_month(date: ISODate) -> calendar.Month {
  date.month
}

/// Returns the month as a number (1 - 12).
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

/// Returns the year. (eg. 2026)
pub fn to_year(date: ISODate) -> Int {
  date.year
}

/// Returns day of week number, to ISO standards.
/// 
/// (The first day is Monday, which equals 1.)
pub fn to_day_of_week(date: ISODate) -> DayOfWeek {
  date
  |> to_day_of_week_number
  |> int_to_dow
}

/// Returns the day of the week as a number, in ISO standards.
/// 
/// Monday is 1 and Sunday is 7.
pub fn to_day_of_week_number(date: ISODate) -> Int {
  case int.modulo(day.to_unix_days(date.day) + 3, 7) {
    Error(Nil) -> panic as "modulo broke in an unexpected way."
    Ok(n) -> n + 1
  }
}

/// Returns a number representing the Ordinal Day of a year out of a Day.
/// 
/// This is useful if you want to know how many days of the year have
/// passed, including the given date.
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
    n if n >= 0 -> {
      day.add(date.day, 7 - n)
      |> from_day
    }
    _ -> {
      day.add(date.day, int.negate(diff))
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
  case to_day_of_week(date) == day_of_week {
    True -> date
    False -> prev_day_of_week(date, day_of_week)
  }
}

/// Looks for the next closest day of week
/// from the one given, including the current day.
pub fn closest_next_day_of_week(
  date: ISODate,
  day_of_week: DayOfWeek,
) -> ISODate {
  case to_day_of_week(date) == day_of_week {
    True -> date
    False -> next_day_of_week(date, day_of_week)
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
    calendar.May, _ -> 31
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
