import duration_extra
import gleam/dynamic/decode.{type Decoder}
import gleam/int
import gleam/json.{type Json}
import gleam/order.{type Order}
import gleam/time/calendar
import gleam/time/duration.{type Duration}
import tempo
import tempo/duration as gtempo_duration
import tempo/offset as gtempo_offset

/// Offsets are the measure by which time is shifted in timezones.
/// 
/// ## On validity
/// 
/// This module constructor assumes the minutes coming in are
/// within correct bounds, and does not check to see if it does.
/// 
/// As of April 2026, the current minimum offset is -12hrs
/// (-720 minutes) and the maximum is +14hrs (+840 minutes).
/// These are political constructs, and may not be the same in
/// the future.
/// 
/// If you need to guard against offsets being created that don't
/// exist currently, you will need to create extra functionality.
/// 
/// ## Time zones
/// 
/// A time zone is a region of the Earth that observes certain
/// kinds of offset patterns. This module does not cover
/// time zones, just offsets that may happen to be a part of a
/// particular time zone.
/// 
pub opaque type Offset {
  Offset(minutes: Int)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Converts an Offset into a Duration.
pub fn to_duration(offset: Offset) -> Duration {
  offset.minutes
  |> duration.minutes
}

/// Converts an Offset into an Int representing minutes.
pub fn to_minutes(offset: Offset) -> Int {
  offset.minutes
}

/// Gets the current offset from the computer that is
/// executing this function.
pub fn from_local() -> Offset {
  calendar.local_offset()
  |> from_duration
}

/// Creates an Offset from an Int representing minutes.
/// 
/// ## Examples
/// ```gleam
/// offset.from_minutes(60)
/// ```
pub fn from_minutes(mins: Int) -> Offset {
  Offset(minutes: mins)
}

/// Creates an Offset from a Duration.
/// 
/// ## Examples
/// 
/// ```gleam
/// duration.minutes(60)
/// |> offset.from_duration
/// ```
pub fn from_duration(duration: Duration) -> Offset {
  duration
  |> duration_extra.as_minutes
  |> from_minutes
}

/// Creates an Offset from a gtempo offset.
pub fn from_gtempo_offset(offset: tempo.Offset) -> Offset {
  Offset(
    minutes: offset
    |> gtempo_offset.to_duration
    |> gtempo_duration.as_minutes,
  )
}

/// Converts an Offset type in this package to one used by gtempo.
pub fn to_gtempo_offset(offset: Offset) -> Result(tempo.Offset, Nil) {
  offset.minutes
  |> gtempo_duration.minutes
  |> gtempo_offset.from_duration
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- COMPARISON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Returns True if both Offsets are equal.
pub fn is_equal(offset_1: Offset, to offset_2: Offset) -> Bool {
  to_minutes(offset_1) == to_minutes(offset_2)
}

/// Compares the values of each offset against each other.
pub fn compare(offset_1: Offset, to offset_2: Offset) -> Order {
  int.compare(to_minutes(offset_1), with: to_minutes(offset_2))
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ---------------------- JSON -------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const default: Offset = Offset(minutes: 0)

pub fn to_json(offset: Offset) -> Json {
  offset.minutes
  |> json.int()
}

pub fn decoder() -> Decoder(Offset) {
  decode.new_primitive_decoder("Offset", fn(offset) {
    case decode.run(offset, decode.int) {
      Error(_) -> Error(default)
      Ok(mins) -> Ok(from_minutes(mins))
    }
  })
}
