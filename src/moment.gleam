import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result
import gleam/time/duration.{type Duration}
import gleam/time/timestamp.{type Timestamp}
import offset.{type Offset}
import tempo.{type DateTime}
import tempo/datetime as gtempo_datetime
import tempo/naive_datetime as tempo_naive_datetime
import tempo/offset as tempo_offset
import timestamp_extra

/// A type that combines a Timestamp with an Offset.
/// 
/// A Timestamp is perfect for a non-ambiguous point in time, but without
/// an Offset, it can't tell you what solar day an event happened in,
/// and it can't be used to deduce a calendar date/time.
/// 
/// While gleam/time offers the ability to produce a calendar date by 
/// adding an offset to a Timestamp, there are many cases where it's useful
/// to carry an offset with a Timestamp as a type.
/// 
/// Moments keep the best parts of Timestamp while adding the minimum
/// possible information to derive Days, dates and times.
///
/// ```gleam
/// 
/// timestamp.from_unix_seconds(1_718_234_444_923)
/// |> moment.from_timestamp(at: offset.from_minutes(60))
/// |> day.from_moment
/// |> iso_date.from_day
/// ```
/// 
/// Because Offsets don't tell us when something happened, only a
/// contextualision detail, Moments are compared to each other
/// exactly the same as Timestamps.
/// 
pub opaque type Moment {
  Moment(timestamp: Timestamp, offset: Offset)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn from_timestamp(timestamp: Timestamp, with offset: Offset) -> Moment {
  Moment(timestamp:, offset:)
}

/// Returns the UNIX time value of the Moment, without the contextualising offset.
pub fn to_timestamp(moment: Moment) -> Timestamp {
  moment.timestamp
}

/// Returns the Offset portion of a Moment.
pub fn to_offset(moment: Moment) -> Offset {
  moment.offset
}

/// Converts a gtempo DateTime to a Moment.
pub fn from_gtempo_datetime(datetime: DateTime) -> Moment {
  Moment(
    timestamp: datetime
      |> gtempo_datetime.to_timestamp,
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
pub fn to_gtempo_datetime(moment: Moment) -> Result(DateTime, Nil) {
  //
  // tempo has an unexpected way of handling offsets.
  case offset.to_gtempo_offset(moment.offset) {
    Error(_) -> Error(Nil)
    Ok(offset) -> {
      let gtempo_offset_as_duration =
        offset
        |> tempo_offset.to_duration

      moment.timestamp
      |> gtempo_datetime.from_timestamp
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
pub fn is_equal(a: Moment, to b: Moment) -> Bool {
  to_timestamp(a) == to_timestamp(b)
}

/// Checks if the offset portion of two Moments are equal.
pub fn offset_is_equal(a: Moment, to b: Moment) -> Bool {
  offset.is_equal(to_offset(a), to: to_offset(b))
}

/// Compares the values of only the UnixTime against each other.
pub fn compare(a: Moment, to b: Moment) -> Order {
  timestamp.compare(to_timestamp(a), to_timestamp(b))
}

/// Reverse-chronological comparison function.
pub fn compare_reverse(a: Moment, b: Moment) -> Order {
  compare(a, b)
  |> order.negate
}

/// Checks to see if one Moment occurred earlier than another.
pub fn is_earlier(a: Moment, than b: Moment) -> Bool {
  timestamp.compare(to_timestamp(a), to_timestamp(b)) == Lt
}

/// Checks to see if one Moment occurred earlier than or the
/// same time as another.
pub fn is_earlier_or_equal(a: Moment, to b: Moment) -> Bool {
  let comparison = timestamp.compare(to_timestamp(a), to_timestamp(b))

  comparison == Lt || comparison == Eq
}

/// Checks to see if one Moment occurred later than another.
pub fn is_later(a: Moment, than b: Moment) -> Bool {
  timestamp.compare(to_timestamp(a), to_timestamp(b)) == Gt
}

/// Gets the difference between the Timestamp of both Moments.
pub fn difference(a: Moment, from b: Moment) -> Duration {
  timestamp.difference(to_timestamp(a), to_timestamp(b))
}

/// Adds a Duration to the Moment, while retaining the Moment's
/// Offset.
pub fn add(moment: Moment, duration duration: Duration) -> Moment {
  let timestamp = to_timestamp(moment)

  Moment(..moment, timestamp: timestamp.add(timestamp, duration))
}

/// Subtracts a specified number of milliseconds from the Moment's
/// UNIX time.
pub fn subtract(moment: Moment, duration duration: Duration) -> Moment {
  let timestamp = to_timestamp(moment)

  Moment(..moment, timestamp: timestamp.subtract(timestamp, duration))
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
pub fn to_json(moment: Moment) -> Json {
  json.object([
    #("timestamp", moment.timestamp |> timestamp_extra.to_json),
    #("offset", moment.offset |> offset.to_json),
  ])
}

/// A version of DateTimes decoding for the application
/// as a Decoder primitive.
pub fn decoder() -> Decoder(Moment) {
  let default =
    Moment(
      // 8 March 2025
      timestamp: timestamp_extra.default(),
      offset: offset.from_minutes(0),
    )
  decode.new_primitive_decoder("DateTime", fn(datetime) {
    let offset_decoder = offset.decoder()
    let timestamp_decoder = timestamp_extra.decoder()

    let datetimestore_decoder = {
      use timestamp <- decode.field("timestamp", timestamp_decoder)
      use offset <- decode.field("offset", offset_decoder)
      decode.success(Moment(timestamp:, offset:))
    }
    case decode.run(datetime, datetimestore_decoder) {
      Error(_) -> Error(default)
      Ok(moment) -> Ok(moment)
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
