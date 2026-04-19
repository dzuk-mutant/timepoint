import calendar/iso_date
import calendar/iso_week.{type ISOWeek}
import day.{type Day}

/// A type representing an ISO 8601 Week Date.
/// 
/// ISO Week Dates are not the same as ISO Dates - 
/// for instance, years are not calculated the same.
/// 
/// See the Wikipedia article on ISO week dates for
/// more information - https://en.wikipedia.org/wiki/ISO_week_date
pub opaque type ISOWeekDate {
  ISOWeekDate(day_no: Int, iso_week: ISOWeek, day: Day)
}

// ----------------------------------------------------
// ----------------------------------------------------
// -------------------- constructor -------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// An unsafe constructor, for testing only.
pub fn unsafe_from_values(
  year year: Int,
  week_no week_no: Int,
  day_no day_no: Int,
  day day: Day,
) {
  let interval =
    day
    |> iso_week.from_day
    |> iso_week.to_interval

  ISOWeekDate(
    day_no:,
    iso_week: iso_week.unsafe_from_values(week_no:, year:, interval:),
    day:,
  )
}

/// A constructor that gets an entire ISOWeekDate
/// from one Day.
pub fn from_day(day: Day) -> ISOWeekDate {
  let date = iso_date.from_day(day)
  ISOWeekDate(
    day_no: iso_date.to_day_of_week_number(date),
    iso_week: iso_week.from_day(day),
    day:,
  )
}

// ----------------------------------------------------
// ----------------------------------------------------
// -------------------- conversion -------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// Provides the year value contextual to the ISO Week Date -
/// this is not always the same as the year value in an ISO Date.
pub fn to_year(week_date: ISOWeekDate) -> Int {
  week_date.iso_week
  |> iso_week.to_year
}

/// Provides the week number.
pub fn to_week_number(week_date: ISOWeekDate) -> Int {
  week_date.iso_week
  |> iso_week.to_week_number
}

/// Provides the day number - 1-7, representing Monday-Sunday.
pub fn to_day_number(week_date: ISOWeekDate) -> Int {
  week_date.day_no
}
