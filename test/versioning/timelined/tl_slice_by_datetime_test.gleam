import gleeunit/should
import interval/moment_interval
import moment
import versioning/timelined
import versioning/timelined/tl_any_variant.{Current, Past}
import versioning/timelined/tl_current_variant
import versioning/timelined/tl_past_variant
import versioning/timelined/tl_slice_by_moment

fn eq_func(a: String, b: String) -> Bool {
  a == b
}

pub fn by_moment_medley_1_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
  )
  // ---- slice
  |> timelined.slice_by_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2024-07-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-08-05T00:00:00.000Z"),
  ))
  // ---- the actual func
  |> tl_slice_by_moment.to_any_list()
  |> should.equal([
    Current(tl_current_variant.new(
      value: "🎸🥁",
      start: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
    )),
    Past(tl_past_variant.new(
      value: "Fort Greene Park",
      start: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
    )),
    Past(tl_past_variant.new(
      value: "I'm listening to Battles",
      start: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
    )),
    Past(tl_past_variant.new(
      value: "whatever",
      start: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
    )),
  ])
}

pub fn by_moment_medley_2_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
  )
  // ---- slice
  |> timelined.slice_by_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2024-07-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2024-08-05T00:00:00.000Z"),
  ))
  // ---- the actual func
  |> tl_slice_by_moment.to_any_list()
  |> should.equal([
    Past(tl_past_variant.new(
      value: "whatever",
      start: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
    )),
  ])
}

pub fn by_moment_medley_3_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
  )
  // ---- slice
  |> timelined.slice_by_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2025-07-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-08-05T00:00:00.000Z"),
  ))
  // ---- the actual func
  |> tl_slice_by_moment.to_any_list()
  |> should.equal([
    Current(tl_current_variant.new(
      value: "🎸🥁",
      start: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
    )),
  ])
}

/// Double slice resulting in empty slice
pub fn by_moment_medley_4_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
  )
  // ---- slice
  |> timelined.slice_by_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2024-07-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-08-05T00:00:00.000Z"),
  ))
  |> tl_slice_by_moment.chop(moment_interval.new(
    start: moment.from_gtempo_literal("2024-08-30T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2024-10-30T00:00:00.000Z"),
  ))
  // ---- the actual func
  |> tl_slice_by_moment.to_any_list()
  |> should.equal([
    Past(tl_past_variant.new(
      value: "Fort Greene Park",
      start: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
    )),
    Past(tl_past_variant.new(
      value: "I'm listening to Battles",
      start: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
    )),
  ])
}

/// double slice resulting in an empty slice
pub fn by_moment_medley_5_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
  )
  // ---- slice
  |> timelined.slice_by_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2024-07-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2024-08-05T00:00:00.000Z"),
  ))
  |> tl_slice_by_moment.chop(moment_interval.new(
    start: moment.from_gtempo_literal("2010-08-30T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2010-10-30T00:00:00.000Z"),
  ))
  // ---- the actual func
  |> tl_slice_by_moment.to_any_list()
  |> should.equal([])
}

/// Double slice resulting in a non-empty slice, tested as non-empty.
pub fn by_moment_medley_6_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
  )
  // ---- slice
  |> timelined.slice_by_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2024-07-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2025-08-05T00:00:00.000Z"),
  ))
  |> tl_slice_by_moment.chop(moment_interval.new(
    start: moment.from_gtempo_literal("2024-08-30T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2024-10-30T00:00:00.000Z"),
  ))
  // ---- the actual func
  |> tl_slice_by_moment.is_empty()
  |> should.equal(False)
}

/// double slice resulting in an empty slice, tested as empty.
pub fn by_moment_medley_7_test() {
  timelined.new(
    with: "whatever",
    starting_at: moment.from_gtempo_literal("2024-07-16T00:00:00.000Z"),
    equality_fn: eq_func,
  )
  |> timelined.unsafe_insert_new_current(
    with: "I'm listening to Battles",
    starting_at: moment.from_gtempo_literal("2024-08-22T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "Fort Greene Park",
    starting_at: moment.from_gtempo_literal("2024-09-01T00:00:00.000Z"),
  )
  |> timelined.unsafe_insert_new_current(
    with: "🎸🥁",
    starting_at: moment.from_gtempo_literal("2024-11-25T00:00:00.000Z"),
  )
  // ---- slice
  |> timelined.slice_by_moment_interval(moment_interval.new(
    start: moment.from_gtempo_literal("2024-07-01T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2024-08-05T00:00:00.000Z"),
  ))
  |> tl_slice_by_moment.chop(moment_interval.new(
    start: moment.from_gtempo_literal("2010-08-30T00:00:00.000Z"),
    end_excluding: moment.from_gtempo_literal("2010-10-30T00:00:00.000Z"),
  ))
  // ---- the actual func
  |> tl_slice_by_moment.is_empty()
  |> should.equal(True)
}
