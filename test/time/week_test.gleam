import gleam/list
import gleeunit/should
import tempo/date
import time/week
import time/window/date_window

// ----------------------------------------------------
// ----------------------------------------------------
// ------------ week.date_window_from_date ------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn date_window_from_date_1_test() {
  date.literal("2025-02-22")
  |> week.date_window_from_date()
  |> should.equal(date_window.new(
    start: date.literal("2025-02-17"),
    final: date.literal("2025-02-23"),
  ))
}

/// On Monday.
pub fn date_window_from_date_2_test() {
  date.literal("2025-04-14")
  |> week.date_window_from_date()
  |> should.equal(date_window.new(
    start: date.literal("2025-04-14"),
    final: date.literal("2025-04-20"),
  ))
}

/// On Sunday.
pub fn date_window_from_date_3_test() {
  date.literal("2024-07-21")
  |> week.date_window_from_date()
  |> should.equal(date_window.new(
    start: date.literal("2024-07-15"),
    final: date.literal("2024-07-21"),
  ))
}

/// On Wednesday.
pub fn date_window_from_date_4_test() {
  date.literal("2025-05-14")
  |> week.date_window_from_date()
  |> should.equal(date_window.new(
    start: date.literal("2025-05-12"),
    final: date.literal("2025-05-18"),
  ))
}

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------- week_list_from_date ---------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn week_list_from_date_1_test() {
  date.literal("2025-02-22")
  |> week.list_from_date()
  |> list.map(date.to_string)
  |> should.equal([
    "2025-02-17", "2025-02-18", "2025-02-19", "2025-02-20", "2025-02-21",
    "2025-02-22", "2025-02-23",
  ])
}

pub fn week_list_from_date_monday_test() {
  date.literal("2025-04-14")
  |> week.list_from_date()
  |> list.map(date.to_string)
  |> should.equal([
    "2025-04-14", "2025-04-15", "2025-04-16", "2025-04-17", "2025-04-18",
    "2025-04-19", "2025-04-20",
  ])
}

pub fn week_list_from_date_sunday_test() {
  date.literal("2024-07-21")
  |> week.list_from_date()
  |> list.map(date.to_string)
  |> should.equal([
    "2024-07-15", "2024-07-16", "2024-07-17", "2024-07-18", "2024-07-19",
    "2024-07-20", "2024-07-21",
  ])
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------- to_normalised_day_of_week ------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn to_normalised_day_of_week_1_test() {
  date.literal("2025-03-29")
  |> week.to_normalised_day_of_week_number()
  |> should.equal(6)
}

pub fn to_normalised_day_of_week_2_test() {
  date.literal("2025-03-30")
  |> week.to_normalised_day_of_week_number()
  |> should.equal(7)
}
