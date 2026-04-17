import day.{type Day}
import day_interval.{type DayInterval}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import versioning/calendrical/cal_any_variant.{type CalAnyVariant, Current, Past}
import versioning/calendrical/cal_current_variant.{type CalCurrentVariant}
import versioning/calendrical/cal_past_variant.{type CalPastVariant}

/// A slice of a Calendrical. When a Calendrical is 
/// filtered, this type is returned.
pub type CalSlice(v) {
  CalSlice(
    interval: DayInterval,
    current: Option(CalCurrentVariant(v)),
    history: List(CalPastVariant(v)),
  )
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// --------------------- CONSTRUCTOR --------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
pub fn new(
  interval interval: DayInterval,
  current current: Option(CalCurrentVariant(v)),
  history history: List(CalPastVariant(v)),
) -> CalSlice(v) {
  CalSlice(interval:, current:, history:)
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------- QUERY ----------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Checks if a CalSlice is empty.
pub fn is_empty(slice: CalSlice(v)) -> Bool {
  slice.current == None && list.is_empty(slice.history)
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// --------------------- CONVERSIONS --------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Converts a CalSlice to a list of AnyVariants.
/// 
/// For when you just need to map over stuff.
/// 
/// You will lose the bounding data for the Slice
/// with this operation.
/// 
pub fn to_any_list(slice: CalSlice(v)) -> List(CalAnyVariant(v)) {
  let mapped_history =
    slice.history
    |> list.map(fn(x) { Past(x) })

  case slice.current {
    Some(current) -> [Current(current), ..mapped_history]
    None -> mapped_history
  }
}

pub fn to_start_day(slice: CalSlice(v)) -> Day {
  day_interval.to_start(slice.interval)
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------ CHOP/GET --------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Filters a CalSlice with a new DayInterval.
pub fn chop(slice: CalSlice(v), by new_interval: DayInterval) -> CalSlice(v) {
  let current = case slice.current {
    None -> None
    Some(c) ->
      case cal_current_variant.is_effective_in_day_interval(c, new_interval) {
        False -> None
        True -> Some(c)
      }
  }

  let history =
    slice.history
    |> list.filter(keeping: fn(x) {
      cal_past_variant.is_effective_in_day_interval(x, new_interval)
    })

  CalSlice(interval: new_interval, current:, history:)
}

pub fn get_variant_by_day(
  slice: CalSlice(v),
  day: Day,
) -> Result(CalAnyVariant(v), Nil) {
  case slice.current {
    Some(current) ->
      case cal_current_variant.is_effective_on_day(current, day) {
        True -> Ok(Current(current))
        False -> get_variant_in_history(slice, day)
      }
    None -> get_variant_in_history(slice, day)
  }
}

fn get_variant_in_history(
  slice: CalSlice(v),
  day: Day,
) -> Result(CalAnyVariant(v), Nil) {
  slice.history
  |> list.find(fn(x) { cal_past_variant.is_effective_on_day(x, day) })
  |> result.map(fn(x) { Past(x) })
}
