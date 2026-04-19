import day.{type Day}
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/order.{Eq, Gt, Lt}
import gleeunit/should
import moment
import tempo.{type Date}
import tempo/date as gtempo_date

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------ to/from_gtempo -------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

pub fn to_from_gtempo(input_and_expected_output: Day) {
  input_and_expected_output
  |> day.to_gtempo_date()
  |> day.from_gtempo_date()
  |> should.equal(input_and_expected_output)
}

pub fn to_from_gtempo_1_test() {
  to_from_gtempo(day.from_unix_days(127))
}

pub fn to_from_gtempo_2_test() {
  to_from_gtempo(day.from_unix_days(712_399))
}

pub fn to_from_gtempo_3_test() {
  to_from_gtempo(day.from_unix_days(128_745))
}

pub fn to_from_gtempo_4_test() {
  to_from_gtempo(day.from_unix_days(500_000))
}

// -------------------------------------------------------

pub fn to_gtempo(input: Day, expected_output: Date) {
  input
  |> day.to_gtempo_date()
  |> should.equal(expected_output)
}

pub fn to_gtempo_1_test() {
  to_gtempo(day.from_rata_die(739_318), gtempo_date.literal("2025-03-08"))
}

pub fn to_gtempo_2_test() {
  to_gtempo(day.from_rata_die(728_578), gtempo_date.literal("1995-10-12"))
}

pub fn to_gtempo_3_test() {
  to_gtempo(day.from_rata_die(733_837), gtempo_date.literal("2010-03-06"))
}

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------ to/from_rata_die ------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

fn to_from_rata_die(input_and_expected_output: Int) {
  input_and_expected_output
  |> day.from_rata_die()
  |> day.to_rata_die()
  |> should.equal(input_and_expected_output)
}

pub fn to_from_rata_die_1_test() {
  to_from_rata_die(0000)
}

pub fn to_from_rata_die_2_test() {
  to_from_rata_die(887_777)
}

pub fn to_from_rata_die_3_test() {
  to_from_rata_die(666_666)
}

pub fn to_from_rata_die_4_test() {
  to_from_rata_die(24_612)
}

pub fn to_from_rata_die_5_test() {
  to_from_rata_die(736_452)
}

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------ to/from_unix_days -----------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

fn to_from_unix_days(input_and_expected_output: Int) {
  input_and_expected_output
  |> day.from_unix_days()
  |> day.to_unix_days()
  |> should.equal(input_and_expected_output)
}

pub fn to_from_unix_days_1_test() {
  to_from_unix_days(0000)
}

pub fn to_from_unix_days_2_test() {
  to_from_unix_days(8877)
}

pub fn to_from_unix_days_3_test() {
  to_from_unix_days(66_666)
}

pub fn to_from_unix_days_4_test() {
  to_from_unix_days(2462)
}

pub fn to_from_unix_days_5_test() {
  to_from_unix_days(736_452)
}

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------ epoch sanity checking -------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

pub fn epoch_sanity_check_1_test() {
  day.from_unix_days(0)
  |> day.to_string
  |> should.equal("1970-01-01")
}

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------- from_moment ----------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

// -------------------------------------------------------

fn from_moment(input input: String, output output: String) {
  input
  |> moment.from_gtempo_literal
  |> day.from_moment
  |> day.to_string
  |> should.equal(output)
}

pub fn from_moment_1_test() {
  from_moment(input: "2025-03-08T00:00:00.000Z", output: "2025-03-08")
}

pub fn from_moment_2_test() {
  from_moment(input: "2025-03-08T23:59:59.999Z", output: "2025-03-08")
}

pub fn from_moment_3_test() {
  from_moment(input: "2025-03-08T23:59:59.999+12:00", output: "2025-03-08")
}

pub fn from_moment_4_test() {
  from_moment(input: "2025-03-08T12:00:00.000+12:00", output: "2025-03-08")
}

pub fn from_moment_5_test() {
  from_moment(input: "1992-09-11T00:00:00.000+12:00", output: "1992-09-11")
}

pub fn from_moment_6_test() {
  from_moment(input: "1992-09-11T00:00:00.000-05:30", output: "1992-09-11")
}

pub fn from_moment_7_test() {
  from_moment(input: "1992-09-11T00:00:00.000-11:30", output: "1992-09-11")
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
  day.from_unix_days(012_498)
  |> day.is_equal(day.from_unix_days(012_498))
  |> should.equal(True)
}

// actually equal
pub fn is_equal_2_test() {
  day.from_unix_days(812_729)
  |> day.is_equal(day.from_unix_days(812_729))
  |> should.equal(True)
}

// not equal
pub fn is_equal_3_test() {
  day.from_unix_days(012_498)
  |> day.is_equal(day.from_unix_days(987))
  |> should.equal(False)
}

