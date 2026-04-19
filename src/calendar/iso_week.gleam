import calendar/iso_date
import day.{type Day}
import gleam/list
import gleam/result
import interval/day_interval.{type DayInterval}
import tempo/date.{Sun} as gtempo_date

/// A type-enforced representation of a week
/// in ISO 8601 dates.
pub opaque type ISOWeek {
  ISOWeek(interval: DayInterval, week_no: Int, year: Int)
}

/// An unsafe constructor, for testing only.
pub fn unsafe_from_values(
  interval interval: DayInterval,
  week_no week_no: Int,
  year year: Int,
) {
  ISOWeek(interval:, week_no:, year:)
}

/// Creates a ISOWeek that surrounds a particular Day.
pub fn from_day(day: Day) -> ISOWeek {
  let monday = iso_date.most_recent_monday_behind(day)

  let tuple = tuple_from_day(day)

  ISOWeek(
    interval: day_interval.new(start: monday, final: day.add(monday, days: 6)),
    week_no: tuple.0,
    year: tuple.1,
  )
}

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// --------------------- batch  ----------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

/// Creates a list of ISOWeek intervals from an Interval.
/// 
/// Will only create ISOWeeks that are fully
/// encompassed by the given interval. If it only
/// encompasses partial weeks, the resulting list will be empty.
pub fn list_from_inside_interval(interval: DayInterval) -> List(ISOWeek) {
  case day_interval.length(interval) < 7 {
    True -> []
    False -> {
      inside_week_acc(
        current_day: day_interval.to_final(interval),
        end_day: day_interval.to_start(interval),
        interval:,
        acc: [],
      )
    }
  }
}

fn inside_week_acc(
  current_day current_day: Day,
  end_day end_day: Day,
  interval interval: DayInterval,
  acc acc: List(ISOWeek),
) -> List(ISOWeek) {
  case day.is_earlier(current_day, than: end_day) {
    True -> acc

    // try to accumulate
    False -> {
      let dow =
        current_day
        |> day.to_gtempo_date
        |> gtempo_date.to_day_of_week
      case { dow == Sun } {
        False -> {
          // search for Sunday BACKWARDS.
          inside_week_acc(
            current_day: current_day
              |> day.to_gtempo_date
              |> gtempo_date.prior_day_of_week(day_of_week: Sun)
              |> day.from_gtempo_date,
            end_day:,
            interval:,
            acc:,
          )
        }
        True -> {
          let monday = iso_date.most_recent_monday_behind(current_day)

          case day_interval.is_around_day(interval, monday) {
            False -> acc
            True -> {
              let new_week = from_day(monday)
              inside_week_acc(
                current_day: monday
                  |> day.subtract(1),
                end_day:,
                interval:,
                acc: [new_week, ..acc],
              )
            }
          }
        }
      }
    }
  }
}

/// Creates a list of isoweek intervals from an Interval.
/// 
/// Will create ISOWeeks that are overlapping the given interval.
/// 
/// So a list that partly or fully encompasses W12-W14 will
/// encompass a list that represents W12-W14.
pub fn list_from_around_interval(interval: DayInterval) -> List(ISOWeek) {
  let interval_start =
    interval
    |> day_interval.to_start

  let interval_start_dow =
    interval_start
    |> day.to_gtempo_date
    |> gtempo_date.to_day_of_week

  let interval_final =
    interval
    |> day_interval.to_final

  let interval_final_dow =
    interval_final
    |> day.to_gtempo_date
    |> gtempo_date.to_day_of_week

  // ---------------------------------

  let earliest_monday = case interval_start_dow {
    gtempo_date.Mon -> interval_start
    _ -> {
      interval_start
      |> day.to_gtempo_date
      |> gtempo_date.prior_day_of_week(gtempo_date.Mon)
      |> day.from_gtempo_date
    }
  }

  let latest_sunday = case interval_final_dow {
    gtempo_date.Sun -> interval_final
    _ -> {
      interval_final
      |> day.to_gtempo_date
      |> gtempo_date.next_day_of_week(gtempo_date.Sun)
      |> day.from_gtempo_date
    }
  }

  around_week_acc(current_sunday: latest_sunday, earliest_monday:, acc: [])
}

