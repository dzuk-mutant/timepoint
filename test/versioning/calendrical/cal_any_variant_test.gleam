import day
import gleeunit/should
import versioning/calendrical/cal_any_variant.{Current, Past}
import versioning/calendrical/cal_current_variant
import versioning/calendrical/cal_past_variant

pub fn unwrap_current_variant_test() {
  cal_current_variant.new(
    value: "boop",
    start: day.testing_iso8601("2025-02-27"),
  )
  |> Current
  |> cal_any_variant.unwrap()
  |> should.equal("boop")
}

pub fn unwrap_past_variant_test() {
  cal_past_variant.new(
    value: "boop",
    start: day.testing_iso8601("2025-02-27"),
    final: day.testing_iso8601("2025-02-28"),
  )
  |> Past
  |> cal_any_variant.unwrap()
  |> should.equal("boop")
}
