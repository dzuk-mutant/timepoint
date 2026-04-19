import day
import gleam/dynamic/decode
import gleam/json
import gleeunit/should
import interval/day_interval
import interval/moment_interval
import moment
import versioning/timelined/tl_current_variant
import versioning/timelined/tl_past_variant.{type TLPastVariant}

// ----------------------------------------
// ----------------------------------------
// ---------------- JSON ------------------
// ----------------------------------------
// ----------------------------------------

fn json_o(input: TLPastVariant(String), expected_output: String) {
  input
  |> tl_past_variant.to_json(value_encoder: json.string)
  |> json.to_string()
  |> should.equal(expected_output)
}

fn json_io(expected_input_and_output: TLPastVariant(String)) {
  let tl_decoder =
    tl_past_variant.decoder(default_value: "oops", value_decoder: decode.string)

  expected_input_and_output
  |> tl_past_variant.to_json(value_encoder: json.string)
  |> json.to_string()
  |> json.parse(using: tl_decoder)
  |> should.equal(Ok(expected_input_and_output))
}

pub fn json_o_1_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-23T00:00:00.000Z"),
    value: "boop",
  )
  |> json_o(
    "{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1740096000,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1740268800,\"unix_ns\":0},\"offset\":0}},\"value\":\"boop\"}",
  )
}

pub fn json_io_1_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-23T00:00:00.000Z"),
    value: "boop",
  )
  |> json_io
}

pub fn json_o_2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2001-10-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2001-10-23T00:00:00.000Z"),
    value: "weeeeew",
  )
  |> json_o(
    "{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1003622400,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1003795200,\"unix_ns\":0},\"offset\":0}},\"value\":\"weeeeew\"}",
  )
}

pub fn json_io_2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2001-10-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2001-10-23T00:00:00.000Z"),
    value: "weeeeew",
  )
  |> json_io
}

// ----------------------------------------
// ----------------------------------------
// -------- unwrap ---------
// ----------------------------------------
// ----------------------------------------

pub fn variant_unwrap_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-23T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.unwrap()
  |> should.equal("boop")
}

// ----------------------------------------
// ----------------------------------------
// -------- new, to_start_moment, to_end_excluding_moment ---------
// ----------------------------------------
// ----------------------------------------

/// Start and end_excluding are in the right order.
pub fn new_1_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.to_start_moment()
  |> should.equal(moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"))
}

/// Start and end_excluding are in the right order.
pub fn new_2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-02T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.to_end_excluding_moment()
  |> should.equal(moment.from_gtempo_literal("2025-03-02T00:00:00.000Z"))
}

/// Start and end_excluding are in the wrong order.
/// 
/// THIS SHOULD NOT BE ALLOWABLE IN THE APPLICATION.
/// THIS IS A DELIBERATE EXAMPLE OF THINGS GOING WRONG.
pub fn new_unsafe_use_1_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.to_start_moment()
  |> should.equal(moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"))
}

/// Start and end_excluding are in the wrong order.
/// 
/// THIS SHOULD NOT BE ALLOWABLE IN THE APPLICATION.
/// THIS IS A DELIBERATE EXAMPLE OF THINGS GOING WRONG.
pub fn new_unsafe_use_2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.to_end_excluding_moment()
  |> should.equal(moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"))
}

// ----------------------------------------
// ----------------------------------------
// -------- from_current_variant ---------
// ----------------------------------------
// ----------------------------------------

