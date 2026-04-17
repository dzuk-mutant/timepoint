import gleam/dynamic/decode.{type Decoder}
import gleam/int
import gleam/json.{type Json}
import gleam/order.{type Order, Eq, Gt, Lt}
import tempo.{type DateTime}
import tempo/datetime as gtempo_datetime
import duration.{type Duration}

/// A type representing a universal point in time, without any offset context.
/// 
/// This type can tell you when in UNIX time something happened, but cannot
/// contextualise it within calendar days and time.
/// 
/// This is useful for when you don't need to know what offset something
/// happened in; you just want the pure point in time at which something occurred.
pub opaque type UnixTime {
  UnixTime(unix_time: Int)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Converts a gtempo DateTime to a UnixTime.
/// 
/// WARNING: If the DateTime has an Offset, it will be ignored.
pub fn from_gtempo_datetime(datetime: DateTime) -> UnixTime {
  UnixTime(unix_time: gtempo_datetime.to_unix_milli(datetime))
}

/// Converts a gtempo-compatible literal string into a Day.
/// 
/// TESTING ONLY. Will panic if it's wrong.
/// WARNING: If the DateTime has an Offset, it will be ignored.
pub fn from_gtempo_datetime_literal(str: String) -> UnixTime {
  str
  |> gtempo_datetime.literal
  |> from_gtempo_datetime
}

/// Converts a UnixTime to a gtempo DateTime.
/// 
/// WARNING: It is best to use UnixTime conversions to/from
/// gtempo sparingly and with intent. Timepoint has a different
/// structure and perspective.
/// 
/// In all gtempo, the casual representation of time and
/// the time itself are the same, in Timepoint they are not.
/// 
/// Offsets are an important part of a gtempo DateTime, while in
/// Timepoint, Offsets only offer contextualising information to
/// a UnixTime that can already tell you everything about what
/// happened at a certain point in time.
///
/// Converting from gtempo DateTimes removes any offset that may
/// have been there.
pub fn to_gtempo_datetime_at_utc(um: UnixTime) -> DateTime {
  um.unix_time
  |> gtempo_datetime.from_unix_milli
}

/// Creates a UNIX time value from an Int.
pub fn from_int(unix_time: Int) -> UnixTime {
  UnixTime(unix_time:)
}

/// Returns the UNIX time value as an Int.
pub fn to_int(tso: UnixTime) -> Int {
  tso.unix_time
}

/// Returns the UNIX time value as a duration from the start of UNIX time.
pub fn to_duration_from_epoch(tso: UnixTime) -> Duration {
  tso.unix_time
  |> duration.millis
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- COMPARISON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Checks if two Moments are the same.
pub fn is_equal(um_1: UnixTime, to um_2: UnixTime) -> Bool {
  to_int(um_1) == to_int(um_2)
}

/// Compares UnixTime against each other.
pub fn compare(um_1: UnixTime, to um_2: UnixTime) -> Order {
  int.compare(to_int(um_1), with: to_int(um_2))
}

pub fn is_earlier(um_1: UnixTime, than um_2: UnixTime) -> Bool {
  compare(um_1, to: um_2) == Lt
}

pub fn is_earlier_or_equal(a: UnixTime, to b: UnixTime) -> Bool {
  let comparison = compare(a, to: b)
  comparison == Lt || comparison == Eq
}

pub fn is_later(um_1: UnixTime, than um_2: UnixTime) -> Bool {
  compare(um_1, to: um_2) == Gt
}

/// Gets the difference in days from the first and the second.
pub fn difference(a: UnixTime, from b: UnixTime) -> Int {
  to_int(b) - to_int(a)
}

/// Subtracts a specified number of days from the UnixTime.
pub fn add(tso: UnixTime, milli milli: Int) -> UnixTime {
  UnixTime(unix_time: tso.unix_time + milli)
}

/// Subtracts a specified number of days from the UnixTime.
pub fn subtract(tso: UnixTime, milli milli: Int) -> UnixTime {
  UnixTime(unix_time: tso.unix_time - milli)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ----------------------- JSON ------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const default: UnixTime = UnixTime(unix_time: 0)

/// The string function used for all DateTimes
/// in the Database apart from dict keys.
pub fn to_json(um: UnixTime) -> Json {
  um.unix_time |> json.int
}

pub fn decoder() -> Decoder(UnixTime) {
  decode.new_primitive_decoder("UnixTime", fn(unix_time) {
    case decode.run(unix_time, decode.int) {
      Error(_) -> Error(default)
      Ok(millis) -> Ok(from_int(millis))
    }
  })
}
