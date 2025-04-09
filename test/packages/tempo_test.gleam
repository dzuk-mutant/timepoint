import gleam/order.{Eq, Lt}
import gleeunit/should
import tempo.{type DateTime}
import tempo/date
import tempo/datetime
import tempo/duration
import tempo/instant
import tempo/mock
import tempo/naive_datetime
import tempo/offset

/// a quick sanity test on how I'm testing time.
pub fn datetime_literal_test() {
  datetime.literal("2025-02-22T00:00:00.000Z")
  |> should.equal(datetime.literal("2025-02-22T00:00:00.000+00:00"))
}

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------- time zone tests -------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn datetime_tz_1_test() {
  datetime.compare(
    datetime.literal("2025-02-22T00:00:00.000+00:00"),
    datetime.literal("2025-02-22T10:00:00.000+10:00"),
  )
  |> should.equal(Eq)
}

pub fn datetime_tz_2_test() {
  datetime.compare(
    datetime.literal("2025-02-22T23:00:00.000+00:00"),
    datetime.literal("2025-02-23T09:00:00.000+10:00"),
  )
  |> should.equal(Eq)
}

pub fn datetime_tz_3_test() {
  datetime.compare(
    datetime.literal("2025-02-22T23:00:00.000+00:00"),
    datetime.literal("2025-02-23T10:00:00.000+10:00"),
  )
  |> should.equal(Lt)
}

/// A datetime in a future date being before a datetime in a past date due to timezones.
pub fn datetime_tz_4_test() {
  datetime.compare(
    datetime.literal("2025-02-23T01:00:00.000+00:00"),
    datetime.literal("2025-02-22T23:00:00.000-08:00"),
  )
  |> should.equal(Lt)
}

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------- day of week -----------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn to_day_of_week_number_1_test() {
  date.literal("2025-03-24")
  |> date.to_day_of_week_number()
  |> should.equal(1)
}

pub fn to_day_of_week_number_2_test() {
  date.literal("2025-03-29")
  |> date.to_day_of_week_number()
  |> should.equal(6)
}

/// Undesirable, but how the library works.
pub fn to_day_of_week_number_3_test() {
  date.literal("2024-12-29")
  |> date.to_day_of_week_number()
  |> should.equal(0)
}

// ----------------------------------------------------
// ----------------------------------------------------
// -------- applying and de-applying offsets ----------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn offset_application_1_test() {
  datetime.literal("2000-01-01T00:00:00.000+02:00")
  |> datetime.to_unix_milli
  |> datetime.from_unix_milli
  |> datetime.add(duration.minutes(120))
  |> datetime.apply_offset
  |> naive_datetime.set_offset(offset.literal("+02:00"))
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------------------ mock ----------------------
// ----------------------------------------------------
// ----------------------------------------------------

fn mock(datetime: DateTime) {
  mock.freeze_time(datetime)

  instant.now()
  |> instant.as_local_datetime
  |> should.equal(datetime)

  mock.unfreeze_time()
}

pub fn mock_1_test() {
  datetime.literal("2000-01-01T00:00:00.000+01:00")
  |> mock()
}
