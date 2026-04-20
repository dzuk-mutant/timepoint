import day
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleeunit/should
import interval/day_interval
import versioning/calendrical.{
  type Calendrical, InvalidNewCurrentIsEarlierThanHistoricalStart, NoChange,
  NonDestructive, WillOverwriteCurrent, WillOverwriteCurrentAndHistory,
}
import versioning/calendrical/cal_any_variant.{Current, Past}
import versioning/calendrical/cal_current_variant
import versioning/calendrical/cal_past_variant
import versioning/calendrical/cal_slice.{CalSlice}

fn eq_func(a: String, b: String) -> Bool {
  a == b
}

// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------

// ----------------------------------------
// ------------------ JSON ----------------
// ----------------------------------------
fn json_o(input: Calendrical(String), expected expected: String) {
  input
  |> calendrical.to_json(value_encoder: json.string)
  |> json.to_string()
  |> should.equal(expected)
}

fn json_io(input_and_expected_output: Calendrical(String)) {
  let decoder =
    calendrical.decoder(
      default_value: "oops",
      value_decoder: decode.string,
      equality_fn: fn(a, b) { a == b },
    )
  input_and_expected_output
  |> calendrical.to_json(value_encoder: json.string)
  |> json.to_string()
  |> json.parse(using: decoder)
  |> result.map(calendrical.to_list)
  |> should.equal(Ok(input_and_expected_output |> calendrical.to_list))
}

fn json_erroneous_string(string: String) {
  let decoder =
    calendrical.decoder(
      default_value: "oops",
      value_decoder: decode.string,
      equality_fn: fn(a, b) { a == b },
    )
  string
  |> json.parse(using: decoder)
  |> result.is_error()
  |> should.equal(True)
}

fn example_1() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
}

pub fn json_o_1_test() {
  example_1()
  |> json_o(
    expected: "{\"current\":{\"start\":20144,\"value\":\"🎸🥁\"},\"history_start\":20121,\"history\":[{\"interval\":{\"start\":20138,\"final\":20143},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":20137,\"final\":20137},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":20121,\"final\":20136},\"value\":\"whatever\"}]}",
  )
}

pub fn json_io_1_test() {
  example_1()
  |> json_io
}

fn example_2() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
}

pub fn json_o_2_test() {
  example_2()
  |> json_o(
    expected: "{\"current\":{\"start\":20121,\"value\":\"whatever\"},\"history_start\":20121,\"history\":[]}",
  )
}

pub fn json_io_2_test() {
  example_2()
  |> json_io
}

/// one of the historical dates is not contiguous.
/// 
/// (These numbers are using the old rata die system
/// so they are wildly in the future now that UNIX time
/// is used. The date formatting and logic is still
/// completely the same though, so these tests don't
/// need rewriting.)
pub fn json_erroneous_string_1_test() {
  "{\"current\":{\"start\":739307,\"value\":\"🎸🥁\"},\"history_start\":739284,\"history\":[{\"interval\":{\"start\":739301,\"final\":739306},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":739300,\"final\":739300},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":739284,\"final\":739289},\"value\":\"whatever\"}]}"
  |> json_erroneous_string()
}

/// one of the historical dates is not contiguous. (take 2)
/// /// 
/// (These numbers are using the old rata die system
/// so they are wildly in the future now that UNIX time
/// is used. The date formatting and logic is still
/// completely the same though, so these tests don't
/// need rewriting.)
pub fn json_erroneous_string_2_test() {
  "{\"current\":{\"start\":739307,\"value\":\"🎸🥁\"},\"history_start\":739284,\"history\":[{\"interval\":{\"start\":739301,\"final\":739327},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":739300,\"final\":739300},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":739284,\"final\":739299},\"value\":\"whatever\"}]}"
  |> json_erroneous_string()
}

/// one of the historical dates is not contiguous. (take 3, i fucked up a lot)
/// /// 
/// (These numbers are using the old rata die system
/// so they are wildly in the future now that UNIX time
/// is used. The date formatting and logic is still
/// completely the same though, so these tests don't
/// need rewriting.)
pub fn json_erroneous_string_3_test() {
  "{\"current\":{\"start\":739307,\"value\":\"🎸🥁\"},\"history_start\":739284,\"history\":[{\"interval\":{\"start\":0000002,\"final\":739306},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":99999,\"final\":343631},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":002424,\"final\":739299},\"value\":\"whatever\"}]}"
  |> json_erroneous_string()
}

