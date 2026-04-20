import gleam/json
import gleam/order.{Eq, Gt, Lt}
import gleam/time/duration
import gleam/time/timestamp
import gleeunit/should
import moment.{type Moment}
import offset

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn to_offset_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(12_498),
    with: offset.from_minutes(0),
  )
  |> moment.to_offset()
  |> should.equal(offset.from_minutes(0))
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
  moment.from_timestamp(
    timestamp.from_unix_seconds(12_498),
    with: offset.from_minutes(0),
  )
  |> moment.is_equal(moment.from_timestamp(
    timestamp.from_unix_seconds(12_498),
    with: offset.from_minutes(0),
  ))
  |> should.equal(True)
}

// actually equal
pub fn is_equal_2_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(23_428_301),
    with: offset.from_minutes(0),
  )
  |> moment.is_equal(moment.from_timestamp(
    timestamp.from_unix_seconds(23_428_301),
    with: offset.from_minutes(0),
  ))
  |> should.equal(True)
}

// not equal
pub fn is_equal_3_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(23_428_301),
    with: offset.from_minutes(0),
  )
  |> moment.is_equal(moment.from_timestamp(
    timestamp.from_unix_seconds(23_428_302),
    with: offset.from_minutes(0),
  ))
  |> should.equal(False)
}

// not equal
pub fn is_equal_4_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(11_111_111),
    with: offset.from_minutes(0),
  )
  |> moment.is_equal(moment.from_timestamp(
    timestamp.from_unix_seconds(23_428_302),
    with: offset.from_minutes(0),
  ))
  |> should.equal(False)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

// Lt
pub fn compare_1_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(111_111),
    with: offset.from_minutes(0),
  )
  |> moment.compare(moment.from_timestamp(
    timestamp.from_unix_seconds(123_123),
    with: offset.from_minutes(0),
  ))
  |> should.equal(Lt)
}

// Lt
pub fn compare_2_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(0),
    with: offset.from_minutes(0),
  )
  |> moment.compare(moment.from_timestamp(
    timestamp.from_unix_seconds(123_123),
    with: offset.from_minutes(0),
  ))
  |> should.equal(Lt)
}

// Eq
pub fn compare_3_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(8_986_543),
    with: offset.from_minutes(0),
  )
  |> moment.compare(moment.from_timestamp(
    timestamp.from_unix_seconds(8_986_543),
    with: offset.from_minutes(0),
  ))
  |> should.equal(Eq)
}

// Eq, even with different offsets
pub fn compare_4_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(8_888_888),
    with: offset.from_minutes(0),
  )
  |> moment.compare(moment.from_timestamp(
    timestamp.from_unix_seconds(8_888_888),
    with: offset.from_minutes(120),
  ))
  |> should.equal(Eq)
}

// Gt
pub fn compare_5_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  )
  |> moment.compare(moment.from_timestamp(
    timestamp.from_unix_seconds(123),
    with: offset.from_minutes(0),
  ))
  |> should.equal(Gt)
}

// Gt
pub fn compare_6_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(3_242_349_809),
    with: offset.from_minutes(0),
  )
  |> moment.compare(moment.from_timestamp(
    timestamp.from_unix_seconds(98_989_989),
    with: offset.from_minutes(0),
  ))
  |> should.equal(Gt)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

// Lt
pub fn compare_reverse_1_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(111_111),
    with: offset.from_minutes(0),
  )
  |> moment.compare_reverse(
    timestamp.from_unix_seconds(123_123)
    |> moment.from_timestamp(with: offset.from_minutes(0)),
  )
  |> should.equal(Gt)
}

// Lt
pub fn compare_reverse_2_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(0),
    with: offset.from_minutes(0),
  )
  |> moment.compare_reverse(
    timestamp.from_unix_seconds(123_123)
    |> moment.from_timestamp(with: offset.from_minutes(0)),
  )
  |> should.equal(Gt)
}

// Eq
pub fn compare_reverse_3_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(8_986_543),
    with: offset.from_minutes(0),
  )
  |> moment.compare_reverse(
    timestamp.from_unix_seconds(8_986_543)
    |> moment.from_timestamp(with: offset.from_minutes(0)),
  )
  |> should.equal(Eq)
}

// Eq, even with different offsets
pub fn compare_reverse_4_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(8_888_888),
    with: offset.from_minutes(0),
  )
  |> moment.compare_reverse(
    timestamp.from_unix_seconds(8_888_888)
    |> moment.from_timestamp(with: offset.from_minutes(120)),
  )
  |> should.equal(Eq)
}

// Gt
pub fn compare_reverse_5_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  )
  |> moment.compare_reverse(moment.from_timestamp(
    timestamp.from_unix_seconds(123),
    with: offset.from_minutes(0),
  ))
  |> should.equal(Lt)
}