fn around_week_acc(
  current_sunday current_sunday: Day,
  earliest_monday earliest_monday: Day,
  acc acc: List(ISOWeek),
) -> List(ISOWeek) {
  case day.is_earlier(current_sunday, than: earliest_monday) {
    True -> acc

    // try to accumulate
    False -> {
      let new_week = from_day(current_sunday)
      around_week_acc(
        current_sunday: current_sunday
          |> day.subtract(7),
        earliest_monday:,
        acc: [new_week, ..acc],
      )
    }
  }
}

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ----------------- conversion  ---------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

/// Returns a DayInterval encompassing the given ISOWeek.
pub fn to_interval(week: ISOWeek) -> DayInterval {
  week.interval
}

/// Returns the week number of the given ISOWeek.
pub fn to_week_number(week: ISOWeek) -> Int {
  week.week_no
}

/// Returns the year of the given ISOWeek.
pub fn to_year(week: ISOWeek) -> Int {
  week.year
}

/// Gets the first day of the ISOWeek.
/// (Monday)
pub fn to_monday(week: ISOWeek) -> Day {
  week.interval
  |> day_interval.to_start
}

/// Creates a List of 7 Days that
/// the ISOWeek covers.
pub fn to_list(week: ISOWeek) -> List(Day) {
  week.interval
  |> day_interval.to_list()
}

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------- query-----------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

/// Checks if two ISOWeeks are the same as each other.
pub fn is_equal(a: ISOWeek, to b: ISOWeek) {
  a.week_no == b.week_no && a.year == b.year
}

/// Basic comparison function for two ISOWeeks.
pub fn compare(a: ISOWeek, to b: ISOWeek) {
  let a_start =
    a.interval
    |> day_interval.to_start

  let b_start =
    b.interval
    |> day_interval.to_start

  day.compare(a_start, to: b_start)
}

/// Reverse chronological comparison function for two ISOWeeks.
pub fn compare_reverse(a: ISOWeek, to b: ISOWeek) {
  let a_start =
    a.interval
    |> day_interval.to_start

  let b_start =
    b.interval
    |> day_interval.to_start

  day.compare_reverse(a_start, to: b_start)
}

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------- helper/internal ------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

/// Creates a week no / year tuple from a Day.
/// 
/// For construction.
fn tuple_from_day(day: Day) -> #(Int, Int) {
  let year =
    day
    |> day.to_gtempo_date
    |> gtempo_date.get_year

  let week_no = day_to_week_no(day)

  case week_no {
    0 -> {
      #(last_week_no_of_year(day), year - 1)
    }
    52 | 53 -> {
      let day_of_week =
        day
        |> day.to_gtempo_date
        |> gtempo_date.to_day_of_week

      case day_of_week {
        gtempo_date.Mon | gtempo_date.Tue | gtempo_date.Wed ->
          case last_dow_in_same_year(day) {
            False -> #(1, year + 1)
            True -> #(week_no, year)
          }
        _ -> #(week_no, year)
      }
    }
    _ -> #(week_no, year)
  }
}

/// Helper that manages overlaps by getting
/// the first date in the week of a boundary-
/// crossing week, and getting that date's week
/// number.
fn last_week_no_of_year(day: Day) -> Int {
  let start = iso_date.most_recent_monday_behind(day)

  day_interval.new(
    start:,
    final: day.add(iso_date.most_recent_monday_behind(day), 6),
  )
  |> day_interval.to_list
  |> list.map(day_to_week_no)
  |> list.first()
  |> result.unwrap(0)
}

/// Gets the week of year that functions in
/// ISO 8601 Week Dates.
/// 
/// If the resulting number is 0, it means it
/// belongs in the previous year's final week date.
fn day_to_week_no(day: Day) -> Int {
  let day_of_week = iso_date.to_day_of_week_number(day)
  let day_of_year = iso_date.to_ordinal_day(day)

  { day_of_year - day_of_week + 10 } / 7
}

/// Helper function that gets the last SheetOnDay of Week
/// of the year.
fn last_dow_in_same_year(day: Day) -> Bool {
  let last_dow =
    day
    |> day.to_gtempo_date
    |> gtempo_date.last_of_month
    |> gtempo_date.to_day_of_week

  case last_dow {
    gtempo_date.Mon | gtempo_date.Tue | gtempo_date.Wed -> False
    _ -> True
  }
}
