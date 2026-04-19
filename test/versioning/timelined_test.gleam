import versioning/timelined.{
  type Timelined, InvalidNewCurrentIsEarlierThanHistoricalStart, NoChange,
  NonDestructive, WillOverwriteCurrent, WillOverwriteCurrentAndHistory,
}
import versioning/timelined/tl_current_variant
import versioning/timelined/tl_past_variant
import versioning/timelined/tl_slice_by_day

import day
import day_interval
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleeunit/should
import moment
import moment_interval
import versioning/timelined/tl_slice_by_moment

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

//

// ----------------------------------------
// ------------------ JSON ----------------
// ----------------------------------------
fn json_o(input: Timelined(String), expected expected: String) {
  input
  |> timelined.to_json(value_encoder: json.string)
  |> json.to_string()
  |> should.equal(expected)
}

fn json_io(input_and_expected_output: Timelined(String)) {
  let decoder =
    timelined.decoder(
      default_value: "oops",
      value_decoder: decode.string,
      equality_fn: eq_func,
    )
  input_and_expected_output
  |> timelined.to_json(value_encoder: json.string)
  |> json.to_string()
  |> json.parse(using: decoder)
  |> result.map(timelined.to_list)
  |> should.equal(Ok(input_and_expected_output |> timelined.to_list))
}

fn json_correct_decode(string: String) {
  let decoder =
    timelined.decoder(
      default_value: "oops",
      value_decoder: decode.string,
      equality_fn: fn(a, b) { a == b },
    )
  string
  |> json.parse(using: decoder)
  |> result.is_error()
  |> should.equal(False)
}

fn json_erroneous_decode(string: String) {
  let decoder =
    timelined.decoder(
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
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
}

pub fn json_o_1_test() {
  example_1()
  |> json_o(
    expected: "{\"current\":{\"start\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0},\"value\":\"🎸🥁\"},\"history_start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"history\":[{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0}},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0}},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0}},\"value\":\"whatever\"}]}",
  )
}

pub fn json_io_1_test() {
  example_1()
  |> json_io
}

fn example_2() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
}

pub fn json_o_2_test() {
  example_2()
  |> json_o(
    expected: "{\"current\":{\"start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"value\":\"whatever\"},\"history_start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"history\":[]}",
  )
}

pub fn json_io_2_test() {
  example_2()
  |> json_io
}

/// Non-contiguous history
pub fn json_erroneous_decode_1_test() {
  "{\"current\":{\"start\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0},\"value\":\"🎸🥁\"},\"history_start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"history\":[{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0}},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0}},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739837800,\"unix_ns\":0},\"offset\":0}},\"value\":\"whatever\"}]}"
  |> json_erroneous_decode()
}

/// Non-contiguous history
pub fn json_erroneous_decode_2_test() {
  "{\"current\":{\"start\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0},\"value\":\"🎸🥁\"},\"history_start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"history\":[{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739921200,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0}},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0}},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0}},\"value\":\"whatever\"}]}"
  |> json_erroneous_decode()
}

/// I just go crazy with the history order.
pub fn json_erroneous_decode_3_test() {
  "{\"current\":{\"start\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0},\"value\":\"🎸🥁\"},\"history_start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"history\":[{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0}},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739830800,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1749923200,\"unix_ns\":0},\"offset\":0}},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0}},\"value\":\"whatever\"}]}"
  |> json_erroneous_decode()
}

/// Current is not contiguous with history.
pub fn json_erroneous_decode_4_test() {
  "{\"current\":{\"start\":{\"timestamp\":{\"unix_s\":1740441800,\"unix_ns\":0},\"offset\":0},\"value\":\"🎸🥁\"},\"history_start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"history\":[{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0}},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0}},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0}},\"value\":\"whatever\"}]}"
  |> json_erroneous_decode()
}

