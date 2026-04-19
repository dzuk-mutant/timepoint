import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/order.{Eq, Gt, Lt}
import gleam/time/timestamp.{type Timestamp}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- COMPARISON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Convenience function that checks to see if two Timestamps
/// are the same.
pub fn is_equal(a: Timestamp, to b: Timestamp) -> Bool {
  a == b
}

/// Convenience function that checks to see if one Timestamp
/// is earlier than another.
pub fn is_earlier(a: Timestamp, than b: Timestamp) -> Bool {
  timestamp.compare(a, b) == Lt
}

/// Convenience function that checks to see if one Timestamp
/// is earlier than or equal to another.
pub fn is_earlier_or_equal(a: Timestamp, to b: Timestamp) -> Bool {
  let comparison = timestamp.compare(a, b)
  comparison == Lt || comparison == Eq
}

/// Convenience function that checks to see if one Timestamp
/// is later than another.
pub fn is_later(a: Timestamp, than b: Timestamp) -> Bool {
  timestamp.compare(a, b) == Gt
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ----------------------- JSON ------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn default() -> Timestamp {
  timestamp.from_unix_seconds(0)
}

/// Converts a Timestamp into a JSON object.
pub fn to_json(ts: Timestamp) -> Json {
  let units = timestamp.to_unix_seconds_and_nanoseconds(ts)

  json.object([
    #("unix_s", units.0 |> json.int),
    #("unix_ns", units.1 |> json.int),
  ])
}

/// Decodes a Timestamp from a JSON object.
pub fn decoder() -> Decoder(Timestamp) {
  decode.new_primitive_decoder("Timestamp", fn(timestamp) {
    let timestamp_decoder = {
      use seconds <- decode.field("unix_s", decode.int)
      use nanoseconds <- decode.field("unix_ns", decode.int)

      decode.success(timestamp.from_unix_seconds_and_nanoseconds(
        seconds:,
        nanoseconds:,
      ))
    }
    case decode.run(timestamp, timestamp_decoder) {
      Error(_) -> Error(default())
      Ok(moment) -> Ok(moment)
    }
  })
}
