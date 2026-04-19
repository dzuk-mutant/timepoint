import day.{type Day}
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import interval/day_interval.{type DayInterval}
import interval/moment_interval.{type MomentInterval}
import moment.{type Moment}

/// Represents a starting Moment for the relevancy or effect of a piece of associated information.
/// 
/// The information should be considered 'in effect' as long as the context window is overlapping or after it.
pub opaque type TLCurrentVariant(v) {
  TLCurrentVariant(start: Moment, value: v)
}

// ---------------------------------
// ---------------------------------
// ---------- CONSTRUCTOR ----------
// ---------------------------------
// ---------------------------------

/// Creates a new TLCurrentVariant.
/// 
/// Will switch the start and end around if they are in reverse order.
pub fn new(value value: v, start start: Moment) -> TLCurrentVariant(v) {
  TLCurrentVariant(value:, start:)
}

// ---------------------------------
// ---------------------------------
// ------------ JSON ---------------
// ---------------------------------
// ---------------------------------

/// Converts a TLCurrentVariant into a JSON String.
pub fn to_json(
  variant: TLCurrentVariant(v),
  value_encoder value_encoder: fn(v) -> Json,
) -> Json {
  json.object([
    #("start", moment.to_json(variant.start)),
    #("value", value_encoder(variant.value)),
  ])
}

pub fn decoder(
  value_decoder value_decoder: Decoder(v),
  default_value default_value: v,
) -> Decoder(TLCurrentVariant(v)) {
  let default =
    TLCurrentVariant(
      start: moment.from_gtempo_literal("2025-03-10T00:00:00.000Z"),
      value: default_value,
    )

  decode.new_primitive_decoder("CalCurrentVariant", fn(variant) {
    let moment_decoder = moment.decoder()

    let variant_decoder = {
      use start <- decode.field("start", moment_decoder)
      use value <- decode.field("value", value_decoder)
      decode.success(TLCurrentVariant(start:, value:))
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

/// Returns the value enclosed in a TLCurrentVariant.
pub fn overwrite_value(
  variant: TLCurrentVariant(v),
  with value: v,
) -> TLCurrentVariant(v) {
  TLCurrentVariant(..variant, value:)
}

// ---------------------------------
// ---------------------------------
// ---------- CONVERSION ------------
// ---------------------------------
// ---------------------------------

/// Returns the value enclosed in a TLCurrentVariant.
pub fn unwrap(variant: TLCurrentVariant(v)) -> v {
  variant.value
}

/// Returns the Moment enclosed in a TLCurrentVariant.
pub fn to_start_moment(variant: TLCurrentVariant(v)) -> Moment {
  variant.start
}

// ---------------------------------
// ---------------------------------
// ------------ QUERY --------------
// ---------------------------------
// ---------------------------------

/// Checks if an TLCurrentVariant is effective at some point in time inside a MomentInterval.
/// 
/// Will be True if the two intervals overlap, except where the end of the Effect is the same as the Query.
pub fn is_effective_in_moment_interval(
  variant: TLCurrentVariant(v),
  interval: MomentInterval,
) -> Bool {
  moment_interval.is_around_moment(interval, variant.start)
  || moment_interval.is_after_moment(interval, variant.start)
}

/// Checks if an TLCurrentVariant is effective at some point in time inside a DayInterval.
pub fn is_effective_in_day_interval(
  variant: TLCurrentVariant(v),
  interval: DayInterval,
) -> Bool {
  day_interval.is_around_moment(interval, variant.start)
  || day_interval.is_after_moment(interval, variant.start)
}

/// Checks if an TLCurrentVariant is effective at some point in time inside a given Day.
pub fn is_effective_on_day(variant: TLCurrentVariant(v), day: Day) -> Bool {
  day.is_earlier_or_equal(day.from_moment(variant.start), to: day)
}

/// Checks to see if the TLCurrentVariant overlaps a given Moment.
/// 
/// It's an alias of active_on_day, which is probably going to be semantically useful going forward.
pub fn overlaps(variant: TLCurrentVariant(v), moment: Moment) -> Bool {
  moment.is_earlier_or_equal(variant.start, to: moment)
}
