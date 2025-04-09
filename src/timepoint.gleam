import gleam/io
import gleam/time
import tempo.{type Offset}

pub fn main() {
  io.println("Hello from timepoint!")
}

/// An absolute, abstract representation of a point in time,
/// recorded in wall clock time, not monotonic time.
pub type Timestamp =
  time.Timestamp

@internal
pub fn timestamp_add_offset(timestamp: Timestamp, offset: Offset) -> Timestamp {
  TimestampWithOffset(timestamp:, offset:)
}

// --------------------------------------------------------------
// --------------------------------------------------------------
// --------------------------------------------------------------
// --------------------------------------------------------------
// --------------------------------------------------------------

/// An absolute Timestamp (gleam_time Timestamp) combined with an
/// offset (from gtempo).
/// 
/// This is the most concise representation of a user's local time.
/// With this time you can derive things like local Gregorian DateTimes.
pub opaque type TimestampWithOffset {
  TimestampWithOffset(timestamp: Timestamp, offset: Offset)
}

@internal
pub fn timestamp_remove_offset(two: TimestampWithOffset) -> Timestamp {
  two.timestamp
}

// --------------------------------------------------------------
// --------------------------------------------------------------
// --------------------------------------------------------------
// --------------------------------------------------------------
// --------------------------------------------------------------

/// A representation of one calendar day on Earth. This is relative
/// to a person's experience of a day, not just what part of the world
/// they live in or what time zone they're in, but whether they were
/// travelling at the time - thus possibly making their experience
/// of a solar day longer or shorter.
/// 
/// This type is agnostic to what calendar that actually is.
pub opaque type SolarDay {
  SolarDay(inner: Int)
}
