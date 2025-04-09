import gleam/time/calendar

pub fn to_string(month: calendar.Month) {
  case month {
    calendar.January -> "January"
    calendar.February -> "February"
    calendar.March -> "March"
    calendar.April -> "April"
    calendar.May -> "May"
    calendar.June -> "June"
    calendar.July -> "July"
    calendar.August -> "August"
    calendar.September -> "September"
    calendar.October -> "October"
    calendar.November -> "November"
    calendar.December -> "December"
  }
}
