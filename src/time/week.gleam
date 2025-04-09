import tempo.{type Date}
import tempo/date.{type DayOfWeek}
import time/extra/date as date_extra
import time/window/date_window.{type DateWindow}

pub fn date_window_from_date(date: Date) -> DateWindow {
  let monday = date_extra.most_recent_monday_behind(date)

  date_window.new(start: monday, final: date.add(monday, days: 6))
}

/// Creates a series of 7 Dates representing the week
/// from Monday that the given Date is in.
pub fn list_from_date(date: Date) -> List(Date) {
  date_window_from_date(date)
  |> date_window.to_date_list()
}

/// For certain views.
/// 
/// Hardcoded English strings for now.
pub fn day_of_week_to_letter(dow: DayOfWeek) -> String {
  case dow {
    date.Mon -> "M"
    date.Tue -> "T"
    date.Wed -> "W"
    date.Thu -> "T"
    date.Fri -> "F"
    date.Sat -> "S"
    date.Sun -> "S"
  }
}

/// Tempo's library treats Sunday as 0. I don't want that!
pub fn to_normalised_day_of_week_number(date: Date) -> Int {
  case date.to_day_of_week_number(date) {
    0 -> 7
    x -> x
  }
}
