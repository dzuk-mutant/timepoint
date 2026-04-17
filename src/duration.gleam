/// An opaque type representing a duration of time.
/// 
/// The smallest possible amount of Duration is 1ms.
pub opaque type Duration {
  Duration(millis: Int)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Creates a Duration from a given number of milliseconds.
pub fn millis(num: Int) -> Duration {
  Duration(millis: num)
}

/// Provides a Duration as milliseconds.
pub fn as_millis(dur: Duration) -> Int {
  dur.millis
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// 1 second
const second_int = 1000

/// Creates a Duration from a given number of seconds.
pub fn seconds(num: Int) -> Duration {
  Duration(millis: num * second_int)
}

/// Provides a Duration as seconds.
/// Rounds the value down (towards zero).
pub fn as_seconds(dur: Duration) -> Int {
  dur.millis / second_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const minute_int = 60_000

/// Creates a Duration from a given number of seconds.
pub fn minutes(num: Int) -> Duration {
  Duration(millis: num * minute_int)
}

/// Provides a Duration as minutes.
/// Rounds the value down (towards zero).
pub fn as_minutes(dur: Duration) -> Int {
  dur.millis / minute_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const hour_int = 3_600_000

pub fn hours(num: Int) -> Duration {
  Duration(millis: num * hour_int)
}

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_hours(dur: Duration) -> Int {
  dur.millis / hour_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const day_int = 86_400_000

/// in UNIX Time (which Timepoint uses),
/// A day is always 86,400 seconds.
/// (Leap seconds are merged into other seconds, they are never counted.)
pub fn days(num: Int) -> Duration {
  Duration(millis: num * day_int)
}

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_days(dur: Duration) -> Int {
  dur.millis / day_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const beat_int = 86_400

pub fn beats(num: Int) -> Duration {
  Duration(millis: num * beat_int)
}

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_beats(dur: Duration) -> Int {
  dur.millis / beat_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const centibeat_int = 864

pub fn centibeats(num: Int) -> Duration {
  Duration(millis: num * centibeat_int)
}

/// Provides a Duration as hours.
/// Rounds the value down (towards zero).
pub fn as_centibeats(dur: Duration) -> Int {
  dur.millis / centibeat_int
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- ARITHMETIC ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn add(a: Duration, b: Duration) -> Duration {
  Duration(millis: a.millis + b.millis)
}

pub fn subtract(a: Duration, b: Duration) -> Duration {
  Duration(millis: a.millis - b.millis)
}
