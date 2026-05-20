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

const minute_as_seconds = 60

/// Provides a Duration as minutes.
/// Rounds the value down (towards zero).
pub fn as_minutes(duration: Duration) -> Int {
  to_seconds_int(duration) / minute_as_seconds
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const hour_as_seconds = 3600

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_hours(duration: Duration) -> Int {
  to_seconds_int(duration) / hour_as_seconds
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const day_as_seconds = 86_400

pub fn days(int: Int) -> Duration {
  duration.seconds(int * day_as_seconds)
}

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_days(duration: Duration) -> Int {
  to_seconds_int(duration) / day_as_seconds
}
