import gleam/list
import gleam/result
import tempo.{type Date}
import tempo/date
import time/extra/date as date_extra
import time/week

/// A type representing an ISO 8601 Week Date.
pub opaque type WeekDate {
  WeekDate(year: Int, week: Int, day: Int)
}

// ----------------------------------------------------
// ----------------------------------------------------
// -------------------- constructor -------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// An unsafe constructor, for testing only.
pub fn unsafe_from_values(year year: Int, week week: Int, day day: Int) {
  WeekDate(year:, week:, day:)
}

/// Creates an ISO 8601 Week Date from a normal Date.
pub fn from_date(date: Date) -> WeekDate {
  let tuple = date.to_tuple(date)

  let year = tuple.0
  let day_of_week = week.to_normalised_day_of_week_number(date)
  let week_of_year = date_to_week_of_year(date)

  case week_of_year {
    0 -> {
      WeekDate(
        day: day_of_week,
        week: get_last_week_no_in_week(date),
        year: year - 1,
      )
    }
    52 | 53 -> {
      case date.to_day_of_week(date) {
        // you need to make sure the final date is
        // in the range for this date to be included
        // in its year.
        date.Mon | date.Tue | date.Wed ->
          case last_dow_in_same_year(date) {
            False -> WeekDate(day: day_of_week, week: 1, year: year + 1)
            True -> WeekDate(day: day_of_week, week: week_of_year, year: year)
          }
        // this date is already in the right range, no check
        // required.
        _ -> WeekDate(day: day_of_week, week: week_of_year, year: year)
      }
    }
    _ -> WeekDate(day: day_of_week, week: week_of_year, year: year)
  }
}

// ----------------------------------------------------
// ----------------------------------------------------
// -------------------- conversion -------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// NOTE: This gives the year of the WeekDate,
/// not the year of this WeekDate's equivalent
/// Gregorian Calendar year.
pub fn to_year(week_date: WeekDate) -> Int {
  week_date.year
}

/// NOTE: This gives the ordinal week of the WeekDate,
/// not the week number of the equivalent
/// Gregorian Calendar date.
pub fn to_week(week_date: WeekDate) -> Int {
  week_date.week
}

/// NOTE: This day of week number is not the
/// same as gtempo's.
/// 
/// (in gtempo, Sunday is 0, in WeekDate, it's 7.)
pub fn to_day(week_date: WeekDate) -> Int {
  week_date.day
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------- helper -----------------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// Helper that manages overlaps by getting
/// the first date in the week of a boundary-
/// crossing week, and getting that date's week
/// number.
fn get_last_week_no_in_week(date: Date) -> Int {
  week.list_from_date(date)
  |> list.map(date_to_week_of_year)
  |> list.first()
  |> result.unwrap(0)
}

/// Gets the week of year that functions in
/// ISO 8601 Week Dates.
/// 
/// If the resulting number is 0, it means it
/// belongs in the previous year's final week date.
fn date_to_week_of_year(date: Date) -> Int {
  let day_of_week = week.to_normalised_day_of_week_number(date)
  let day_of_year = date_extra.to_ordinal_day(date)

  { 10 + day_of_year - day_of_week } / 7
}

/// Helper function that gets the last Day of Week
/// of the year.
fn last_dow_in_same_year(date: Date) -> Bool {
  let last_dow =
    date
    |> date.last_of_month
    |> date.to_day_of_week

  case last_dow {
    date.Mon | date.Tue | date.Wed -> False
    _ -> True
  }
}
