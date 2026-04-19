import gleam/time/duration.{type Duration}

const beat_millis = 86_400

pub fn beats(num: Int) -> Duration {
  duration.milliseconds(num * beat_millis)
}

// pub fn to_beats(dur: Duration) -> Float {
//   dur.millis / beat_int
// }

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const centibeat_millis = 864

pub fn centibeats(num: Int) -> Duration {
  duration.milliseconds(num * centibeat_millis)
}
// pub fn as_centibeats(dur: Duration) -> Int {
//   dur.millis / centibeat_millis
// }
