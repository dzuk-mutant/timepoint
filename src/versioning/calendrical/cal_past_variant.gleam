import versioning/calendrical/cal_current_variant.{type CalCurrentVariant}

import day.{type Day}
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/result
import interval/day_interval.{type DayInterval}

///  A data type representing a version of a data type at a particular point in time in the past.
pub opaque type CalPastVariant(v) {
  CalPastVariant(value: v, interval: DayInterval)
}

// ---------------------------------
// ---------------------------------
// ----------- CONSTRUCTOR ---------
// ---------------------------------
// ---------------------------------

/// Makes a new variant starting at the specified Day
pub fn new(
  value value: v,
  start start: Day,
  final final: Day,
) -> CalPastVariant(v) {
  CalPastVariant(interval: day_interval.new(start:, final:), value:)
}

/// Takes a CalCurrentVariant and adds a final Day to create a CalPastVariant.
pub fn from_current_variant(
  current: CalCurrentVariant(v),
  end_excluding end_excluding: Day,
) -> CalPastVariant(v) {
  let start = cal_current_variant.to_start_day(current)
  let value = cal_current_variant.unwrap(current)

  CalPastVariant(
    interval: day_interval.new_with_end_excluding(start:, end_excluding:),
    value:,
  )
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- JSON ----------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// Converts a CalPastVariant into JSON.
pub fn to_json(
  variant: CalPastVariant(v),
  value_encoder value_encoder: fn(v) -> Json,
) -> Json {
  json.object([
    #("interval", variant.interval |> day_interval.to_json),
    #("value", variant.value |> value_encoder),
  ])
}

// A decoder for converting JSON into a CalPastVariant.
pub fn decoder(
  default_value default_value: v,
  value_decoder value_decoder: Decoder(v),
) -> Decoder(CalPastVariant(v)) {
  let default =
    CalPastVariant(
      interval: day_interval.new_single(day.testing_iso8601("2025-03-10")),
      value: default_value,
    )

  decode.new_primitive_decoder("CalPastVariant", fn(variant) {
    let day_interval_decoder = day_interval.decoder()

    let variant_decoder = {
      use interval <- decode.field("interval", day_interval_decoder)
      use value <- decode.field("value", value_decoder)

      decode.success(CalPastVariant(interval:, value:))
    }
    case decode.run(variant, variant_decoder) {
      Error(_) -> Error(default)
      Ok(variant) -> Ok(variant)
    }
  })
}

// ---------------------------------
// ---------------------------------
// ------------- EDIT --------------
// ---------------------------------
// ---------------------------------

/// Moves the final Day 1 day before the
/// given end_excluding Day.
/// 
/// Will return Result(day_interval.TruncateError)
/// if the given end_excluding Day is not a correct input.
pub fn truncate(
  variant: CalPastVariant(v),
  behind end_excluding: Day,
) -> Result(CalPastVariant(v), day_interval.TruncateError) {
  variant.interval
  |> day_interval.truncate(behind: end_excluding)
  |> result.map(fn(x) { CalPastVariant(..variant, interval: x) })
}

// ---------------------------------
// ---------------------------------
// ----------- CONVERSIONS ---------
// ---------------------------------
// ---------------------------------

/// Gets the start day.
pub fn to_start_day(variant: CalPastVariant(v)) -> Day {
  day_interval.to_start(variant.interval)
}

/// Gets the final day.
pub fn to_final_day(variant: CalPastVariant(v)) -> Day {
  day_interval.to_final(variant.interval)
}

/// Get the value.
pub fn unwrap(variant: CalPastVariant(v)) -> v {
  variant.value
}

/// Converts to a DayInterval. 
pub fn to_day_interval(variant: CalPastVariant(v)) -> DayInterval {
  variant.interval
}

// ---------------------------------
// ---------------------------------
// ---------- QUERY -----------
// ---------------------------------
// ---------------------------------

/// Checks if a Past Variant lands inside a Day Window.
/// 
/// Will be True if the two intervals overlap.
/// 
/// Similar but not exactly the same functionality as its TL counterpart.
pub fn is_effective_in_day_interval(
  variant: CalPastVariant(v),
  interval: DayInterval,
) {
  variant.interval
  |> day_interval.is_overlapped(by: interval)
}

/// Checks if a Past Variant is in effect on a certain Day.
pub fn is_effective_on_day(variant: CalPastVariant(v), day: Day) -> Bool {
  variant.interval
  |> day_interval.is_around_day(day)
}
