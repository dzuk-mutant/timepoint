import gleam/time/calendar as gleam_calendar
import tempo/date.{Mon} as gtempo_date
import tempo/year
import day.{type Day}

/// Gets the gregorian calendar month from Gleam.
pub fn get_gleam_month(day: Day) -> gleam_calendar.Month {
  day
  |> day.to_gtempo_date
  |> gtempo_date.get_month
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- WEEKS ------------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn get_gtempo_day_of_week(day: Day) -> gtempo_date.DayOfWeek {
  day
  |> day.to_gtempo_date
  |> gtempo_date.to_day_of_week
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- DATES ------------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// Creates the most recent Monday behind the date, unless 
/// the given date is Monday, in which case that will be 
/// returned instead.
pub fn most_recent_monday_behind(day: Day) -> Day {
  let gtempo_date = day.to_gtempo_date(day)
  case gtempo_date.to_day_of_week(gtempo_date) {
    Mon -> day
    _ ->
      gtempo_date
      |> gtempo_date.prior_day_of_week(day_of_week: Mon)
      |> day.from_gtempo_date()
  }
}

pub fn to_tuple(day: Day) -> #(Int, Int, Int) {
  day
  |> day.to_gtempo_date
  |> gtempo_date.to_tuple
}

// checks if the first date is exactly one day after the second.
pub fn is_one_day_after(a: Day, from b: Day) {
  day.difference(b, from: a) == 1
}

/// Gets a number representing the Ordinal Day of a year out of a Day.
pub fn to_ordinal_day(day: Day) -> Int {
  let date = day.to_gtempo_date(day)
  let is_leap =
    date
    |> gtempo_date.get_year
    |> year.is_leap_year
  let month_no =
    date
    |> gtempo_date.get_month
  let start_of_month = case month_no, is_leap {
    gleam_calendar.January, _ -> 0
    gleam_calendar.February, _ -> 31
    gleam_calendar.March, False -> 59
    gleam_calendar.March, True -> 60
    gleam_calendar.April, False -> 90
    gleam_calendar.April, True -> 91
    gleam_calendar.May, False -> 120
    gleam_calendar.May, True -> 121
    gleam_calendar.June, False -> 151
    gleam_calendar.June, True -> 152
    gleam_calendar.July, False -> 181
    gleam_calendar.July, True -> 182
    gleam_calendar.August, False -> 212
    gleam_calendar.August, True -> 213
    gleam_calendar.September, False -> 243
    gleam_calendar.September, True -> 244
    gleam_calendar.October, False -> 273
    gleam_calendar.October, True -> 274
    gleam_calendar.November, False -> 304
    gleam_calendar.November, True -> 305
    gleam_calendar.December, False -> 334
    gleam_calendar.December, True -> 335
  }

  start_of_month + gtempo_date.get_day(date)
}

/// Returns day of week number, to ISO standards.
/// 
/// (The first day is Monday.)
pub fn to_day_of_week_number(day: Day) -> Int {
  let dow =
    day
    |> day.to_gtempo_date
    |> gtempo_date.to_day_of_week
  case dow {
    gtempo_date.Mon -> 1
    gtempo_date.Tue -> 2
    gtempo_date.Wed -> 3
    gtempo_date.Thu -> 4
    gtempo_date.Fri -> 5
    gtempo_date.Sat -> 6
    gtempo_date.Sun -> 7
  }
}