// Gt
pub fn compare_reverse_6_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(3_242_349_809),
    with: offset.from_minutes(0),
  )
  |> moment.compare_reverse(
    timestamp.from_unix_seconds(98_989_989)
    |> moment.from_timestamp(with: offset.from_minutes(0)),
  )
  |> should.equal(Lt)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

/// even with the offset, the same time is the same time.
pub fn is_earlier_1_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(123),
    with: offset.from_minutes(0),
  )
  |> moment.is_earlier(
    than: timestamp.from_unix_seconds(124)
    |> moment.from_timestamp(with: offset.from_minutes(600)),
  )
  |> should.equal(True)
}

pub fn is_earlier_2_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(123),
    with: offset.from_minutes(0),
  )
  |> moment.is_earlier(than: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(True)
}

pub fn is_earlier_3_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(123),
    with: offset.from_minutes(0),
  )
  |> moment.is_earlier(than: moment.from_timestamp(
    timestamp.from_unix_seconds(123),
    with: offset.from_minutes(0),
  ))
  |> should.equal(False)
}

pub fn is_earlier_4_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(125),
    with: offset.from_minutes(0),
  )
  |> moment.is_earlier(than: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(False)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn is_later_1_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(123),
    with: offset.from_minutes(0),
  )
  |> moment.is_later(than: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(False)
}

pub fn is_later_2_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  )
  |> moment.is_later(than: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(False)
}

pub fn is_later_3_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(125),
    with: offset.from_minutes(0),
  )
  |> moment.is_later(than: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(True)
}

/// different offset test
/// 
/// (offsets should not affect the calculation)
pub fn is_later_4_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(125),
    with: offset.from_minutes(-120),
  )
  |> moment.is_later(than: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(True)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn difference_1_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(123),
    with: offset.from_minutes(0),
  )
  |> moment.difference(from: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(duration.seconds(1))
}

pub fn difference_2_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  )
  |> moment.difference(from: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(duration.seconds(0))
}

pub fn difference_3_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(0),
    with: offset.from_minutes(0),
  )
  |> moment.difference(from: moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
  |> should.equal(duration.seconds(124))
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn add_1_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  )
  |> moment.add(duration.seconds(1))
  |> should.equal(moment.from_timestamp(
    timestamp.from_unix_seconds(125),
    with: offset.from_minutes(0),
  ))
}

pub fn add_2_test() {
  moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  )
  |> moment.add(duration.seconds(0))
  |> should.equal(moment.from_timestamp(
    timestamp.from_unix_seconds(124),
    with: offset.from_minutes(0),
  ))
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- JSON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn output(input: Moment, expected_output: String) {
  input
  |> moment.to_json()
  |> json.to_string()
  |> should.equal(expected_output)
}

pub fn output_input(input_and_expected_output: Moment) {
  let date_decoder = moment.decoder()

  input_and_expected_output
  |> moment.to_json()
  |> json.to_string()
  |> json.parse(using: date_decoder)
  |> should.equal(Ok(input_and_expected_output))
}

// ----------------- TESTS --------------------

pub fn example_1_input_output_test() {
  output_input(moment.from_timestamp(
    timestamp.from_unix_seconds(8_888_888),
    with: offset.from_minutes(0),
  ))
}

pub fn example_2_input_output_test() {
  output_input(
    timestamp.from_unix_seconds(3_242_342_358)
    |> moment.from_timestamp(with: offset.from_minutes(210)),
  )
}

pub fn example_3_input_output_test() {
  output_input(moment.from_timestamp(
    timestamp.from_unix_seconds(21_312_312_312),
    with: offset.from_minutes(-600),
  ))
}

pub fn example_1_output_test() {
  output(
    moment.from_timestamp(
      timestamp.from_unix_seconds(1_741_392_000),
      with: offset.from_minutes(0),
    ),
    "{\"timestamp\":{\"unix_s\":1741392000,\"unix_ns\":0},\"offset\":0}",
  )
}

pub fn example_2_output_test() {
  output(
    moment.from_timestamp(
      timestamp.from_unix_seconds(813_479_756),
      with: offset.from_minutes(-240),
    ),
    "{\"timestamp\":{\"unix_s\":813479756,\"unix_ns\":0},\"offset\":-14400}",
  )
}

pub fn example_3_output_test() {
  output(
    moment.from_timestamp(
      timestamp.from_unix_seconds(1_267_912_800),
      with: offset.from_minutes(640),
    ),
    "{\"timestamp\":{\"unix_s\":1267912800,\"unix_ns\":0},\"offset\":38400}",
  )
}