/// current is not contiguous with history.
/// /// 
/// (These numbers are using the old rata die system
/// so they are wildly in the future now that UNIX time
/// is used. The date formatting and logic is still
/// completely the same though, so these tests don't
/// need rewriting.)
pub fn json_erroneous_string_4_test() {
  "{\"current\":{\"start\":739317,\"value\":\"🎸🥁\"},\"history_start\":739284,\"history\":[{\"interval\":{\"start\":739301,\"final\":739306},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":739300,\"final\":739300},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":739284,\"final\":739299},\"value\":\"whatever\"}]}"
  |> json_erroneous_string()
}

/// start date doesn't match first variant.
/// /// 
/// (These numbers are using the old rata die system
/// so they are wildly in the future now that UNIX time
/// is used. The date formatting and logic is still
/// completely the same though, so these tests don't
/// need rewriting.)
pub fn json_erroneous_string_5_test() {
  "{\"current\":{\"start\":739307,\"value\":\"🎸🥁\"},\"history_start\":000001,\"history\":[{\"interval\":{\"start\":739301,\"final\":739306},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":739300,\"final\":739300},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":739284,\"final\":739299},\"value\":\"whatever\"}]}"
  |> json_erroneous_string()
}

// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------

//

// ----------------------------------------
// ----------- insert_new_current ---------
// ----------------------------------------

/// A very simple one - trying to edit the same info.
pub fn insert_new_current_1_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.insert_new_current(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> should.equal(
    NoChange(calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )),
  )
}

///   before
///   C 2025-02-25 --
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
///   after
///   C 2025-02-26 -- (new)
///   H 2025-02-25 - 2025-02-25 (moved to past)
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
pub fn insert_new_current_2_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: day.testing_iso8601("2025-02-25"),
    )

  existing
  |> calendrical.insert_new_current(
    with: "It's Moby now",
    starting_at: day.testing_iso8601("2025-02-26"),
  )
  |> should.equal(NonDestructive(
    existing
    |> calendrical.unsafe_insert_new_current(
      with: "It's Moby now",
      starting_at: day.testing_iso8601("2025-02-26"),
    ),
  ))
}

///   before
///   C 2025-02-25 --
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
///   after
///   C 2025-02-25 -- (replaced)
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
pub fn insert_new_current_3_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: day.testing_iso8601("2025-02-25"),
    )

  existing
  |> calendrical.insert_new_current(
    with: "It's Moby now",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> should.equal(WillOverwriteCurrent(
    existing
    |> calendrical.unsafe_insert_new_current(
      with: "It's Moby now",
      starting_at: day.testing_iso8601("2025-02-25"),
    ),
  ))
}

///   before
///   C 2025-02-25 --
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
///   after
///   (deleted)
///   C 2025-02-24 -- (new)
///   H 2025-02-19 - 2025-02-23 (truncated)
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
pub fn insert_new_current_4_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: day.testing_iso8601("2025-02-25"),
    )

  existing
  |> calendrical.insert_new_current(
    with: "It's Moby now",
    starting_at: day.testing_iso8601("2025-02-24"),
  )
  |> should.equal(WillOverwriteCurrentAndHistory(
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "It's Moby now",
      starting_at: day.testing_iso8601("2025-02-24"),
    ),
  ))
}

///   before
///   C 2025-02-25 --
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
///   after
///   (deleted)
///   (deleted)
///   C 2025-02-19 -- (new)
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
/// 
/// THIS IS TESTED AS AN UNWRAPPED LIST BECAUSE THE
/// INTERNAL STRUCTURE OF MAP MAKES IT HARD TO
/// PRODUCE RELIABLE TESTS SOMETIMES DEPENDING ON HOW
/// ITS BEEN SHUFFLED AND EDITED.
/// 
pub fn insert_new_current_5_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: day.testing_iso8601("2025-02-25"),
    )

  existing
  |> calendrical.insert_new_current(
    with: "It's Moby now",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unwrap_insertion_result()
  |> calendrical.to_list()
  |> should.equal(
    WillOverwriteCurrentAndHistory(
      calendrical.new(
        with: "whatever",
        starting_at: day.testing_iso8601("2025-02-02"),
        equality_fn: eq_func,
      )
      |> calendrical.unsafe_insert_new_current(
        with: "I'm listening to Battles",
        starting_at: day.testing_iso8601("2025-02-18"),
      )
      |> calendrical.unsafe_insert_new_current(
        with: "It's Moby now",
        starting_at: day.testing_iso8601("2025-02-19"),
      ),
    )
    |> calendrical.unwrap_insertion_result()
    |> calendrical.to_list(),
  )
}