/// Start and end_excluding are in the right order.
pub fn from_moment_start_1_test() {
  tl_current_variant.new(
    start: moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.from_current_variant(
    end_excluding: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
  )
  |> tl_past_variant.to_start_moment()
  |> should.equal(moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"))
}

/// Start and end_excluding are in the right order.
pub fn from_moment_start_2_test() {
  tl_current_variant.new(
    start: moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.from_current_variant(
    end_excluding: moment.from_gtempo_literal("2025-05-05T00:00:00.000Z"),
  )
  |> tl_past_variant.to_end_excluding_moment()
  |> should.equal(moment.from_gtempo_literal("2025-05-05T00:00:00.000+00:00"))
}

/// Start and end_excluding are in the wrong order.
/// 
/// THIS SHOULD NOT BE ALLOWABLE IN THE APPLICATION.
/// THIS IS A DELIBERATE EXAMPLE OF THINGS GOING WRONG.
pub fn from_moment_unsafe_use_1_test() {
  tl_current_variant.new(
    start: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.from_current_variant(
    end_excluding: moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"),
  )
  |> tl_past_variant.to_start_moment()
  |> should.equal(moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"))
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
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.truncate(behind: moment.from_gtempo_literal(
    "2025-03-20T00:00:00.000Z",
  ))
  |> should.equal(
    Ok(tl_past_variant.new(
      start: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2025-03-20T00:00:00.000Z"),
      value: "boop",
    )),
  )
}

///     S--------F
///     S-----------F (new)
/// 
///     (Error - later than it should be.)
pub fn truncate_2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.truncate(behind: moment.from_gtempo_literal(
    "2025-04-20T00:00:00.000Z",
  ))
  |> should.equal(Error(moment_interval.ResultIntervalIsLarger))
}

///     S--------F
///     S+F (new)
/// 
///     (Error - end is at start)
pub fn truncate_3_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-03-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.truncate(behind: moment.from_gtempo_literal(
    "2025-03-01T00:00:00.000Z",
  ))
  |> should.equal(Error(moment_interval.ResultIntervalIsZero))
}

///       S--------F
///     F-S (new)
/// 
///     (Error)
pub fn truncate_4_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-03-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.truncate(behind: moment.from_gtempo_literal(
    "2025-03-01T00:00:00.000Z",
  ))
  |> should.equal(Error(moment_interval.ResultIntervalIsZero))
}

///       S--------F
///  F----S (new)
/// 
///     (Error)
pub fn truncate_5_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-03-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.truncate(behind: moment.from_gtempo_literal(
    "2025-02-01T00:00:00.000Z",
  ))
  |> should.equal(Error(moment_interval.ResultIntervalIsZero))
}

// ================================================
// ====== is_effective_in_moment_interval ==============
// ================================================

///             |------|
///  o------o
/// 
///    (False)
pub fn is_effective_in_moment_interval_1_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///          |------|
///  o------o (just misses by 1ms)
/// 
///    (False)
pub fn is_effective_in_moment_interval_2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///         |------|
///  o------o
/// 
///    (False)
pub fn is_effective_in_moment_interval_2x_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///         |------|
///    o------o
/// 
///    (True)
pub fn is_effective_in_moment_interval_3_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-10T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-03T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///     |-------------|
///        o-------o
/// 
///    (True)
pub fn is_effective_in_moment_interval_4_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-31T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-01-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-20T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///       |-------|
///    o------------o
/// 
///    (True)
pub fn is_effective_in_moment_interval_5_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-05-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-20T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///     |---------|
///          o----------o
/// 
///    (True)
pub fn is_effective_in_moment_interval_6_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-01-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-20T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///     |---------| (just by 1ms)
///                o-----o
/// 
///    (False)
pub fn is_effective_in_moment_interval_7_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-01-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-01T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///     |---------|
///               o-----o
/// 
///    (False)
pub fn is_effective_in_moment_interval_7x_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-01-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-01T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///     |---------|
///                   o-----o
/// 
///    (False)
pub fn is_effective_in_moment_interval_8_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-01-11T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-03-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-01T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

// ================================================
// ====== is_effective_in_day_interval ==============
// ================================================

///             |------|
///  o------o
/// 
///    (False)
pub fn is_effective_in_day_interval_1_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-02-21"),
    final: day.from_gtempo_literal("2025-02-25"),
  ))
  |> should.equal(False)
}

///          |------|
///  o------o (just off as it goes into the next day)
/// 
///    (False)
pub fn is_effective_in_day_interval_2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-02-04"),
    final: day.from_gtempo_literal("2025-02-25"),
  ))
  |> should.equal(False)
}

///         t-------t
///  d------d (made it by 1ms)
/// 
///    (True)
pub fn is_effective_in_day_interval_2x_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-02-03"),
    final: day.from_gtempo_literal("2025-02-25"),
  ))
  |> should.equal(True)
}

///         |-------|
///  o------o (directly on end_excluding)
/// 
///    (False)
pub fn is_effective_in_day_interval_2xx_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-02-04"),
    final: day.from_gtempo_literal("2025-02-25"),
  ))
  |> should.equal(False)
}

