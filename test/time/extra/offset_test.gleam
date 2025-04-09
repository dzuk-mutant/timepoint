import gleeunit/should
import tempo/offset
import time/extra/offset as extra_offset

// --------------------------------------------
// --------------------------------------------
// ---------------- QUERY ---------------------
// --------------------------------------------
// --------------------------------------------

pub fn is_equal_1_test() {
  offset.literal("+00:00")
  |> extra_offset.is_equal(to: offset.literal("+00:00"))
  |> should.equal(True)
}

pub fn is_equal_2_test() {
  offset.literal("+00:00")
  |> extra_offset.is_equal(to: offset.literal("+10:00"))
  |> should.equal(False)
}

pub fn is_equal_3_test() {
  offset.literal("+00:00")
  |> extra_offset.is_equal(to: offset.literal("+00:30"))
  |> should.equal(False)
}