/// Start date doesn't match first variant.
pub fn json_erroneous_decode_5_test() {
  "{\"current\":{\"start\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0},\"value\":\"🎸🥁\"},\"history_start\":{\"timestamp\":{\"unix_s\":1738444400,\"unix_ns\":0},\"offset\":0},\"history\":[{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1740441600,\"unix_ns\":0},\"offset\":0}},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739923200,\"unix_ns\":0},\"offset\":0}},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1738454400,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739836800,\"unix_ns\":0},\"offset\":0}},\"value\":\"whatever\"}]}"
  |> json_erroneous_decode()
}

pub fn json_correct_decode_1_test() {
  "{\"current\":{\"start\":{\"timestamp\":{\"unix_s\":1740441600000,\"unix_ns\":0},\"offset\":0},\"value\":\"🎸🥁\"},\"history_start\":{\"timestamp\":{\"unix_s\":1738454400000,\"unix_ns\":0},\"offset\":0},\"history\":[{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739923200000,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1740441600000,\"unix_ns\":0},\"offset\":0}},\"value\":\"Fort Greene Park\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1739836800000,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739923200000,\"unix_ns\":0},\"offset\":0}},\"value\":\"I'm listening to Battles\"},{\"interval\":{\"start\":{\"timestamp\":{\"unix_s\":1738454400000,\"unix_ns\":0},\"offset\":0},\"end_excluding\":{\"timestamp\":{\"unix_s\":1739836800000,\"unix_ns\":0},\"offset\":0}},\"value\":\"whatever\"}]}"
  |> json_correct_decode()
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
// ----------- insert_new_current ---------
// ----------------------------------------

/// A very simple one - trying to edit the same info.
pub fn insert_new_current_1_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.insert_new_current(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> should.equal(
    NoChange(timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
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
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
    )

  existing
  |> timelined.insert_new_current(
    with: "It's Moby now",
    starting_at: moment.from_gtempo_literal("2025-02-26T00:00:00.000Z"),
  )
  |> should.equal(NonDestructive(
    existing
    |> timelined.unsafe_insert_new_current(
      with: "It's Moby now",
      starting_at: moment.from_gtempo_literal("2025-02-26T00:00:00.000Z"),
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
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
    )

  existing
  |> timelined.insert_new_current(
    with: "It's Moby now",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> should.equal(WillOverwriteCurrent(
    existing
    |> timelined.unsafe_insert_new_current(
      with: "It's Moby now",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
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
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
    )

  existing
  |> timelined.insert_new_current(
    with: "It's Moby now",
    starting_at: moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"),
  )
  |> should.equal(WillOverwriteCurrentAndHistory(
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "It's Moby now",
      starting_at: moment.from_gtempo_literal("2025-02-24T00:00:00.000Z"),
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
/// THIS IS TESTED AS AN UNWRAPPED LIST BECAUSE THE
/// INTERNAL STRUCTURE OF MAP MAKES IT HARD TO
/// PRODUCE RELIABLE TESTS SOMETIMES DEPENDING ON HOW
/// ITS BEEN SHUFFLED AND EDITED.
/// 
pub fn insert_new_current_5_test() {
  let existing =
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
    )

  existing
  |> timelined.insert_new_current(
    with: "It's Moby now",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unwrap_insertion_result()
  |> timelined.to_list()
  |> should.equal(
    WillOverwriteCurrentAndHistory(
      timelined.new(
        with: "whatever",
        starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
        equality_fn: eq_func,
      )
      |> timelined.unsafe_insert_new_current(
        with: "I'm listening to Battles",
        starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
      )
      |> timelined.unsafe_insert_new_current(
        with: "It's Moby now",
        starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
      ),
    )
    |> timelined.unwrap_insertion_result()
    |> timelined.to_list(),
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
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
    )

  existing
  |> timelined.insert_new_current(
    with: "It's Moby now",
    starting_at: moment.from_gtempo_literal("2025-02-16T00:00:00.000Z"),
  )
  |> should.equal(WillOverwriteCurrentAndHistory(
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "It's Moby now",
      starting_at: moment.from_gtempo_literal("2025-02-16T00:00:00.000Z"),
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
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
    )

  existing
  |> timelined.insert_new_current(
    with: "It's Moby now",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
  )
  |> should.equal(
    WillOverwriteCurrentAndHistory(timelined.new(
      with: "It's Moby now",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
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
///   Will not execute and simply returns the existing timelined.
/// 
pub fn insert_new_current_8_test() {
  let existing =
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
    )

  existing
  |> timelined.insert_new_current(
    with: "It's Moby now",
    starting_at: moment.from_gtempo_literal("2025-01-01T00:00:00.000Z"),
  )
  |> should.equal(InvalidNewCurrentIsEarlierThanHistoricalStart(existing))
}

// ----------------------------------------
// ---------------- unsafe_insert_new_current ------------------
// ----------------------------------------

pub fn unsafe_insert_new_current_1_test() {
  timelined.new(
    with: "test",
    starting_at: moment.from_gtempo_literal("2025-01-04T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "test_change",
    starting_at: moment.from_gtempo_literal("2025-01-05T00:00:00.000Z"),
  )
  |> timelined.to_current_variant()
  |> tl_current_variant.unwrap()
  |> should.equal("test_change")
}

pub fn unsafe_insert_new_current_2_test() {
  timelined.new(
    with: "test",
    starting_at: moment.from_gtempo_literal("2025-01-04T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "test",
    starting_at: moment.from_gtempo_literal("2025-01-04T00:00:00.000Z"),
  )
  |> timelined.to_current_variant()
  |> tl_current_variant.unwrap()
  |> should.equal("test")
}

// ----------------------------------------
// ---------------- slice_by_moment_interval -----------------
// ----------------------------------------

///      C 2025-02-25 --
///   x  H 2025-02-19 - 2025-02-24
///   x  H 2025-02-18 - 2025-02-18
///   x  H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn slice_by_moment_interval_1_test() {
  let interval =
    moment_interval.new(
      start: moment.from_gtempo_literal("2025-02-15T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2025-02-23T00:00:00.000Z"),
    )
  // --------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_moment_interval(interval)
  |> should.equal(
    tl_slice_by_moment.new(interval:, current: None, history: [
      tl_past_variant.new(
        value: "Fort Greene Park",
        start: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
      ),
      tl_past_variant.new(
        value: "I'm listening to Battles",
        start: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
      ),
      tl_past_variant.new(
        value: "whatever",
        start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
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
pub fn slice_by_moment_interval_2_test() {
  let interval =
    moment_interval.new(
      start: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2025-02-18T23:59:59.999Z"),
    )
  // --------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_moment_interval(interval)
  |> should.equal(
    tl_slice_by_moment.new(interval:, current: None, history: [
      tl_past_variant.new(
        value: "I'm listening to Battles",
        start: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
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
pub fn slice_by_moment_interval_3_test() {
  let interval =
    moment_interval.new(
      start: moment.from_gtempo_literal("2025-03-05T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2025-03-05T00:00:00.000Z"),
    )
  // --------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_moment_interval(interval)
  |> should.equal(
    tl_slice_by_moment.new(
      interval:,
      current: Some(tl_current_variant.new(
        value: "🎸🥁",
        start: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
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
pub fn slice_by_moment_interval_4_test() {
  let interval =
    moment_interval.new(
      start: moment.from_gtempo_literal("2025-01-05T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2025-01-05T00:00:00.000Z"),
    )
  // -----------------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_moment_interval(interval)
  |> should.equal(tl_slice_by_moment.new(interval:, current: None, history: []))
}

///   x  C 2025-02-25 --
///   x  H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn slice_by_moment_interval_5_test() {
  let interval =
    moment_interval.new(
      start: moment.from_gtempo_literal("2025-02-20T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2025-03-05T00:00:00.000Z"),
    )
  // -----------------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_moment_interval(interval)
  |> should.equal(
    tl_slice_by_moment.new(
      interval:,
      current: Some(tl_current_variant.new(
        value: "🎸🥁",
        start: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
      )),
      history: [
        tl_past_variant.new(
          value: "Fort Greene Park",
          start: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
          end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
        ),
      ],
    ),
  )
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
      start: day.from_gtempo_literal("2025-02-15"),
      final: day.from_gtempo_literal("2025-02-23"),
    )
  // -----------------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_day_interval(interval)
  |> should.equal(
    tl_slice_by_day.new(interval:, current: None, history: [
      tl_past_variant.new(
        value: "Fort Greene Park",
        start: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
      ),
      tl_past_variant.new(
        value: "I'm listening to Battles",
        start: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
      ),
      tl_past_variant.new(
        value: "whatever",
        start: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
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
      start: day.from_gtempo_literal("2025-02-18"),
      final: day.from_gtempo_literal("2025-02-18"),
    )
  // -----------------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_day_interval(interval)
  |> should.equal(
    tl_slice_by_day.new(interval:, current: None, history: [
      tl_past_variant.new(
        value: "I'm listening to Battles",
        start: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
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
      start: day.from_gtempo_literal("2025-03-05"),
      final: day.from_gtempo_literal("2025-03-05"),
    )
  //---------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_day_interval(interval)
  |> should.equal(
    tl_slice_by_day.new(
      interval:,
      current: Some(tl_current_variant.new(
        value: "🎸🥁",
        start: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
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
      start: day.from_gtempo_literal("2025-01-05"),
      final: day.from_gtempo_literal("2025-01-05"),
    )
  // -----------------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_day_interval(interval)
  |> should.equal(tl_slice_by_day.new(interval:, current: None, history: []))
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
      start: day.from_gtempo_literal("2025-02-20"),
      final: day.from_gtempo_literal("2025-03-05"),
    )
  // -----------------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_day_interval(interval)
  |> should.equal(
    tl_slice_by_day.new(
      interval:,
      current: Some(tl_current_variant.new(
        value: "🎸🥁",
        start: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
      )),
      history: [
        tl_past_variant.new(
          value: "Fort Greene Park",
          start: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
          end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
        ),
      ],
    ),
  )
}

///   x  C 2025-02-25 --
///   x  H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn filter_by_day_interval_t1_test() {
  let interval =
    day_interval.new(
      start: day.from_gtempo_literal("2025-02-20"),
      final: day.from_gtempo_literal("2025-02-25"),
    )
  // -----------------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T23:59:59.999Z"),
  )
  |> timelined.slice_by_day_interval(interval)
  |> should.equal(
    tl_slice_by_day.new(
      interval:,
      current: Some(tl_current_variant.new(
        value: "🎸🥁",
        start: moment.from_gtempo_literal("2025-02-25T23:59:59.999Z"),
      )),
      history: [
        tl_past_variant.new(
          value: "Fort Greene Park",
          start: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
          end_excluding: moment.from_gtempo_literal("2025-02-25T23:59:59.999Z"),
        ),
      ],
    ),
  )
}

///      C 2025-02-25 --
///   x  H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn filter_by_day_interval_t2_test() {
  let interval =
    day_interval.new(
      start: day.from_gtempo_literal("2025-02-20"),
      final: day.from_gtempo_literal("2025-02-24"),
    )
  // -----------------------------------------------------
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.slice_by_day_interval(interval)
  |> should.equal(
    tl_slice_by_day.new(interval:, current: None, history: [
      tl_past_variant.new(
        value: "Fort Greene Park",
        start: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
        end_excluding: moment.from_gtempo_literal(
          "2025-02-25T00:00:00.000+00:00",
        ),
      ),
    ]),
  )
}

// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ---------- filter_by_day --------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------
// ----------------------------------------

///      C 2025-02-25 --
///   x  H 2025-02-19 - 2025-02-24
///      H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn filter_by_day_1_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.filter_by_day(day.from_gtempo_literal("2025-02-20"))
  |> should.equal(
    tl_slice_by_day.new(
      interval: day_interval.new(
        start: day.from_gtempo_literal("2025-02-20"),
        final: day.from_gtempo_literal("2025-02-20"),
      ),
      current: None,
      history: [
        tl_past_variant.new(
          value: "Fort Greene Park",
          start: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
          end_excluding: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
        ),
      ],
    ),
  )
}

///      C 2025-02-25 --
///      H 2025-02-19 - 2025-02-24
///   x  H 2025-02-18 - 2025-02-18
///      H 2025-02-02 - 2025-02-17
/// 
/// 
/// 
pub fn filter_by_day_2_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
  )
  |> timelined.filter_by_day(day.from_gtempo_literal("2025-02-18"))
  |> should.equal(
    tl_slice_by_day.new(
      interval: day_interval.new(
        start: day.from_gtempo_literal("2025-02-18"),
        final: day.from_gtempo_literal("2025-02-18"),
      ),
      current: None,
      history: [
        tl_past_variant.new(
          value: "I'm listening to Battles",
          start: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
          end_excluding: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
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

fn init() -> Timelined(String) {
  timelined.new(
    with: "test_value_1",
    starting_at: moment.from_gtempo_literal("2025-01-04T00:00:00.000Z"),
    equality_fn: eq_func,
  )
}

fn init_2() -> Timelined(String) {
  init()
  |> timelined.unsafe_insert_new_current(
    with: "test_value_2",
    starting_at: moment.from_gtempo_literal("2025-01-05T00:00:00.000Z"),
  )
}

fn init_3() -> Timelined(String) {
  init_2()
  |> timelined.unsafe_insert_new_current(
    with: "test_value_3",
    starting_at: moment.from_gtempo_literal("2025-01-06T00:00:00.000Z"),
  )
}

// ----------------------------------------
// ---------------- to_current -----------------
// ----------------------------------------

pub fn to_current_variant_1_item_test() {
  init()
  |> timelined.to_current_variant()
  |> tl_current_variant.unwrap()
  |> should.equal("test_value_1")
}

pub fn to_current_variant_2_items_test() {
  init_2()
  |> timelined.to_current_variant()
  |> tl_current_variant.unwrap()
  |> should.equal("test_value_2")
}

pub fn to_current_variant_3_items_test() {
  init_3()
  |> timelined.to_current_variant()
  |> tl_current_variant.unwrap()
  |> should.equal("test_value_3")
}

// ----------------------------------------
// ---------------- to_history_list-----------------
// ----------------------------------------

pub fn changeable_to_history_list_1_item_test() {
  init()
  |> timelined.to_history_list()
  |> list.map(tl_past_variant.unwrap)
  |> should.equal([])
}

pub fn changeable_to_history_list_2_items_test() {
  init_2()
  |> timelined.to_history_list()
  |> list.map(tl_past_variant.unwrap)
  |> should.equal(["test_value_1"])
}

pub fn changeable_to_history_list_3_items_test() {
  init_3()
  |> timelined.to_history_list()
  |> list.map(tl_past_variant.unwrap)
  |> should.equal(["test_value_2", "test_value_1"])
}

// ----------------------------------------
// --------- to_latest_edit_moment ----------
// ----------------------------------------

pub fn to_latest_edit_moment_1_test() {
  let existing =
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )
    |> timelined.unsafe_insert_new_current(
      with: "I'm listening to Battles",
      starting_at: moment.from_gtempo_literal("2025-02-18T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "Fort Greene Park",
      starting_at: moment.from_gtempo_literal("2025-02-19T00:00:00.000Z"),
    )
    |> timelined.unsafe_insert_new_current(
      with: "🎸🥁",
      starting_at: moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"),
    )

  existing
  |> timelined.to_latest_edit_moment
  |> should.equal(moment.from_gtempo_literal("2025-02-25T00:00:00.000Z"))
}

pub fn to_latest_edit_moment_2_test() {
  let existing =
    timelined.new(
      with: "whatever",
      starting_at: moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"),
      equality_fn: eq_func,
    )

  existing
  |> timelined.to_latest_edit_moment
  |> should.equal(moment.from_gtempo_literal("2025-02-02T00:00:00.000Z"))
}

// ----------------------------------------
// ---------- has_history ------------
// ----------------------------------------

pub fn changeable_has_history_false_test() {
  init()
  |> timelined.has_history()
  |> should.equal(False)
}

pub fn changeable_has_history_true_2_test() {
  init_2()
  |> timelined.has_history()
  |> should.equal(True)
}

pub fn changeable_has_history_true_3_test() {
  init_3()
  |> timelined.has_history()
  |> should.equal(True)
}
