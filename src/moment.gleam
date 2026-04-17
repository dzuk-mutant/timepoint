import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/order.{type Order}
import gleam/result
import tempo.{type DateTime}
import tempo/datetime as gtempo_datetime
import tempo/naive_datetime as tempo_naive_datetime
import tempo/offset as tempo_offset
import offset.{type Offset}
import unix_time.{type UnixTime}

/// A type representing a universal point in time, plus offset context.
/// 
/// This type can tell you when in UNIX time something happened, and also
/// can tell you what time zone offset it happened in, allowing you
/// to deduce local calendar days and time.
/// 
/// This is useful when knowing when something happened should be
/// contextualised with the offset that that particular event took place with.
/// 
/// This is also important for being able to cast Moments to Solar Days;
/// without an Offset, it's unclear what day a Moment would fit into.
pub opaque type Moment {
  Moment(unix_time: UnixTime, offset: Offset)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn from_values(
  unix_time unix_time: Int,
  offset_mins offset_mins: Int,
) -> Moment {
  Moment(
    unix_time: unix_time.from_int(unix_time),
    offset: offset.from_minutes(offset_mins),
  )
}

/// Returns the UNIX time value of the Moment, without the contextualising offset.
pub fn to_unix_time(ts: Moment) -> UnixTime {
  ts.unix_time
}

/// Returns the Offset portion of a Moment.
pub fn to_offset(ts: Moment) -> Offset {
  ts.offset
}

/// Converts a gtempo DateTime to a Moment.
pub fn from_gtempo_datetime(datetime: DateTime) -> Moment {
  Moment(
    unix_time: datetime
      |> gtempo_datetime.to_unix_milli
      |> unix_time.from_int,
    offset: datetime
      |> gtempo_datetime.get_offset
      |> offset.from_gtempo_offset,
  )
}

/// Converts a gtempo-compatible literal string into a Day.
/// 
/// TESTING ONLY. Will panic if it's wrong.
pub fn from_gtempo_literal(str: String) -> Moment {
  str
  |> gtempo_datetime.literal
  |> from_gtempo_datetime
}

/// Converts a Moment to a gtempo DateTime.
/// 
/// Offsets are included in the gtempo output.
pub fn to_gtempo_datetime(ts: Moment) -> Result(DateTime, Nil) {
  //
  // tempo has an unexpected way of handling offsets.
  case offset.to_gtempo_offset(ts.offset) {
    Error(_) -> Error(Nil)
    Ok(offset) -> {
      let gtempo_offset_as_duration =
        offset
        |> tempo_offset.to_duration

      ts.unix_time
      |> unix_time.to_int
      |> gtempo_datetime.from_unix_milli
      |> gtempo_datetime.add(gtempo_offset_as_duration)
      |> gtempo_datetime.apply_offset
      |> tempo_naive_datetime.set_offset(offset)
      |> Ok
    }
  }
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- COMPARISON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Checks if the UnixTime portion of two Moments are equal.
pub fn is_equal(ts_1: Moment, to ts_2: Moment) -> Bool {
  to_unix_time(ts_1) == to_unix_time(ts_2)
}

/// Checks if the offset portion of two Moments are equal.
pub fn offset_is_equal(ts_1: Moment, to ts_2: Moment) -> Bool {
  offset.is_equal(to_offset(ts_1), to: to_offset(ts_2))
}

/// Compares the values of only the UnixTime against each other.
pub fn compare(ts_1: Moment, to ts_2: Moment) -> Order {
  unix_time.compare(to_unix_time(ts_1), to: to_unix_time(ts_2))
}

/// Reverse-chronological comparison function. Used a lot in this app.
pub fn compare_reverse(a: Moment, b: Moment) -> Order {
  compare(a, b)
  |> order.negate
}

pub fn is_earlier(ts_1: Moment, than ts_2: Moment) -> Bool {
  unix_time.is_earlier(to_unix_time(ts_1), than: to_unix_time(ts_2))
}

pub fn is_earlier_or_equal(a: Moment, to b: Moment) -> Bool {
  unix_time.is_earlier_or_equal(to_unix_time(a), to: to_unix_time(b))
}

pub fn is_later(ts_1: Moment, than ts_2: Moment) -> Bool {
  unix_time.is_later(to_unix_time(ts_1), than: to_unix_time(ts_2))
}

// Gets the difference between the UNIX time of both Moments.
pub fn difference(ts_1: Moment, from ts_2: Moment) -> Int {
  unix_time.difference(to_unix_time(ts_1), from: to_unix_time(ts_2))
}

/// Adds a specified number of milliseconds from the Moment's
/// UNIX time.
pub fn add(ts: Moment, milli milli: Int) -> Moment {
  Moment(unix_time: unix_time.add(to_unix_time(ts), milli:), offset: ts.offset)
}

/// Subtracts a specified number of milliseconds from the Moment's
/// UNIX time.
pub fn subtract(ts: Moment, milli milli: Int) -> Moment {
  Moment(
    unix_time: unix_time.subtract(to_unix_time(ts), milli:),
    offset: ts.offset,
  )
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ----------------------- JSON ------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// The string function used for all DateTimes
/// in the Database apart from dict keys.
pub fn to_json(ts: Moment) -> Json {
  json.object([
    #("unix_time", ts.unix_time |> unix_time.to_json),
    #("offset", ts.offset |> offset.to_json),
  ])
}

/// A version of DateTimes decoding for the application
/// as a Decoder primitive.
pub fn decoder() -> Decoder(Moment) {
  let default =
    Moment(
      // 8 March 2025
      unix_time: unix_time.from_int(1_741_392_000),
      offset: offset.from_minutes(0),
    )
  decode.new_primitive_decoder("DateTime", fn(datetime) {
    let offset_decoder = offset.decoder()
    let unix_milli_decoder = unix_time.decoder()

    let datetimestore_decoder = {
      use unix_time <- decode.field("unix_time", unix_milli_decoder)
      use offset <- decode.field("offset", offset_decoder)
      decode.success(Moment(unix_time:, offset:))
    }
    case decode.run(datetime, datetimestore_decoder) {
      Error(_) -> Error(default)
      Ok(ts) -> Ok(ts)
    }
  })
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// --------------------- HELPER ------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// A helper function for testing.
pub fn to_string(moment: Moment) -> String {
  moment
  |> to_gtempo_datetime
  |> result.unwrap(gtempo_datetime.literal("2001-01-01T00:00:00.000Z"))
  |> gtempo_datetime.to_string
}
