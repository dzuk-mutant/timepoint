import day
import day_interval
import gleeunit/should
import versioning/calendrical
import versioning/calendrical/cal_any_variant.{Current, Past}
import versioning/calendrical/cal_current_variant
import versioning/calendrical/cal_past_variant
import versioning/calendrical/cal_slice

fn eq_func(a: String, b: String) -> Bool {
  a == b
}

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ------------------ to_any_list --------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

pub fn to_any_list_1_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2024-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- the actual func
  |> cal_slice.to_any_list()
  |> should.equal([
    Current(cal_current_variant.new(
      value: "🎸🥁",
      start: day.from_gtempo_literal("2024-11-25"),
    )),
    Past(cal_past_variant.new(
      value: "Fort Greene Park",
      start: day.from_gtempo_literal("2024-09-01"),
      final: day.from_gtempo_literal("2024-11-24"),
    )),
    Past(cal_past_variant.new(
      value: "I'm listening to Battles",
      start: day.from_gtempo_literal("2024-08-22"),
      final: day.from_gtempo_literal("2024-08-31"),
    )),
    Past(cal_past_variant.new(
      value: "whatever",
      start: day.from_gtempo_literal("2024-07-16"),
      final: day.from_gtempo_literal("2024-08-21"),
    )),
  ])
}

pub fn to_any_list_2_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2024-07-01"),
    final: day.from_gtempo_literal("2024-08-05"),
  ))
  // ---- the actual func

  |> cal_slice.to_any_list()
  |> should.equal([
    Past(cal_past_variant.new(
      value: "whatever",
      start: day.from_gtempo_literal("2024-07-16"),
      final: day.from_gtempo_literal("2024-08-21"),
    )),
  ])
}

pub fn to_any_list_3_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- the actual func
  |> cal_slice.to_any_list()
  |> should.equal([
    Current(cal_current_variant.new(
      value: "🎸🥁",
      start: day.from_gtempo_literal("2024-11-25"),
    )),
  ])
}

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// --------------------- is_empty --------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

/// a double-sliced Calendrical that results in an empty slice.
pub fn is_empty_1_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2024-07-01"),
    final: day.from_gtempo_literal("2024-08-05"),
  ))
  // ---- slice 2
  |> cal_slice.chop(day_interval.new(
    start: day.from_gtempo_literal("2025-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- the actual func

  |> cal_slice.is_empty()
  |> should.equal(True)
}

/// A single-pass slice that does contain stuff.
pub fn is_empty_2_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2025-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- the actual func
  |> cal_slice.is_empty()
  |> should.equal(False)
}

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// --------------------- filter ----------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

/// Just a smaller slice of the original slice.
pub fn filter_1_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2024-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- slice 2
  |> cal_slice.chop(day_interval.new(
    start: day.from_gtempo_literal("2024-08-30"),
    final: day.from_gtempo_literal("2024-11-13"),
  ))
  // ---- the actual func
  |> cal_slice.to_any_list()
  |> should.equal([
    Past(cal_past_variant.new(
      value: "Fort Greene Park",
      start: day.from_gtempo_literal("2024-09-01"),
      final: day.from_gtempo_literal("2024-11-24"),
    )),
    Past(cal_past_variant.new(
      value: "I'm listening to Battles",
      start: day.from_gtempo_literal("2024-08-22"),
      final: day.from_gtempo_literal("2024-08-31"),
    )),
  ])
}

/// A filter that goes out of bounds and results in an empty slice.
pub fn filter_2_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2024-07-01"),
    final: day.from_gtempo_literal("2024-08-05"),
  ))
  // ---- slice 2
  |> cal_slice.chop(day_interval.new(
    start: day.from_gtempo_literal("2025-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- the actual func

  |> cal_slice.to_any_list()
  |> should.equal([])
}

// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// -------------- get_variant_by_day ----------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------
// ---------------------------------------------------

// get something in the past.
pub fn get_variant_by_day_1_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice all
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2024-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- the actual func
  |> cal_slice.get_variant_by_day(day.from_gtempo_literal("2024-07-17"))
  |> should.equal(
    Past(cal_past_variant.new(
      value: "whatever",
      start: day.from_gtempo_literal("2024-07-16"),
      final: day.from_gtempo_literal("2024-08-21"),
    ))
    |> Ok,
  )
}

// get the current.
pub fn get_variant_by_day_2_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice all
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2024-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- the actual func
  |> cal_slice.get_variant_by_day(day.from_gtempo_literal("2024-12-01"))
  |> should.equal(
    Current(cal_current_variant.new(
      value: "🎸🥁",
      start: day.from_gtempo_literal("2024-11-25"),
    ))
    |> Ok,
  )
}

// get the current.
pub fn get_variant_by_day_3_test() {
  calendrical.new(
    with: "whatever",
    starting_at: day.from_gtempo_literal("2024-07-16"),
    equality_fn: eq_func,
  )
  |> calendrical.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: day.from_gtempo_literal("2024-08-22"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: day.from_gtempo_literal("2024-09-01"),
  )
  |> calendrical.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: day.from_gtempo_literal("2024-11-25"),
  )
  // ---- slice all
  |> calendrical.slice_by_day_interval(day_interval.new(
    start: day.from_gtempo_literal("2024-07-01"),
    final: day.from_gtempo_literal("2025-08-05"),
  ))
  // ---- the actual func
  |> cal_slice.get_variant_by_day(day.from_gtempo_literal("2024-09-02"))
  |> should.equal(
    Past(cal_past_variant.new(
      value: "Fort Greene Park",
      start: day.from_gtempo_literal("2024-09-01"),
      final: day.from_gtempo_literal("2024-11-24"),
    ))
    |> Ok,
  )
}