///   before
///   C 2025-02-25 --
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
///   after
///   (deleted)
///   (deleted)
///   (deleted)
///   C 2025-02-16 -- (new)
///   H 2025-02-02 - 2025-02-15 (truncated)
/// 
pub fn insert_new_current_6_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: day.testing_iso8601("2025-02-25"),
    )

  existing
  |> calendrical.insert_new_current(
    with: "It's Moby now",
    starting_at: day.testing_iso8601("2025-02-16"),
  )
  |> should.equal(WillOverwriteCurrentAndHistory(
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "It's Moby now",
      starting_at: day.testing_iso8601("2025-02-16"),
    ),
  ))
}

///   before
///   C 2025-02-25 --
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
///   after
///   (deleted)
///   (deleted)
///   (deleted)
///   (deleted)
///   C 2025-02-02 -- (new)
/// 
pub fn insert_new_current_7_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: day.testing_iso8601("2025-02-25"),
    )

  existing
  |> calendrical.insert_new_current(
    with: "It's Moby now",
    starting_at: day.testing_iso8601("2025-02-02"),
  )
  |> should.equal(
    WillOverwriteCurrentAndHistory(calendrical.new(
      with: "It's Moby now",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )),
  )
}

///   before
///   C 2025-02-25 --
///   H 2025-02-19 - 2025-02-24
///   H 2025-02-18 - 2025-02-18
///   H 2025-02-02 - 2025-02-17
/// 
///   attempt (INVALID)
///   (deleted)
///   (deleted)
///   (deleted)
///   (deleted)
///   C 2025-01-01 -- (new, way before the others)
/// 
///   Will not execute and simply returns the existing calendrical.
/// 
pub fn insert_new_current_8_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: day.testing_iso8601("2025-02-25"),
    )

  existing
  |> calendrical.insert_new_current(
    with: "It's Moby now",
    starting_at: day.testing_iso8601("2025-01-01"),
  )
  |> should.equal(InvalidNewCurrentIsEarlierThanHistoricalStart(existing))
}

// ----------------------------------------
// ---------------- unsafe_insert_new_current ------------------
// ----------------------------------------

pub fn unsafe_insert_new_current_1_test() {
  calendrical.new(
    with: "test",
    starting_at: day.testing_iso8601("2025-01-04"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "test_change",
    starting_at: day.testing_iso8601("2025-01-05"),
  )
  |> calendrical.to_current_variant()
  |> cal_current_variant.unwrap()
  |> should.equal("test_change")
}

pub fn unsafe_insert_new_current_2_test() {
  calendrical.new(
    with: "test",
    starting_at: day.testing_iso8601("2025-01-04"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "test",
    starting_at: day.testing_iso8601("2025-01-04"),
  )
  |> calendrical.to_current_variant()
  |> cal_current_variant.unwrap()
  |> should.equal("test")
}

// ----------------------------------------
// ---------------- filter_by_day_interval -----------------
// ----------------------------------------

///      C 2025-02-25 --
///   x  H 2025-02-19 - 2025-02-24
///   x  H 2025-02-18 - 2025-02-18
///   x  H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn filter_by_day_interval_1_test() {
  let interval =
    day_interval.new(
      start: day.testing_iso8601("2025-02-15"),
      final: day.testing_iso8601("2025-02-23"),
    )
  // ----------------------------------------
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.slice_by_day_interval(interval)
  |> should.equal(
    CalSlice(interval:, current: None, history: [
      cal_past_variant.new(
        value: "Fort Greene Park",
        start: day.testing_iso8601("2025-02-19"),
        final: day.testing_iso8601("2025-02-24"),
      ),
      cal_past_variant.new(
        value: "I'm listening to Battles",
        start: day.testing_iso8601("2025-02-18"),
        final: day.testing_iso8601("2025-02-18"),
      ),
      cal_past_variant.new(
        value: "whatever",
        start: day.testing_iso8601("2025-02-02"),
        final: day.testing_iso8601("2025-02-17"),
      ),
    ]),
  )
}

///      C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///   x  H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn filter_by_day_interval_2_test() {
  let interval =
    day_interval.new(
      start: day.testing_iso8601("2025-02-18"),
      final: day.testing_iso8601("2025-02-18"),
    )
  // ----------------------------------------
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.slice_by_day_interval(interval)
  |> should.equal(
    CalSlice(interval:, current: None, history: [
      cal_past_variant.new(
        value: "I'm listening to Battles",
        start: day.testing_iso8601("2025-02-18"),
        final: day.testing_iso8601("2025-02-18"),
      ),
    ]),
  )
}

