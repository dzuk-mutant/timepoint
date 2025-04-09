import gleam/order.{type Order}
import gleam/time/calendar
import tempo.{type Date}
import tempo/date.{Mon}
import tempo/year

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- WEEKS ------------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// Creates the most recent Monday behind the date, unless 
/// the given date is Monday, in which case that will be 
/// returned instead.
pub fn most_recent_monday_behind(date: Date) -> Date {
  case date.to_day_of_week(date) {
    Mon -> date
    _ -> date.prior_day_of_week(date, day_of_week: Mon)
  }
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- DATES ------------------------
// ----------------------------------------------------
// ----------------------------------------------------

// checks if the first date is exactly one day after the second.
pub fn is_one_day_after(date: Date, from comp: Date) {
  date.difference(comp, date) == 1
}

/// A reversed order function for dates. Used to order a
/// bunch of Maps across the application.
pub fn order_reverse(a: Date, b: Date) -> Order {
  date.compare(a, b)
  |> order.negate
}

/// Gets a number representing the Ordinal Date of a year out of a Date.
pub fn to_ordinal_day(date: Date) -> Int {
  let is_leap = date |> date.get_year |> year.is_leap_year
  let month_no = date |> date.get_month
  let start_of_month = case month_no, is_leap {
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

  start_of_month + date.get_day(date)
}
