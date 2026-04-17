import duration
import gleam/json
import gleam/order.{Eq, Gt, Lt}
import gleeunit/should
import tempo.{type DateTime}
import tempo/datetime as gtempo_datetime
import unix_time.{type UnixTime}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn to_from_gtempo(input_and_expected_output: UnixTime) {
  input_and_expected_output
  |> unix_time.to_gtempo_datetime_at_utc()
  |> unix_time.from_gtempo_datetime()
  |> should.equal(input_and_expected_output)
}

pub fn to_from_gtempo_1_test() {
  to_from_gtempo(unix_time.from_int(127))
}

pub fn to_from_gtempo_2_test() {
  to_from_gtempo(unix_time.from_int(712_399))
}

pub fn to_from_gtempo_3_test() {
  to_from_gtempo(unix_time.from_int(813_479_756_000))
}

pub fn to_from_gtempo_4_test() {
  to_from_gtempo(unix_time.from_int(1_741_392_000_000))
}

// -------------------------------------------------------

pub fn to_gtempo(input: UnixTime, expected_output: DateTime) {
  input
  |> unix_time.to_gtempo_datetime_at_utc()
  |> should.equal(expected_output)
}

pub fn to_gtempo_1_test() {
  to_gtempo(
    unix_time.from_int(1_741_392_000_000),
    gtempo_datetime.literal("2025-03-08T00:00:00.000Z"),
  )
}

pub fn to_gtempo_2_test() {
  to_gtempo(
    unix_time.from_int(813_479_756_000),
    gtempo_datetime.literal("1995-10-12T06:35:56.000Z"),
  )
}

// just out.
pub fn to_gtempo_3_test() {
  unix_time.from_gtempo_datetime_literal("2010-03-06T23:00:00.000+01:00")
  |> should.equal(unix_time.from_int(1_267_912_800_000))
}

// back and forth - the same time, but the offset context is gone.
pub fn to_gtempo_4_test() {
  unix_time.from_gtempo_datetime_literal("2010-03-06T23:00:00.000+01:00")
  |> unix_time.to_gtempo_datetime_at_utc()
  |> should.equal(gtempo_datetime.literal("2010-03-06T22:00:00.000+00:00"))
}

// -------------------------------------------------------

pub fn to_from_unix_milli(input_and_expected_output: Int) {
  input_and_expected_output
  |> unix_time.from_int()
  |> unix_time.to_int()
  |> should.equal(input_and_expected_output)
}

pub fn to_from_unix_milli_1_test() {
  to_from_unix_milli(0000)
}

pub fn to_from_unix_milli_2_test() {
  to_from_unix_milli(887_777)
}

pub fn to_from_unix_milli_3_test() {
  to_from_unix_milli(666_666)
}

pub fn to_from_unix_milli_4_test() {
  to_from_unix_milli(24_612)
}

pub fn to_from_unix_milli_5_test() {
  to_from_unix_milli(736_452)
}

// -------------------------------------------------------

pub fn to_duration_1_test() {
  unix_time.from_int(1)
  |> unix_time.to_duration_from_epoch
  |> duration.as_millis
  |> should.equal(1)
}

pub fn to_duration_2_test() {
  unix_time.from_int(1_267_912_800_000)
  |> unix_time.to_duration_from_epoch
  |> duration.as_millis
  |> should.equal(1_267_912_800_000)
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
  unix_time.from_int(012_498)
  |> unix_time.is_equal(unix_time.from_int(012_498))
  |> should.equal(True)
}

// actually equal
pub fn is_equal_2_test() {
  unix_time.from_int(812_729)
  |> unix_time.is_equal(unix_time.from_int(812_729))
  |> should.equal(True)
}

// not equal
pub fn is_equal_3_test() {
  unix_time.from_int(012_498)
  |> unix_time.is_equal(unix_time.from_int(987))
  |> should.equal(False)
}

// not equal
pub fn is_equal_4_test() {
  unix_time.from_int(111_111)
  |> unix_time.is_equal(unix_time.from_int(565_322))
  |> should.equal(False)
}

// -------------------------------------------------------

// Lt
pub fn compare_1_test() {
  unix_time.from_int(123_123)
  |> unix_time.compare(unix_time.from_int(565_322))
  |> should.equal(Lt)
}

