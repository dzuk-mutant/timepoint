import day.{type Day}
import day_interval.{type DayInterval}
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/order.{Eq, Gt, Lt}

/// Represents a starting Day for the relevancy or effect of a piece of associated information.
/// 
/// The information should be considered 'in effect' as long as the context window is overlapping or after it.
pub opaque type CalCurrentVariant(v) {
  CalCurrentVariant(start: Day, value: v)
}

// ---------------------------------
// ---------------------------------
// ---------- CONSTRUCTOR ----------
// ---------------------------------
// ---------------------------------

/// Creates a new CurrentVariant.
/// 
/// Will switch the start and end around if they are in reverse order.
pub fn new(value value: v, start start: Day) -> CalCurrentVariant(v) {
  CalCurrentVariant(value:, start:)
}

// ---------------------------------
// ---------------------------------
// ------------ JSON ---------------
// ---------------------------------
// ---------------------------------

/// Converts a TLCurrentVariant into a JSON String.
pub fn to_json(
  variant: CalCurrentVariant(v),
  value_encoder value_encoder: fn(v) -> Json,
) -> Json {
  json.object([
    #("start", day.to_json(variant.start)),
    #("value", value_encoder(variant.value)),
  ])
}

pub fn decoder(
  value_decoder value_decoder: Decoder(v),
  default_value default_value: v,
) -> Decoder(CalCurrentVariant(v)) {
  let default =
    CalCurrentVariant(
      start: day.from_gtempo_literal("2025-03-10"),
      value: default_value,
    )

  decode.new_primitive_decoder("CalCurrentVariant", fn(variant) {
    let day_decoder = day.decoder()

    let variant_decoder = {
      use start <- decode.field("start", day_decoder)
      use value <- decode.field("value", value_decoder)
      decode.success(CalCurrentVariant(start:, value:))
    }

    case decode.run(variant, variant_decoder) {
      Error(_) -> Error(default)
      Ok(variant) -> Ok(variant)
    }
  })
}

// ---------------------------------
// ---------------------------------
// ------------ EDIT ---------------
// ---------------------------------
// ---------------------------------

/// Returns the value enclosed in a CalCurrentVariant.
pub fn overwrite_value(
  variant: CalCurrentVariant(v),
  with value: v,
) -> CalCurrentVariant(v) {
  CalCurrentVariant(..variant, value:)
}

// ---------------------------------
// ---------------------------------
// ---------- CONVERSION ------------
// ---------------------------------
// ---------------------------------

/// Returns the value enclosed in a CalCurrentVariant.
pub fn unwrap(variant: CalCurrentVariant(v)) -> v {
  variant.value
}

/// Returns the Day enclosed in a CalCurrentVariant.
pub fn to_start_day(variant: CalCurrentVariant(v)) -> Day {
  variant.start
}

// ---------------------------------
// ---------------------------------
// ------------ QUERY --------------
// ---------------------------------
// ---------------------------------

/// Checks if an CalCurrentVariant lands inside a DayInterval.
/// 
/// Will be True if the two intervals overlap, except where the end of the Effect is the same as the Query.
pub fn is_effective_in_day_interval(
  variant: CalCurrentVariant(v),
  interval: DayInterval,
) -> Bool {
  case day.compare(variant.start, day_interval.to_final(interval)) {
    Lt | Eq -> True
    Gt -> False
  }
}

/// Checks to see if the CalCurrentVariant is effective on a given day.
pub fn is_effective_on_day(variant: CalCurrentVariant(v), day: Day) -> Bool {
  day.is_earlier_or_equal(variant.start, to: day)
}

/// Checks to see if the CalCurrentVariant overlaps a given day.
/// 
/// It's an alias of active_on_day, which is probably going to be semantically useful going forward.
pub fn overlaps(variant: CalCurrentVariant(v), day: Day) -> Bool {
  is_effective_on_day(variant, day)
}
