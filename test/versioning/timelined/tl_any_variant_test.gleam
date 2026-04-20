import gleeunit/should
import moment
import versioning/timelined/tl_any_variant.{Current, Past}
import versioning/timelined/tl_current_variant
import versioning/timelined/tl_past_variant

pub fn unwrap_current_variant_test() {
  tl_current_variant.new(
    value: "boop",
    start: moment.testing_rfc3339("2025-02-27T00:00:00.000Z"),
  )
  |> Current
  |> tl_any_variant.unwrap()
  |> should.equal("boop")
}

pub fn unwrap_past_variant_test() {
  tl_past_variant.new(
    value: "boop",
    start: moment.testing_rfc3339("2025-02-27T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2025-02-28T00:00:00.000Z"),
  )
  |> Past
  |> tl_any_variant.unwrap()
  |> should.equal("boop")
}