// Lt
pub fn compare_2_test() {
  unix_time.from_int(0)
  |> unix_time.compare(unix_time.from_int(123))
  |> should.equal(Lt)
}

// Eq
pub fn compare_3_test() {
  unix_time.from_int(342_334)
  |> unix_time.compare(unix_time.from_int(342_334))
  |> should.equal(Eq)
}

// Eq
pub fn compare_4_test() {
  unix_time.from_int(9899)
  |> unix_time.compare(unix_time.from_int(9899))
  |> should.equal(Eq)
}

// Gt
pub fn compare_5_test() {
  unix_time.from_int(124)
  |> unix_time.compare(unix_time.from_int(123))
  |> should.equal(Gt)
}

// Gt
pub fn compare_6_test() {
  unix_time.from_int(987_767)
  |> unix_time.compare(unix_time.from_int(7656))
  |> should.equal(Gt)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn is_earlier_1_test() {
  unix_time.from_int(123_123)
  |> unix_time.is_earlier(than: unix_time.from_int(123_124))
  |> should.equal(True)
}

pub fn is_earlier_2_test() {
  unix_time.from_int(123_123)
  |> unix_time.is_earlier(than: unix_time.from_int(123_123))
  |> should.equal(False)
}

pub fn is_earlier_3_test() {
  unix_time.from_int(99_999_999)
  |> unix_time.is_earlier(than: unix_time.from_int(123_124))
  |> should.equal(False)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn is_later_1_test() {
  unix_time.from_int(123_123)
  |> unix_time.is_later(than: unix_time.from_int(123_124))
  |> should.equal(False)
}

pub fn is_later_2_test() {
  unix_time.from_int(123_123)
  |> unix_time.is_later(than: unix_time.from_int(123_123))
  |> should.equal(False)
}

pub fn is_later_3_test() {
  unix_time.from_int(99_999_999)
  |> unix_time.is_later(than: unix_time.from_int(123_124))
  |> should.equal(True)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn difference_1_test() {
  unix_time.from_int(123_123)
  |> unix_time.difference(from: unix_time.from_int(123_124))
  |> should.equal(1)
}

pub fn difference_2_test() {
  unix_time.from_int(123_123)
  |> unix_time.difference(from: unix_time.from_int(123_123))
  |> should.equal(0)
}

pub fn difference_3_test() {
  unix_time.from_int(0)
  |> unix_time.difference(from: unix_time.from_int(123_123))
  |> should.equal(123_123)
}

pub fn difference_4_test() {
  unix_time.from_int(600_000)
  |> unix_time.difference(from: unix_time.from_int(500_000))
  |> should.equal(-100_000)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn add_1_test() {
  unix_time.from_int(123_123)
  |> unix_time.add(milli: 1)
  |> should.equal(unix_time.from_int(123_124))
}

pub fn add_2_test() {
  unix_time.from_int(123_123)
  |> unix_time.add(milli: 0)
  |> should.equal(unix_time.from_int(123_123))
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- JSON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn output(input: UnixTime, expected_output: String) {
  input
  |> unix_time.to_json()
  |> json.to_string()
  |> should.equal(expected_output)
}

pub fn output_input(input_and_expected_output: UnixTime) {
  let date_decoder = unix_time.decoder()

  input_and_expected_output
  |> unix_time.to_json()
  |> json.to_string()
  |> json.parse(using: date_decoder)
  |> should.equal(Ok(input_and_expected_output))
}

// ----------------- TESTS --------------------

pub fn example_1_input_output_test() {
  output_input(unix_time.from_int(739_318))
}

pub fn example_2_input_output_test() {
  output_input(unix_time.from_int(728_578))
}

pub fn example_3_input_output_test() {
  output_input(unix_time.from_int(1_267_912_800_000))
}

pub fn example_1_output_test() {
  output(unix_time.from_int(1_741_392_000_000), "1741392000000")
}

pub fn example_2_output_test() {
  output(unix_time.from_int(813_479_756_000), "813479756000")
}

pub fn example_3_output_test() {
  output(unix_time.from_int(1_267_912_800_000), "1267912800000")
}
