import duration_extra
import gleam/time/duration
import gleeunit/should

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ------------------ UNIT SANITY CHECK ----------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn units_1_test() {
  duration_extra.days(1)
  |> duration_extra.as_hours
  |> should.equal(24)
}

pub fn units_2_test() {
  duration.hours(1)
  |> duration_extra.as_minutes
  |> should.equal(60)
}

pub fn units_3_test() {
  duration.minutes(1)
  |> duration_extra.as_seconds
  |> should.equal(60)
}

pub fn units_5_test() {
  duration_extra.days(1)
  |> duration_extra.as_beats
  |> should.equal(1000)
}

pub fn units_6_test() {
  duration_extra.beats(1)
  |> duration_extra.as_centibeats
  |> should.equal(100)
}