///   x  C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn filter_by_day_interval_3_test() {
  let interval =
    day_interval.new(
      start: day.testing_iso8601("2025-03-05"),
      final: day.testing_iso8601("2025-03-05"),
    )
  // ----------------------------------------
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.slice_by_day_interval(interval)
  |> should.equal(
    CalSlice(
      interval:,
      current: Some(cal_current_variant.new(
        value: "🎸🥁",
        start: day.testing_iso8601("2025-02-25"),
      )),
      history: [],
    ),
  )
}

///      C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
///   
///   x  ???? (nothing for now)
/// 
pub fn filter_by_day_interval_4_test() {
  let interval =
    day_interval.new(
      start: day.testing_iso8601("2025-01-05"),
      final: day.testing_iso8601("2025-01-05"),
    )
  // ----------------------------------------
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.slice_by_day_interval(interval)
  |> should.equal(CalSlice(interval:, current: None, history: []))
}

///   x  C 2025-02-25 --
///   x  H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn filter_by_day_interval_5_test() {
  let interval =
    day_interval.new(
      start: day.testing_iso8601("2025-02-20"),
      final: day.testing_iso8601("2025-03-05"),
    )
  // ----------------------------------------
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.slice_by_day_interval(interval)
  |> should.equal(
    CalSlice(
      interval:,
      current: Some(cal_current_variant.new(
        value: "🎸🥁",
        start: day.testing_iso8601("2025-02-25"),
      )),
      history: [
        cal_past_variant.new(
          value: "Fort Greene Park",
          start: day.testing_iso8601("2025-02-19"),
          final: day.testing_iso8601("2025-02-24"),
        ),
      ],
    ),
  )
}

// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------

///   (way in the future)
///   x  C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn get_variant_by_day_1_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.get_variant_by_day(day.testing_iso8601("2032-02-20"))
  |> should.equal(
    Ok(
      Current(cal_current_variant.new(
        value: "🎸🥁",
        start: day.testing_iso8601("2025-02-25"),
      )),
    ),
  )
}

///   (way in the future)
///      C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
///   x  (just before, fail)
/// 
/// 
pub fn get_variant_by_day_2_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.get_variant_by_day(day.testing_iso8601("2025-02-01"))
  |> should.equal(Error(Nil))
}

///   (way in the future)
///      C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///   x  H 2025-02-02 - 2025-02-17
///     (just at the start)
/// 
/// 
pub fn get_variant_by_day_3_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.get_variant_by_day(day.testing_iso8601("2025-02-02"))
  |> should.equal(
    Ok(
      Past(cal_past_variant.new(
        value: "whatever",
        start: day.testing_iso8601("2025-02-02"),
        final: day.testing_iso8601("2025-02-17"),
      )),
    ),
  )
}

///   (just on the start day)
///   x  C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
///     (just at the start)
/// 
/// 
pub fn get_variant_by_day_4_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.get_variant_by_day(day.testing_iso8601("2025-02-25"))
  |> should.equal(
    Ok(
      Current(cal_current_variant.new(
        value: "🎸🥁",
        start: day.testing_iso8601("2025-02-25"),
      )),
    ),
  )
}

