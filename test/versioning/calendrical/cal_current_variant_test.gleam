import day
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleeunit/should
import interval/day_interval
import versioning/calendrical/cal_current_variant.{type CalCurrentVariant}

// --------------------------------------------
// --------------------------------------------
// ----------------- JSON --------------------
// --------------------------------------------
// --------------------------------------------
pub fn json_o(input: CalCurrentVariant(String), expected expected: String) {
  input
  |> cal_current_variant.to_json(fn(x) { x |> json.string })
  |> json.to_string()
  |> should.equal(expected)
}

pub fn json_io(
  input_and_expected_output: CalCurrentVariant(String),
  value_decoder: Decoder(String),
) {
  let variant_decoder =
    cal_current_variant.decoder(default_value: "boop", value_decoder:)
  input_and_expected_output
  |> cal_current_variant.to_json(fn(x) { x |> json.string })
  |> json.to_string()
  |> json.parse(using: variant_decoder)
  |> should.equal(Ok(input_and_expected_output))
}

pub fn json_o_1_test() {
  cal_current_variant.new(
    start: day.from_gtempo_literal("2025-03-08"),
    value: "33333",
  )
  |> json_o(expected: "{\"start\":20155,\"value\":\"33333\"}")
}

pub fn json_io_1_test() {
  cal_current_variant.new(
    start: day.from_gtempo_literal("2025-03-08"),
    value: "33333",
  )
  |> json_io(decode.string)
}

// =====================================
// ============ unwrap ==============
// ================================================
pub fn unwrap_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-02-02"),
  )
  |> cal_current_variant.unwrap
  |> should.equal("boop")
}

// =====================================
// ============ to_start_day ==============
// ================================================
pub fn to_start_day_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-02-02"),
  )
  |> cal_current_variant.to_start_day
  |> should.equal(day.from_gtempo_literal("2025-02-02"))
}

// ================================================
// ====== is_effective_in_day_interval ==============
// ================================================

///    |------|
///  o-------------
/// 
///    (True)
pub fn is_effective_in_day_interval_1_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-02-02"),
  )
  |> cal_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025.02.21"),
    final: day.from_gtempo_literal("2025.02.25"),
  ))
  |> should.equal(True)
}

///    |------|
///    o-------------
/// 
///    (True)
pub fn is_effective_in_day_interval_2_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-02-21"),
  )
  |> cal_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025.02.21"),
    final: day.from_gtempo_literal("2025.02.25"),
  ))
  |> should.equal(True)
}

///    |------|
///       o----------
/// 
///    (True)
pub fn is_effective_in_day_interval_3_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-02-22"),
  )
  |> cal_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025.02.21"),
    final: day.from_gtempo_literal("2025.02.25"),
  ))
  |> should.equal(True)
}

///    |------|
///           o---------
/// 
///    (True)
pub fn is_effective_in_day_interval_4_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-02-25"),
  )
  |> cal_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025.02.21"),
    final: day.from_gtempo_literal("2025.02.25"),
  ))
  |> should.equal(True)
}

///    |------|
///               o---------
/// 
///    (False)
pub fn is_effective_in_day_interval_5_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-03-24"),
  )
  |> cal_current_variant.is_effective_in_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025.02.21"),
    final: day.from_gtempo_literal("2025.02.25"),
  ))
  |> should.equal(False)
}

// ================================================
// ============= is_effective_on_day ==================
// ================================================

///      x
///    o---------
/// 
///     (True)
pub fn is_effective_on_day_1_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-03-24"),
  )
  |> cal_current_variant.is_effective_on_day(day.from_gtempo_literal(
    "2025-03-25",
  ))
  |> should.equal(True)
}

///      x
///      o-------
/// 
///     (True)
pub fn is_effective_on_day_2_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-03-24"),
  )
  |> cal_current_variant.is_effective_on_day(day.from_gtempo_literal(
    "2025-03-24",
  ))
  |> should.equal(True)
}

///      x
///        o-------
/// 
///     (False)
pub fn is_effective_on_day_3_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-03-24"),
  )
  |> cal_current_variant.is_effective_on_day(day.from_gtempo_literal(
    "2025-03-21",
  ))
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
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-03-24"),
  )
  |> cal_current_variant.overlaps(day.from_gtempo_literal("2025-03-25"))
  |> should.equal(True)
}

///      x
///      o-------
/// 
///     (True)
pub fn overlaps_2_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-03-24"),
  )
  |> cal_current_variant.overlaps(day.from_gtempo_literal("2025-03-24"))
  |> should.equal(True)
}

///      x
///        o-------
/// 
///     (False)
pub fn overlaps_3_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.from_gtempo_literal("2025-03-24"),
  )
  |> cal_current_variant.overlaps(day.from_gtempo_literal("2025-03-21"))
  |> should.equal(False)
}
