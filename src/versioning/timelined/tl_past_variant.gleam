import day.{type Day}
import day_interval.{type DayInterval}
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/result
import moment.{type Moment}
import moment_interval.{type MomentInterval}
import versioning/timelined/tl_current_variant.{type TLCurrentVariant}

///  A data type representing a version of a data type at a particular point in time in the past.
pub opaque type TLPastVariant(v) {
  TLPastVariant(value: v, interval: MomentInterval)
}

// ---------------------------------
// ---------------------------------
// ----------- CONSTRUCTOR ---------
// ---------------------------------
// ---------------------------------
/// Makes a new variant starting at the specified Moment
pub fn new(
  value value: v,
  start start: Moment,
  end_excluding end_excluding: Moment,
) -> TLPastVariant(v) {
  TLPastVariant(interval: moment_interval.new(start:, end_excluding:), value:)
}

/// Takes a TLCurrentVariant and adds an end Moment to create a TLPastVariant.
///
/// (For now, it will switch the start and end if the end is earlier than
/// the start, not at all desired behaviour but better than making myself
/// handle a result for an internal function.)
pub fn from_current_variant(
  current: TLCurrentVariant(v),
  end_excluding end_excluding: Moment,
) -> TLPastVariant(v) {
  let start = tl_current_variant.to_start_moment(current)
  let value = tl_current_variant.unwrap(current)

  TLPastVariant(interval: moment_interval.new(start:, end_excluding:), value:)
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

/// Converts a TLPastVariant into JSON.
pub fn to_json(
  variant: TLPastVariant(v),
  value_encoder value_encoder: fn(v) -> Json,
) -> Json {
  json.object([
    #("interval", variant.interval |> moment_interval.to_json),
    #("value", variant.value |> value_encoder),
  ])
}

// A decoder for converting JSON into a TLPastVariant.
pub fn decoder(
  default_value default_value: v,
  value_decoder value_decoder: Decoder(v),
) -> Decoder(TLPastVariant(v)) {
  let default =
    TLPastVariant(
      interval: moment_interval.new(
        start: moment.from_gtempo_literal("2025-03-10T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-04-11T00:00:00.000Z"),
      ),
      value: default_value,
    )

  decode.new_primitive_decoder("TLPastVariant", fn(variant) {
    let moment_interval_decoder = moment_interval.decoder()

    let variant_decoder = {
      use interval <- decode.field("interval", moment_interval_decoder)
      use value <- decode.field("value", value_decoder)

      decode.success(TLPastVariant(interval:, value:))
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

/// Moves the end Moment 1ms 
/// before the given end_excluding Moment.
/// 
/// Will return Result(moment_interval.TruncateError)
/// if the given end_excluding Moment is not a correct input.
pub fn truncate(
  variant: TLPastVariant(v),
  behind end_excluding: Moment,
) -> Result(TLPastVariant(v), moment_interval.TruncateError) {
  variant.interval
  |> moment_interval.truncate(behind: end_excluding)
  |> result.map(fn(x) { TLPastVariant(..variant, interval: x) })
}

// ---------------------------------
// ---------------------------------
// ----------- CONVERSIONS ---------
// ---------------------------------
// ---------------------------------

/// Gets the start Moment.
pub fn to_start_moment(variant: TLPastVariant(v)) -> Moment {
  moment_interval.to_start(variant.interval)
}

/// Gets the end Moment.
pub fn to_end_excluding_moment(variant: TLPastVariant(v)) -> Moment {
  moment_interval.to_end_excluding(variant.interval)
}

/// Get the value.
pub fn unwrap(variant: TLPastVariant(v)) -> v {
  variant.value
}

/// Converts to a MomentInterval. 
pub fn to_moment_interval(variant: TLPastVariant(v)) -> MomentInterval {
  variant.interval
}

// ---------------------------------
// ---------------------------------
// -------------- QUERY ------------
// ---------------------------------
// ---------------------------------

/// Checks if a Past Variant lands inside a MomentInterval.
/// 
/// Will be True if the two overlap.
/// 
/// Exactly the same functionality as its Cal counterpart, just with moments.
pub fn is_effective_in_moment_interval(
  variant: TLPastVariant(v),
  interval: MomentInterval,
) -> Bool {
  variant.interval
  |> moment_interval.is_overlapped(by: interval)
}

/// Checks if a Past Variant lands inside a DayInterval.
/// 
/// Will be True if the two overlap.
pub fn is_effective_in_day_interval(
  variant: TLPastVariant(v),
  interval: DayInterval,
) -> Bool {
  variant.interval
  |> moment_interval.is_overlapped_by_day_interval(by: interval)
}

/// Checks if a Past Variant lands on a Day.
/// 
/// WIll be true if the range of Moment encompasses the Day in some way. 
pub fn is_effective_on_day(variant: TLPastVariant(v), day: Day) -> Bool {
  variant.interval
  |> moment_interval.is_around_day(day)
}
