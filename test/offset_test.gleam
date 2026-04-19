import gleam/int
import gleam/json
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/time/duration
import gleeunit/should
import offset.{type Offset}
import tempo
import tempo/offset as tempo_offset

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn to_from_gtempo(input_and_expected_output: Offset) {
  input_and_expected_output
  |> offset.to_gtempo_offset()
  |> result.unwrap(tempo_offset.literal("+00:00"))
  |> offset.from_gtempo_offset()
  |> should.equal(input_and_expected_output)
}

pub fn to_from_gtempo_1_test() {
  to_from_gtempo(offset.from_minutes(120))
}

pub fn to_from_gtempo_2_test() {
  to_from_gtempo(offset.from_minutes(180))
}

pub fn to_from_gtempo_3_test() {
  to_from_gtempo(offset.from_minutes(-210))
}

pub fn to_from_gtempo_4_test() {
  to_from_gtempo(offset.from_minutes(-500))
}

// -------------------------------------------------------

pub fn to_gtempo(input: Offset, expected_output: tempo.Offset) {
  input
  |> offset.to_gtempo_offset()
  |> result.unwrap(tempo_offset.literal("+00:00"))
  |> should.equal(expected_output)
}

pub fn to_gtempo_1_test() {
  to_gtempo(offset.from_minutes(60), tempo_offset.literal("+01:00"))
}

pub fn to_gtempo_2_test() {
  to_gtempo(offset.from_minutes(-720), tempo_offset.literal("-12:00"))
}

pub fn to_gtempo_3_test() {
  to_gtempo(offset.from_minutes(600), tempo_offset.literal("+10:00"))
}

// -------------------------------------------------------

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
  output(offset.from_minutes(-510), "-510")
}

pub fn example_2_output_test() {
  output(offset.from_minutes(600), "600")
}

pub fn example_3_output_test() {
  output(offset.from_minutes(0), "0")
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

fn json_i_erroneous(input: String) {
  let decoder = offset.decoder()
  input
  |> json.parse(using: decoder)
  |> result.is_error
  |> should.equal(True)
}

pub fn json_i_erroneous_1_test() {
  "1000"
  |> json_i_erroneous()
}

pub fn json_i_erroneous_2_test() {
  "-1000"
  |> json_i_erroneous()
}

pub fn json_i_erroneous_3_test() {
  "841"
  |> json_i_erroneous()
}

pub fn json_i_erroneous_4_test() {
  "-721"
  |> json_i_erroneous()
}

fn json_i_ok(input: Int) {
  let decoder = offset.decoder()
  input
  |> int.to_string
  |> json.parse(using: decoder)
  |> result.unwrap(offset.from_minutes(666_666))
  |> offset.to_minutes
  |> should.equal(input)
}

pub fn json_i_correct_1_test() {
  json_i_ok(720)
}

pub fn json_i_correct_2_test() {
  json_i_ok(840)
}

pub fn json_i_correct_3_test() {
  json_i_ok(-720)
}

pub fn json_i_correct_4_test() {
  json_i_ok(0)
}

pub fn json_i_correct_5_test() {
  json_i_ok(60)
}

pub fn json_i_correct_6_test() {
  json_i_ok(-510)
}
