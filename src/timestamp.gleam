import gleam/time
import tempo.{type Offset}
import timepoint.{type Timestamp, TimestampWithOffset}

/// Adds an offset, turning it into a TimestampWithOffset.
pub fn add_offset(timestamp: Timestamp, offset: Offset) -> TimestampWithOffset {
  timepoint.timestamp_add_offset(timestamp, offset)
}

/// Converts a Timestamp to a SolarDay.
/// 
/// This is a lossy conversion - you can't get a
/// Timestamp back from a SolarDay.
pub fn to_solar_day(timestamp: Timestamp) {
  todo
}
