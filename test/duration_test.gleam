import duration
import gleeunit/should

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ------------------ UNIT SANITY CHECK ----------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn units_1_test() {
  duration.days(1)
  |> duration.as_hours
  |> should.equal(24)
}

pub fn units_2_test() {
  duration.hours(1)
  |> duration.as_minutes
  |> should.equal(60)
}

pub fn units_3_test() {
  duration.minutes(1)
  |> duration.as_seconds
  |> should.equal(60)
}

pub fn units_4_test() {
  duration.seconds(1)
  |> duration.as_millis
  |> should.equal(1000)
}

pub fn units_5_test() {
  duration.days(1)
  |> duration.as_beats
  |> should.equal(1000)
}

pub fn units_6_test() {
  duration.beats(1)
  |> duration.as_centibeats
  |> should.equal(100)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ------------------ ARITHMETIC -----------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn units_arithmetic_1_test() {
  duration.millis(1)
  |> duration.add(duration.seconds(1))
  |> duration.as_millis
  |> should.equal(1001)
}

pub fn units_arithmetic_2_test() {
  duration.minutes(1)
  |> duration.add(duration.seconds(1))
  |> duration.as_seconds
  |> should.equal(61)
}

pub fn units_arithmetic_3_test() {
  duration.hours(1)
  |> duration.subtract(duration.minutes(1))
  |> duration.as_minutes
  |> should.equal(59)
}

pub fn units_arithmetic_4_test() {
  duration.days(1)
  |> duration.subtract(duration.hours(5))
  |> duration.as_hours
  |> should.equal(19)
}
