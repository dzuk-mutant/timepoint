import day
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleeunit/should
import interval/day_interval
import interval/moment_interval
import moment
import versioning/timelined/tl_current_variant.{type TLCurrentVariant}

// --------------------------------------------
// --------------------------------------------
// ----------------- JSON --------------------
// --------------------------------------------
// --------------------------------------------

pub fn output(
  input: TLCurrentVariant(String),
  value_encoder: fn(String) -> Json,
  expected_output: String,
) {
  input
  |> tl_current_variant.to_json(value_encoder)
  |> json.to_string()
  |> should.equal(expected_output)
}

pub fn output_input(
  input_and_expected_output: TLCurrentVariant(String),
  value_encoder: fn(String) -> Json,
  value_decoder: Decoder(String),
) {
  let decoder =
    tl_current_variant.decoder(value_decoder:, default_value: "boop")

  input_and_expected_output
  |> tl_current_variant.to_json(value_encoder)
  |> json.to_string()
  |> json.parse(using: decoder)
  |> should.equal(Ok(input_and_expected_output))
}

// ----------------- TESTS --------------------

pub fn example_1_output_test() {
  output(
    tl_current_variant.new(
      start: moment.from_gtempo_literal("2025-03-08T00:00:00.000Z"),
      value: "33333",
    ),
    fn(x) { x |> json.string },
    "{\"start\":{\"timestamp\":{\"unix_s\":1741392000,\"unix_ns\":0},\"offset\":0},\"value\":\"33333\"}",
  )
}

pub fn example_1_input_output_test() {
  output_input(
    tl_current_variant.new(
      start: moment.from_gtempo_literal("2025-03-08T00:00:00.000Z"),
      value: "33333",
    ),
    fn(x) { x |> json.string },
    decode.string,
  )
}

// =====================================
// ============ unwrap ==============
// ================================================
pub fn unwrap_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
  )
  |> tl_current_variant.unwrap
  |> should.equal("boop")
}

// =====================================
// ============ to_start_day ==============
// ================================================
pub fn to_start_day_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
  )
  |> tl_current_variant.to_start_moment
  |> should.equal(moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"))
}

// ================================================
// ====== is_effective_in_moment_interval ==============
// ================================================

///    |------|
///  o-------------
/// 
///    (True)
pub fn is_effective_in_moment_interval_1_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///    |------|
///    o-------------
/// 
///    (True)
pub fn is_effective_in_moment_interval_2_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///    |------|
///       o----------
/// 
///    (True)
pub fn is_effective_in_moment_interval_3_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-22T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///    |------|
///           o---------
/// 
///    (False)
pub fn is_effective_in_moment_interval_4_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///    |------|
///               o---------
/// 
///    (False)
pub fn is_effective_in_moment_interval_5_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

// ================================================
// ====== is_effective_in_day_interval ==============
// ================================================

///    |------|
///  o-------------
/// 
///    (True)
pub fn is_effective_in_day_interval_1_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(True)
}

///    |------|
///    o-------------
/// 
///    (True)
pub fn is_effective_in_day_interval_2_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-21T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(True)
}

///    |------|
///       o----------
/// 
///    (True)
pub fn is_effective_in_day_interval_3_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-22T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(True)
}

///    |------|
///           o---------
/// 
///    (True)
pub fn is_effective_in_day_interval_4_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(True)
}

///    |------|
///               o---------
/// 
///    (False)
pub fn is_effective_in_day_interval_5_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(False)
}

///    |------|  (just misses)
///            o---------
/// 
///    (True)
pub fn is_effective_in_day_interval_t1_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2026-02-26T00:00:00.001+00:00"),
  )
  |> tl_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(False)
}

///    |------|  (just passes)
///           o---------
/// 
///    (True)
pub fn is_effective_in_day_interval_t2_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-02-25T23:59:59.999+00:00"),
  )
  |> tl_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.testing_iso8601("2025-02-21"),
    final: day.testing_iso8601("2025-02-25"),
  ))
  |> should.equal(True)
}

// ================================================
// ============= is_effective_on_day ==================
// ================================================

///      x
///    o---------
/// 
///     (True)
pub fn is_effective_on_day_1_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_on_day(day.testing_iso8601("2025-03-25"))
  |> should.equal(True)
}

///      x
///      o-------
/// 
///     (True)
pub fn is_effective_on_day_2_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_on_day(day.testing_iso8601("2025-03-24"))
  |> should.equal(True)
}

///      x
///        o-------
/// 
///     (False)
pub fn is_effective_on_day_3_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
  )
  |> tl_current_variant.is_effective_on_day(day.testing_iso8601("2025-03-21"))
  |> should.equal(False)
}

// ================================================
// ============= overlaps ==================
// ================================================

///      x
///    o---------
/// 
///     (True)
pub fn overlaps_1_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
  )
  |> tl_current_variant.overlaps(moment.from_gtempo_literal(
    "2025-03-25T00:00:00.000Z",
  ))
  |> should.equal(True)
}

///      x
///      o-------
/// 
///     (True)
pub fn overlaps_2_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
  )
  |> tl_current_variant.overlaps(moment.from_gtempo_literal(
    "2025-03-24T00:00:00.000Z",
  ))
  |> should.equal(True)
}

///      x
///        o-------
/// 
///     (False)
pub fn overlaps_3_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.from_gtempo_literal("2025-03-24T00:00:00.000Z"),
  )
  |> tl_current_variant.overlaps(moment.from_gtempo_literal(
    "2025-03-21T00:00:00.000Z",
  ))
  |> should.equal(False)
}