///         |------|
///    o------o
/// 
///    (True)
pub fn is_effective_in_day_interval_3_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-10T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-02-03"),
    final: day.from_gtempo_literal("2025-02-25"),
  ))
  |> should.equal(True)
}

///     |-------------|
///        o-------o
/// 
///    (True)
pub fn is_effective_in_day_interval_4_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-31T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-01-02"),
    final: day.from_gtempo_literal("2025-04-20"),
  ))
  |> should.equal(True)
}

///       |-------|
///    o------------o
/// 
///    (True)
pub fn is_effective_in_day_interval_5_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-05-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-02-02"),
    final: day.from_gtempo_literal("2025-03-20"),
  ))
  |> should.equal(True)
}

///     |---------|
///          o----------o
/// 
///    (True)
pub fn is_effective_in_day_interval_6_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-01-02"),
    final: day.from_gtempo_literal("2025-02-20"),
  ))
  |> should.equal(True)
}

///     d---------d
///               t-----t
/// 
///    (True)
pub fn is_effective_in_day_interval_7_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-01-02"),
    final: day.from_gtempo_literal("2025-02-01"),
  ))
  |> should.equal(True)
}

///     |---------|
///               o-----o
/// 
///    (on the starting millisecond)
///    (True)
pub fn is_effective_in_day_interval_7x_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-31T23:59:59.999Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-01-02"),
    final: day.from_gtempo_literal("2025-01-31"),
  ))
  |> should.equal(True)
}

///     |---------|
///                   o-----o
/// 
///    (False)
pub fn is_effective_in_day_interval_8_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-01-11T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-03-02"),
    final: day.from_gtempo_literal("2025-04-01"),
  ))
  |> should.equal(False)
}

///          |------|
///  o------o (just misses)
/// 
///    (True)
/// 
pub fn is_effective_in_day_interval_t1_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-03T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-02-04"),
    final: day.from_gtempo_literal("2025-02-25"),
  ))
  |> should.equal(False)
}

///          |-----|
///  o------o (just passes)
/// 
///    (False)
/// 
pub fn is_effective_in_day_interval_t2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-04T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-02-04"),
    final: day.from_gtempo_literal("2025-02-25"),
  ))
  |> should.equal(False)
}

///     |---------| (just misses)
///                o-----o
/// 
///    (True)
/// 
pub fn is_effective_in_day_interval_t3_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-03-31T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-01-02"),
    final: day.from_gtempo_literal("2025-02-01"),
  ))
  |> should.equal(False)
}

///     |---------| (just hits)
///               o-----o
/// 
///    (True)
/// 
pub fn is_effective_in_day_interval_t4_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-02-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-04-01T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-01-02"),
    final: day.from_gtempo_literal("2025-02-01"),
  ))
  |> should.equal(True)
}

// ================================================
// ============= is_effective_on_day ==================
// ================================================

///             x
///   o-----o
/// 
///     (False)
pub fn is_effective_on_day_1_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-01-11T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_on_day(day.from_gtempo_literal("2025-03-25"))
  |> should.equal(False)
}

///          x  (missed by 1ms)
///   o-----o
/// 
///     (False)
pub fn is_effective_on_day_2_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-01-11T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_on_day(day.from_gtempo_literal("2025-01-11"))
  |> should.equal(False)
}

///         x
///   o-----o
/// 
///     (False)
pub fn is_effective_on_day_2x_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-01-11T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_on_day(day.from_gtempo_literal("2025-01-11"))
  |> should.equal(False)
}

///       x
///   o-----o
/// 
///     (True)
pub fn is_effective_on_day_3_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-01-11T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_on_day(day.from_gtempo_literal("2025-01-05"))
  |> should.equal(True)
}

///   x
///   o-----o
/// 
///     (True)
pub fn is_effective_on_day_4_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-01-11T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_on_day(day.from_gtempo_literal("2025-01-01"))
  |> should.equal(True)
}

/// x
///   o-----o
/// 
///     (False)
pub fn is_effective_on_day_5_test() {
  tl_past_variant.new(
    start: moment.from_gtempo_literal("2025-08-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-08-11T00:00:00.000Z"),
    value: "boop",
  )
  |> tl_past_variant.is_effective_on_day(day.from_gtempo_literal("2025-01-01"))
  |> should.equal(False)
}
