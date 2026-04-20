import gleam/json
import gleam/order.{Eq, Gt, Lt}
import gleam/time/duration
import gleeunit/should
import offset.{type Offset}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn to_from_minutes(input_and_expected_output: Int) {
  input_and_expected_output
  |> offset.from_minutes()
  |> offset.to_minutes()
  |> should.equal(input_and_expected_output)
}

pub fn to_from_minutes_1_test() {
  to_from_minutes(180)
}

pub fn to_from_minutes_2_test() {
  to_from_minutes(210)
}

pub fn to_from_minutes_3_test() {
  to_from_minutes(600)
}

pub fn to_from_minutes_4_test() {
  to_from_minutes(-720)
}

pub fn to_from_minutes_5_test() {
  to_from_minutes(-420)
}

// -------------------------------------------------------

pub fn to_duration_1_test() {
  offset.from_minutes(60)
  |> offset.to_duration
  |> should.equal(duration.minutes(60))
}

pub fn to_duration_2_test() {
  offset.from_minutes(-600)
  |> offset.to_duration
  |> should.equal(duration.minutes(-600))
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- COMPARISON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

// actually equal
pub fn is_equal_1_test() {
  offset.from_minutes(120)
  |> offset.is_equal(offset.from_minutes(120))
  |> should.equal(True)
}

// actually equal
pub fn is_equal_2_test() {
  offset.from_minutes(-60)
  |> offset.is_equal(offset.from_minutes(-60))
  |> should.equal(True)
}

// not equal
pub fn is_equal_3_test() {
  offset.from_minutes(120)
  |> offset.is_equal(offset.from_minutes(90))
  |> should.equal(False)
}

// not equal
pub fn is_equal_4_test() {
  offset.from_minutes(-720)
  |> offset.is_equal(offset.from_minutes(450))
  |> should.equal(False)
}

// -------------------------------------------------------

// Lt
pub fn compare_1_test() {
  offset.from_minutes(-210)
  |> offset.compare(offset.from_minutes(00))
  |> should.equal(Lt)
}

// Lt
pub fn compare_2_test() {
  offset.from_minutes(120)
  |> offset.compare(offset.from_minutes(510))
  |> should.equal(Lt)
}

// Eq
pub fn compare_3_test() {
  offset.from_minutes(-600)
  |> offset.compare(offset.from_minutes(-600))
  |> should.equal(Eq)
}

// Eq
pub fn compare_4_test() {
  offset.from_minutes(10)
  |> offset.compare(offset.from_minutes(10))
  |> should.equal(Eq)
}

// Gt
pub fn compare_5_test() {
  offset.from_minutes(600)
  |> offset.compare(offset.from_minutes(-120))
  |> should.equal(Gt)
}

// Gt
pub fn compare_6_test() {
  offset.from_minutes(210)
  |> offset.compare(offset.from_minutes(00))
  |> should.equal(Gt)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- JSON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn output(input: Offset, expected_output: String) {
  input
  |> offset.to_json()
  |> json.to_string()
  |> should.equal(expected_output)
}

pub fn output_input(input_and_expected_output: Offset) {
  let date_decoder = offset.decoder()

  input_and_expected_output
  |> offset.to_json()
  |> json.to_string()
  |> json.parse(using: date_decoder)
  |> should.equal(Ok(input_and_expected_output))
}

// ----------------- TESTS --------------------

pub fn example_1_input_output_test() {
  output_input(offset.from_minutes(120))
}

pub fn example_2_input_output_test() {
  output_input(offset.from_minutes(90))
}

pub fn example_3_input_output_test() {
  output_input(offset.from_minutes(-510))
}

pub fn example_1_output_test() {
  output(offset.from_minutes(-510), "-30600")
}

pub fn example_2_output_test() {
  output(offset.from_minutes(600), "36000")
}

pub fn example_3_output_test() {
  output(offset.from_minutes(0), "0")
}