// not equal
pub fn is_equal_4_test() {
  day.from_unix_days(111_111)
  |> day.is_equal(day.from_unix_days(565_322))
  |> should.equal(False)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

// Lt
pub fn compare_1_test() {
  day.from_unix_days(123_123)
  |> day.compare(day.from_unix_days(565_322))
  |> should.equal(Lt)
}

// Lt
pub fn compare_2_test() {
  day.from_unix_days(0)
  |> day.compare(day.from_unix_days(123))
  |> should.equal(Lt)
}

// Eq
pub fn compare_3_test() {
  day.from_unix_days(342_334)
  |> day.compare(day.from_unix_days(342_334))
  |> should.equal(Eq)
}

// Eq
pub fn compare_4_test() {
  day.from_unix_days(9899)
  |> day.compare(day.from_unix_days(9899))
  |> should.equal(Eq)
}

// Gt
pub fn compare_5_test() {
  day.from_unix_days(124)
  |> day.compare(day.from_unix_days(123))
  |> should.equal(Gt)
}

// Gt
pub fn compare_6_test() {
  day.from_unix_days(987_767)
  |> day.compare(day.from_unix_days(7656))
  |> should.equal(Gt)
}

// ----------------------------------------------------
// -------------------- compare_reverse -----------------
// ----------------------------------------------------

pub fn order_reverse_1_test() {
  day.compare_reverse(
    day.from_gtempo_literal("2034-06-08"),
    day.from_gtempo_literal("2034-07-07"),
  )
  |> should.equal(order.Gt)
}

pub fn order_reverse_2_test() {
  day.compare_reverse(
    day.from_gtempo_literal("2025-03-04"),
    day.from_gtempo_literal("2022-01-01"),
  )
  |> should.equal(order.Lt)
}

pub fn order_reverse_3_test() {
  day.compare_reverse(
    day.from_gtempo_literal("2034-06-08"),
    day.from_gtempo_literal("2034-06-08"),
  )
  |> should.equal(order.Eq)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn is_earlier_1_test() {
  day.from_unix_days(123_123)
  |> day.is_earlier(than: day.from_unix_days(123_124))
  |> should.equal(True)
}

pub fn is_earlier_2_test() {
  day.from_unix_days(123_123)
  |> day.is_earlier(than: day.from_unix_days(123_123))
  |> should.equal(False)
}

pub fn is_earlier_3_test() {
  day.from_unix_days(99_999_999)
  |> day.is_earlier(than: day.from_unix_days(123_124))
  |> should.equal(False)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn is_later_1_test() {
  day.from_unix_days(123_123)
  |> day.is_later(than: day.from_unix_days(123_124))
  |> should.equal(False)
}

pub fn is_later_2_test() {
  day.from_unix_days(123_123)
  |> day.is_later(than: day.from_unix_days(123_123))
  |> should.equal(False)
}

pub fn is_later_3_test() {
  day.from_unix_days(99_999_999)
  |> day.is_later(than: day.from_unix_days(123_124))
  |> should.equal(True)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn difference_1_test() {
  day.from_unix_days(123_123)
  |> day.difference(from: day.from_unix_days(123_124))
  |> should.equal(1)
}

pub fn difference_2_test() {
  day.from_unix_days(123_123)
  |> day.difference(from: day.from_unix_days(123_123))
  |> should.equal(0)
}

pub fn difference_3_test() {
  day.from_unix_days(0)
  |> day.difference(from: day.from_unix_days(123_123))
  |> should.equal(123_123)
}

pub fn difference_4_test() {
  day.from_unix_days(600_000)
  |> day.difference(from: day.from_unix_days(500_000))
  |> should.equal(-100_000)
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn add_1_test() {
  day.from_unix_days(123_123)
  |> day.add(days: 1)
  |> should.equal(day.from_unix_days(123_124))
}

pub fn add_2_test() {
  day.from_unix_days(123_123)
  |> day.add(days: 0)
  |> should.equal(day.from_unix_days(123_123))
}

// -------------------------------------------------------
// -------------------------------------------------------
// -------------------------------------------------------

pub fn subtract_1_test() {
  day.from_unix_days(123_123)
  |> day.subtract(days: 1)
  |> should.equal(day.from_unix_days(123_122))
}

pub fn subtract_2_test() {
  day.from_unix_days(123_123)
  |> day.subtract(days: 0)
  |> should.equal(day.from_unix_days(123_123))
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- JSON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn output(input: Day, expected_output: String) {
  input
  |> day.to_json()
  |> json.to_string()
  |> should.equal(expected_output)
}

pub fn output_input(input_and_expected_output: Day) {
  let date_decoder = day.decoder()

  input_and_expected_output
  |> day.to_json()
  |> json.to_string()
  |> json.parse(using: date_decoder)
  |> should.equal(Ok(input_and_expected_output))
}

// ----------------- TESTS --------------------

pub fn example_1_input_output_test() {
  output_input(day.from_unix_days(739_318))
}

pub fn example_2_input_output_test() {
  output_input(day.from_unix_days(728_578))
}

pub fn example_3_input_output_test() {
  output_input(day.from_unix_days(733_837))
}

pub fn example_1_output_test() {
  output(day.from_unix_days(739_318), "739318")
}

pub fn example_2_output_test() {
  output(day.from_unix_days(728_578), "728578")
}

pub fn example_3_output_test() {
  output(day.from_unix_days(733_837), "733837")
}

pub fn testing_date_keys_test() {
  let date_key_decoder = day.decoder_dict_key()
  let buh = dict.from_list([#(day.from_gtempo_literal("2001-01-01"), "beep")])

  buh
  |> json.dict(day.to_json_dict_key, json.string)
  |> json.to_string()
  |> json.parse(decode.dict(
    // basically the type signature for decode.then
    // expects you to have a function that takes in
    // the initially decoded type and then the decoder
    // you actually want. We don't need that so have a
    // weird type signature!
    date_key_decoder,
    decode.string,
  ))
  |> should.equal(Ok(buh))
}
