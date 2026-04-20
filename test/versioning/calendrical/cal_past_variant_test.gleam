import day
import gleam/dynamic/decode
import gleam/json
import gleeunit/should
import interval/day_interval
import versioning/calendrical/cal_current_variant
import versioning/calendrical/cal_past_variant.{type CalPastVariant}

// ----------------------------------------
// ----------------------------------------
// ---------------- JSON ------------------
// ----------------------------------------
// ----------------------------------------

fn json_o(input: CalPastVariant(String), expected expected: String) {
  input
  |> cal_past_variant.to_json(value_encoder: json.string)
  |> json.to_string()
  |> should.equal(expected)
}

fn json_io(expected_input_and_output: CalPastVariant(String)) {
  let cal_decoder =
    cal_past_variant.decoder(
      default_value: "oops",
      value_decoder: decode.string,
    )

  expected_input_and_output
  |> cal_past_variant.to_json(value_encoder: json.string)
  |> json.to_string()
  |> json.parse(using: cal_decoder)
  |> should.equal(Ok(expected_input_and_output))
}

pub fn json_o_1_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-23"),
    value: "boop",
  )
  |> json_o(
    expected: "{\"interval\":{\"start\":20140,\"final\":20142},\"value\":\"boop\"}",
  )
}

pub fn json_io_1_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-23"),
    value: "boop",
  )
  |> json_io
}

pub fn json_o_2_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2001-10-21"),
    final: day.testing_iso8601("2001-10-23"),
    value: "boop",
  )
  |> json_o(
    expected: "{\"interval\":{\"start\":11616,\"final\":11618},\"value\":\"boop\"}",
  )
}

pub fn json_io_2_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2001-10-21"),
    final: day.testing_iso8601("2001-10-23"),
    value: "boop",
  )
  |> json_io
}

// ----------------------------------------
// ----------------------------------------
// -------- unwrap ---------
// ----------------------------------------
// ----------------------------------------

pub fn variant_unwrap_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-23"),
    value: "boop",
  )
  |> cal_past_variant.unwrap()
  |> should.equal("boop")
}

// ----------------------------------------
// ----------------------------------------
// -------- new, to_start_day, to_final_day ---------
// ----------------------------------------
// ----------------------------------------

/// Start and final are in the right order.
pub fn new_1_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-24"),
    final: day.testing_iso8601("2025-03-01"),
    value: "boop",
  )
  |> cal_past_variant.to_start_day()
  |> should.equal(day.testing_iso8601("2025-02-24"))
}

/// Start and final are in the right order.
pub fn new_2_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-24"),
    final: day.testing_iso8601("2025-03-01"),
    value: "boop",
  )
  |> cal_past_variant.to_final_day()
  |> should.equal(day.testing_iso8601("2025-03-01"))
}

/// Start and final are in the wrong order.
/// 
/// THIS SHOULD NOT BE ALLOWABLE IN THE APPLICATION.
/// THIS IS A DELIBERATE EXAMPLE OF THINGS GOING WRONG.
pub fn new_unsafe_use_1_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-24"),
    final: day.testing_iso8601("2025-03-01"),
    value: "boop",
  )
  |> cal_past_variant.to_start_day()
  |> should.equal(day.testing_iso8601("2025-03-24"))
}

/// Start and final are in the wrong order.
/// 
/// THIS SHOULD NOT BE ALLOWABLE IN THE APPLICATION.
/// THIS IS A DELIBERATE EXAMPLE OF THINGS GOING WRONG.
pub fn new_unsafe_use_2_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-24"),
    final: day.testing_iso8601("2025-03-01"),
    value: "boop",
  )
  |> cal_past_variant.to_final_day()
  |> should.equal(day.testing_iso8601("2025-03-01"))
}

// ----------------------------------------
// ----------------------------------------
// -------- from_current_variant ---------
// ----------------------------------------
// ----------------------------------------

/// Start and final are in the right order.
pub fn from_day_start_1_test() {
  cal_current_variant.new(
    start: day.testing_iso8601("2025-02-24"),
    value: "boop",
  )
  |> cal_past_variant.from_current_variant(end_excluding: day.testing_iso8601(
    "2025-03-02",
  ))
  |> cal_past_variant.to_start_day()
  |> should.equal(day.testing_iso8601("2025-02-24"))
}

/// Start and final are in the right order.
pub fn from_day_start_2_test() {
  cal_current_variant.new(
    start: day.testing_iso8601("2025-02-24"),
    value: "boop",
  )
  |> cal_past_variant.from_current_variant(end_excluding: day.testing_iso8601(
    "2025-03-02",
  ))
  |> cal_past_variant.to_final_day()
  |> should.equal(day.testing_iso8601("2025-03-01"))
}

/// Start and final are in the wrong order.
/// 
/// THIS SHOULD NOT BE ALLOWABLE IN THE APPLICATION.
/// THIS IS A DELIBERATE EXAMPLE OF THINGS GOING WRONG.
pub fn from_day_unsafe_use_1_test() {
  cal_current_variant.new(
    start: day.testing_iso8601("2025-03-01"),
    value: "boop",
  )
  |> cal_past_variant.from_current_variant(end_excluding: day.testing_iso8601(
    "2025-02-25",
  ))
  |> cal_past_variant.to_start_day()
  |> should.equal(day.testing_iso8601("2025-03-01"))
}

