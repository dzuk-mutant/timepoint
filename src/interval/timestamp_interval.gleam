import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/order.{Eq, Gt, Lt}
import gleam/time/timestamp.{type Timestamp}
import timestamp_extra

/// Represents a range of time for comparison.
/// 
/// Collision in a TimestampInterval is inclusive at the start
/// point (Eq/Gt) and exclusive at the end (Lt).
/// 
/// TimestampIntervals can only be compared to Timestamps.
/// 
/// If you want to compare with Days and DayIntervals, you need
/// a MomentWindow.
pub opaque type TimestampInterval {
  TimestampInterval(start: Timestamp, end_excluding: Timestamp)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- CONSTRUCTOR ------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

pub fn new(
  start start: Timestamp,
  end_excluding end_excluding: Timestamp,
) -> TimestampInterval {
  TimestampInterval(start:, end_excluding:)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- CONVERSIONS ------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

pub fn to_end_excluding(interval: TimestampInterval) -> Timestamp {
  interval.end_excluding
}

pub fn to_start(interval: TimestampInterval) -> Timestamp {
  interval.start
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

/// Converts a TimestampInterval into a JSON String.
pub fn to_json(interval: TimestampInterval) -> Json {
  json.object([
    #("start", timestamp_extra.to_json(interval.start)),
    #("end_excluding", timestamp_extra.to_json(interval.end_excluding)),
  ])
}

/// Attempts to decode a Timestamp from JSON.
/// 
/// If it's malformed, or formed but the end is
/// before the start, it will throw an Error.
pub fn decoder() -> Decoder(TimestampInterval) {
  let default =
    TimestampInterval(
      start: timestamp.from_unix_seconds(0),
      end_excluding: timestamp.from_unix_seconds(1),
    )

  decode.new_primitive_decoder("TimestampInterval", fn(interval) {
    let timestamp_decoder = timestamp_extra.decoder()

    let interval_decoder = {
      use start <- decode.field("start", timestamp_decoder)
      use end_excluding <- decode.field("end_excluding", timestamp_decoder)

      decode.success(#(start, end_excluding))
    }

    case decode.run(interval, interval_decoder) {
      Error(_) -> Error(default)
      Ok(raw_interval) ->
        case timestamp_extra.is_earlier(raw_interval.1, than: raw_interval.0) {
          True -> Error(default)
          False -> Ok(new(raw_interval.0, raw_interval.1))
        }
    }
  })
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ----------------- COLLISION -------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

pub type TimestampCollision {
  TimestampBeforeStart
  TimestampAtStart
  TimestampInside
  TimestampAtEnd
  TimestampAfterEnd
}

/// Returns a PointCollision type specifically describing
/// where a Timestamp is in relation to a TimestampInterval.
pub fn to_collision_with_timestamp(
  interval: TimestampInterval,
  timestamp: Timestamp,
) -> TimestampCollision {
  case timestamp.compare(timestamp, interval.start) {
    Lt -> TimestampBeforeStart
    Eq -> TimestampAtStart
    Gt ->
      case timestamp.compare(timestamp, interval.end_excluding) {
        Lt -> TimestampInside
        Eq -> TimestampAtEnd
        Gt -> TimestampAfterEnd
      }
  }
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- EDIT ----------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// Type encapsulating the different types of errors
/// that can be detected by the truncate function.
pub type TruncateError {
  ResultIntervalIsZero
  ResultIntervalIsLarger
}

/// Attempts to move the end_excluding 
/// Timestamp to the same point as a given Momeent
/// 
/// Also used to check if a truncation is applicable
/// when it comes to overlap checks.
/// 
/// ```
/// will provide a result,
/// even if the result is the same:
/// 
///    s--------e      s-------e
///    s---T           s-------T
/// 
/// ResultIntervalIsZero:
/// 
///   s--------e       s-------e
///   T              T
/// 
/// ResultIntervalIsLarger:
///  e--------e
///  s-----------T 
/// 
/// ```
///
pub fn truncate(
  interval: TimestampInterval,
  behind truncating_timestamp: Timestamp,
) -> Result(TimestampInterval, TruncateError) {
  case to_collision_with_timestamp(interval, truncating_timestamp) {
    TimestampBeforeStart | TimestampAtStart -> Error(ResultIntervalIsZero)
    TimestampAfterEnd -> Error(ResultIntervalIsLarger)
    _ -> Ok(TimestampInterval(..interval, end_excluding: truncating_timestamp))
  }
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- QUERY ---------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// Checks if a Timestamp lands inside a TimestampInterval.
/// 
/// correct:
/// 
/// |-------|    |-----|   
///    m         m    
/// 
/// ```
/// 
pub fn is_around_timestamp(
  interval: TimestampInterval,
  timestamp: Timestamp,
) -> Bool {
  case to_collision_with_timestamp(interval, timestamp) {
    TimestampAtStart | TimestampInside -> True
    _ -> False
  }
}

/// Checks if a Timestamp lands before a TimestampInterval.
/// 
/// correct:
/// 
///       |-------|     
///    m         
/// 
/// ```
/// 
pub fn is_after_timestamp(
  interval: TimestampInterval,
  timestamp: Timestamp,
) -> Bool {
  case to_collision_with_timestamp(interval, timestamp) {
    TimestampBeforeStart -> True
    _ -> False
  }
}

/// Checks if a TimestampInterval is fully inside another TimestampInterval.
/// 
/// ```
/// 
/// correct:
/// 
///     a-----a      a----a       a----a
///    b-------b     b-----b    b------b
/// 
/// ```
pub fn is_inside(a: TimestampInterval, of b: TimestampInterval) {
  case to_collision_with_timestamp(b, a.start) {
    TimestampAtStart | TimestampInside -> True
    _ -> False
  }
  && case to_collision_with_timestamp(b, a.end_excluding) {
    TimestampInside | TimestampAtEnd -> True
    _ -> False
  }
}

/// Checks if a TimestampInterval is at least partly overlapping another TimestampInterval.
/// 
/// ```
/// correct:
/// 
///     a-----a      a----a       a----a
///    b-------b     b-----b    b------b
/// 
/// 
///   a-----a          a------a 
///     b------b     b-----b     
/// 
/// 
/// 
/// ```
/// 
pub fn is_overlapped(a: TimestampInterval, by b: TimestampInterval) {
  case to_collision_with_timestamp(b, a.start) {
    TimestampBeforeStart | TimestampAtStart | TimestampInside -> True
    _ -> False
  }
  && case to_collision_with_timestamp(b, a.end_excluding) {
    TimestampInside | TimestampAtEnd | TimestampAfterEnd -> True
    _ -> False
  }
}

/// Checks if two TimestampIntervals are considered 'contiguous'.
/// 
/// ```
/// correct:
/// 
/// 1----1
///      2----2
/// 
/// ```
/// 
pub fn is_contiguous(
  prev: TimestampInterval,
  ahead_of next: TimestampInterval,
) -> Bool {
  prev.end_excluding == next.start
}