///   (just on the start day)
///      C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///   x  H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
///     (just at the start)
/// 
/// 
pub fn get_variant_by_day_5_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.get_variant_by_day(day.testing_iso8601("2025-02-18"))
  |> should.equal(
    Ok(
      Past(cal_past_variant.new(
        value: "I'm listening to Battles",
        start: day.testing_iso8601("2025-02-18"),
        final: day.testing_iso8601("2025-02-18"),
      )),
    ),
  )
}

///   (just on the start day)
///      C 2025-02-25 --
///   x  H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
///     (just at the start)
/// 
/// 
pub fn get_variant_by_day_6_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.testing_iso8601("2025-02-02"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.testing_iso8601("2025-02-18"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.testing_iso8601("2025-02-19"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.testing_iso8601("2025-02-25"),
  )
  |> calendrical.get_variant_by_day(day.testing_iso8601("2025-02-20"))
  |> should.equal(
    Ok(
      Past(cal_past_variant.new(
        value: "Fort Greene Park",
        start: day.testing_iso8601("2025-02-19"),
        final: day.testing_iso8601("2025-02-24"),
      )),
    ),
  )
}

// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------

fn init() -> Calendrical(String) {
  calendrical.new(
    with: "test_value_1",
    starting_at: day.testing_iso8601("2025-01-04"),
    equality_fn: eq_func,
  )
}

fn init_2() -> Calendrical(String) {
  init()
  |> calendrical.unsafe_insert_new_current(
    with: "test_value_2",
    starting_at: day.testing_iso8601("2025-01-05"),
  )
}

fn init_3() -> Calendrical(String) {
  init_2()
  |> calendrical.unsafe_insert_new_current(
    with: "test_value_3",
    starting_at: day.testing_iso8601("2025-01-06"),
  )
}

// ----------------------------------------
// ---------------- to_current -----------------
// ----------------------------------------

pub fn to_current_variant_1_item_test() {
  init()
  |> calendrical.to_current_variant()
  |> cal_current_variant.unwrap()
  |> should.equal("test_value_1")
}

pub fn to_current_variant_2_items_test() {
  init_2()
  |> calendrical.to_current_variant()
  |> cal_current_variant.unwrap()
  |> should.equal("test_value_2")
}

pub fn to_current_variant_3_items_test() {
  init_3()
  |> calendrical.to_current_variant()
  |> cal_current_variant.unwrap()
  |> should.equal("test_value_3")
}

// ----------------------------------------
// ---------------- to_history_list-----------------
// ----------------------------------------

pub fn changeable_to_history_list_1_item_test() {
  init()
  |> calendrical.to_history_list()
  |> list.map(cal_past_variant.unwrap)
  |> should.equal([])
}

pub fn changeable_to_history_list_2_items_test() {
  init_2()
  |> calendrical.to_history_list()
  |> list.map(cal_past_variant.unwrap)
  |> should.equal(["test_value_1"])
}

pub fn changeable_to_history_list_3_items_test() {
  init_3()
  |> calendrical.to_history_list()
  |> list.map(cal_past_variant.unwrap)
  |> should.equal(["test_value_2", "test_value_1"])
}

// ----------------------------------------
// --------- to_latest_edit_day ----------
// ----------------------------------------

pub fn to_latest_edit_day_1_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2025-02-02"),
      equality_fn: eq_func,
    )
    |> calendrical.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: day.testing_iso8601("2025-02-18"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: day.testing_iso8601("2025-02-19"),
    )
    |> calendrical.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: day.testing_iso8601("2025-02-25"),
    )

  existing
  |> calendrical.to_latest_edit_day()
  |> should.equal(day.testing_iso8601("2025-02-25"))
}

pub fn to_latest_edit_day_2_test() {
  let existing =
    calendrical.new(
      with: "whatever",
      starting_at: day.testing_iso8601("2026-03-05"),
      equality_fn: eq_func,
    )

  existing
  |> calendrical.to_latest_edit_day()
  |> should.equal(day.testing_iso8601("2026-03-05"))
}

// ----------------------------------------
// ---------- has_history ------------
// ----------------------------------------

pub fn changeable_has_history_false_test() {
  init()
  |> calendrical.has_history()
  |> should.equal(False)
}

pub fn changeable_has_history_true_2_test() {
  init_2()
  |> calendrical.has_history()
  |> should.equal(True)
}

pub fn changeable_has_history_true_3_test() {
  init_3()
  |> calendrical.has_history()
  |> should.equal(True)
}