/// Start and final are in the wrong order.
/// 
/// THIS SHOULD NOT BE ALLOWABLE IN THE APPLICATION.
/// THIS IS A DELIBERATE EXAMPLE OF THINGS GOING WRONG.
pub fn from_day_unsafe_use_2_test() {
  cal_current_variant.new(
    start: day.testing_iso8601("2025-03-01"),
    value: "boop",
  )
  |> cal_past_variant.from_current_variant(end_excluding: day.testing_iso8601(
    "2025-02-25",
  ))
  |> cal_past_variant.to_final_day()
  |> should.equal(day.testing_iso8601("2025-02-24"))
}

// ----------------------------------------
// ----------------------------------------
// ----------- truncate -----------------
// ----------------------------------------
// ----------------------------------------

///     S--------F
///     S----F (new)
/// 
///     (Ok)
pub fn truncate_1_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-01"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.truncate(behind: day.testing_iso8601("2025-03-21"))
  |> should.equal(
    Ok(cal_past_variant.new(
      start: day.testing_iso8601("2025-03-01"),
      final: day.testing_iso8601("2025-03-20"),
      value: "boop",
    )),
  )
}

///     S--------F
///     S-----------F (new)
/// 
///     (Ok)
pub fn truncate_2_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-01"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.truncate(behind: day.testing_iso8601("2025-03-21"))
  |> should.equal(
    Ok(cal_past_variant.new(
      start: day.testing_iso8601("2025-03-01"),
      final: day.testing_iso8601("2025-03-20"),
      value: "boop",
    )),
  )
}

///     S--------F
///     S+F (new)
/// 
///     (Ok)
pub fn truncate_3_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-01"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.truncate(behind: day.testing_iso8601("2025-03-02"))
  |> should.equal(
    Ok(cal_past_variant.new(
      start: day.testing_iso8601("2025-03-01"),
      final: day.testing_iso8601("2025-03-01"),
      value: "boop",
    )),
  )
}

///       S--------F
///     F-S (new)
/// 
///     (Error)
pub fn truncate_4_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.truncate(behind: day.testing_iso8601("2025-03-02"))
  |> should.equal(Error(day_interval.FinalIsEarlierThanStart))
}

///       S--------F
///  F----S (new)
/// 
///     (Error)
pub fn truncate_5_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.truncate(behind: day.testing_iso8601("2025-02-01"))
  |> should.equal(Error(day_interval.FinalIsEarlierThanStart))
}

// ----------------------------------------
// ----------------------------------------
// ------ is_effective_in_day_interval --------
// ----------------------------------------
// ----------------------------------------

///             |------|
///  o------o
/// 
///    (False)
pub fn is_around_day_interval_1_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-02"),
    final: day.testing_iso8601("2025-02-04"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(False)
}

///         |------|
///  o------o
/// 
///    (True)
pub fn is_around_day_interval_2_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-02"),
    final: day.testing_iso8601("2025-02-04"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-04"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(True)
}

///         |------|
///    o------o
/// 
///    (True)
pub fn is_around_day_interval_3_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-02"),
    final: day.testing_iso8601("2025-02-10"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-03"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(True)
}

///     |-------------|
///        o-------o
/// 
///    (True)
pub fn is_around_day_interval_4_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-02"),
    final: day.testing_iso8601("2025-03-31"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-01-02"),
    final: day.testing_iso8601("2025-04-20"),
  ))
  |> should.equal(True)
}

///       |-------|
///    o------------o
/// 
///    (True)
pub fn is_around_day_interval_5_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-01-01"),
    final: day.testing_iso8601("2025-05-01"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-02"),
    final: day.testing_iso8601("2025-03-20"),
  ))
  |> should.equal(True)
}

///     |---------|
///          o----------o
/// 
///    (True)
pub fn is_around_day_interval_6_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-02"),
    final: day.testing_iso8601("2025-04-01"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-01-02"),
    final: day.testing_iso8601("2025-02-20"),
  ))
  |> should.equal(True)
}

///     |---------|
///               o-----o
/// 
///    (True)
pub fn is_around_day_interval_7_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-02-01"),
    final: day.testing_iso8601("2025-04-01"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-01-02"),
    final: day.testing_iso8601("2025-02-01"),
  ))
  |> should.equal(True)
}

///     |---------|
///                   o-----o
/// 
///    (False)
pub fn is_around_day_interval_8_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-01-01"),
    final: day.testing_iso8601("2025-01-11"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-04-01"),
  ))
  |> should.equal(False)
}

// ----------------------------------------
// ----------------------------------------
// ----------- is_effective_on_day -------------
// ----------------------------------------
// ----------------------------------------

///            H
///     S----F
/// 
///     (False)
pub fn is_effective_on_day_1_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_on_day(day.testing_iso8601("2025-04-20"))
  |> should.equal(False)
}

///          H
///     S----F
/// 
///     (True)
pub fn is_effective_on_day_2_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_on_day(day.testing_iso8601("2025-03-24"))
  |> should.equal(True)
}

///        H
///     S----F
/// 
///     (True)
pub fn is_effective_on_day_3_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_on_day(day.testing_iso8601("2025-03-15"))
  |> should.equal(True)
}

///        H
///       S+F
/// 
///     (True)
pub fn is_effective_on_day_4_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-03-02"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_on_day(day.testing_iso8601("2025-03-02"))
  |> should.equal(True)
}

///     H
///     S----F
/// 
///     (True)
pub fn is_effective_on_day_5_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_on_day(day.testing_iso8601("2025-03-02"))
  |> should.equal(True)
}

///     H
///        S----F
/// 
///     (False)
pub fn is_effective_on_day_6_test() {
  cal_past_variant.new(
    start: day.testing_iso8601("2025-03-02"),
    final: day.testing_iso8601("2025-03-24"),
    value: "boop",
  )
  |> cal_past_variant.is_effective_on_day(day.testing_iso8601("2025-02-02"))
  |> should.equal(False)
}
