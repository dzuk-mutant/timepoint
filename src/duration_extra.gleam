import gleam/float
import gleam/time/duration.{type Duration}

pub fn to_seconds_int(duration: Duration) -> Int {
  let units = duration.to_seconds_and_nanoseconds(duration)
  units.0
}

/// Provides a Duration as seconds.
/// Rounds the value down (towards zero).
pub fn as_seconds(duration: Duration) -> Int {
  to_seconds_int(duration)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const minute_int = 60

/// Provides a Duration as minutes.
/// Rounds the value down (towards zero).
pub fn as_minutes(duration: Duration) -> Int {
  to_seconds_int(duration) / minute_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const hour_int = 3600

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_hours(duration: Duration) -> Int {
  to_seconds_int(duration) / hour_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const day_int = 86_400

pub fn days(int: Int) -> Duration {
  duration.seconds(int * day_int)
}

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_days(duration: Duration) -> Int {
  to_seconds_int(duration) / day_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const beat_int = 864

pub fn beats(int: Int) -> Duration {
  duration.seconds(int * beat_int)
}

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_beats(duration: Duration) -> Int {
  to_seconds_int(duration) / beat_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const centibeat_int: Float = 8.64

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_centibeats(duration: Duration) -> Int {
  duration.to_seconds(duration) /. centibeat_int
  |> float.truncate
}
