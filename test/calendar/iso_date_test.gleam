import calendar/iso_date
import day.{type Day}
import gleeunit/should

// ----------------------------------------------------
// ----------------------------------------------------
// -------------------- to_day_of_week ----------------
// ----------------------------------------------------
// ----------------------------------------------------
fn day_of_week_chain(day: Day) -> iso_date.DayOfWeek {
  day
  |> iso_date.from_day
  |> iso_date.to_day_of_week
}

pub fn to_day_of_week_1_test() {
  day.from_gtempo_literal("2026-04-19")
  |> day_of_week_chain
  |> should.equal(iso_date.Sunday)
}

pub fn to_day_of_week_2_test() {
  day.from_gtempo_literal("2026-04-13")
  |> day_of_week_chain
  |> should.equal(iso_date.Monday)
}

pub fn to_day_of_week_3_test() {
  day.from_gtempo_literal("2026-04-15")
  |> day_of_week_chain
  |> should.equal(iso_date.Wednesday)
}

pub fn to_day_of_week_4_test() {
  day.from_gtempo_literal("2029-09-24")
  |> day_of_week_chain
  |> should.equal(iso_date.Monday)
}

pub fn to_day_of_week_5_test() {
  day.from_gtempo_literal("2029-08-31")
  |> day_of_week_chain
  |> should.equal(iso_date.Friday)
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------- to_day_of_week_number ------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn to_day_of_week_number_1_test() {
  day.from_gtempo_literal("2025-03-29")
  |> iso_date.from_day
  |> iso_date.to_day_of_week_number()
  |> should.equal(6)
}

pub fn to_day_of_week_number_2_test() {
  day.from_gtempo_literal("2025-03-30")
  |> iso_date.from_day
  |> iso_date.to_day_of_week_number()
  |> should.equal(7)
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------------ is_one_day_after ----------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn date_is_one_day_after_1_test() {
  day.from_gtempo_literal("2024-03-04")
  |> iso_date.is_one_day_after(from: day.from_gtempo_literal("2024-03-03"))
  |> should.equal(True)
}

pub fn date_is_one_day_after_2_test() {
  day.from_gtempo_literal("1999-12-31")
  |> iso_date.is_one_day_after(from: day.from_gtempo_literal("1999-12-30"))
  |> should.equal(True)
}

pub fn date_is_one_day_after_3_test() {
  day.from_gtempo_literal("2034-06-07")
  |> iso_date.is_one_day_after(from: day.from_gtempo_literal("1999-12-30"))
  |> should.equal(False)
}

pub fn date_is_one_day_after_4_test() {
  day.from_gtempo_literal("2034-06-07")
  |> iso_date.is_one_day_after(from: day.from_gtempo_literal("2034-06-08"))
  |> should.equal(False)
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------------ to_ordinal_day -----------------
// ----------------------------------------------------
// ----------------------------------------------------

fn ordinal_day_test(day: Day) -> Int {
  day
  |> iso_date.from_day
  |> iso_date.to_ordinal_day
}

pub fn to_ordinal_day_1_test() {
  ordinal_day_test(day.from_gtempo_literal("2016-11-05"))
  |> should.equal(310)
}

// explicitly normal year -----------------------------------------

pub fn to_ordinal_day_normal_year_1_test() {
  ordinal_day_test(day.from_gtempo_literal("2025-01-31"))
  |> should.equal(31)
}

pub fn to_ordinal_day_normal_year_2_test() {
  ordinal_day_test(day.from_gtempo_literal("2025-02-10"))
  |> should.equal(41)
}

pub fn to_ordinal_day_normal_year_3_test() {
  ordinal_day_test(day.from_gtempo_literal("2025-03-29"))
  |> should.equal(88)
}

pub fn to_ordinal_day_normal_year_4_test() {
  ordinal_day_test(day.from_gtempo_literal("2023-04-27"))
  |> should.equal(117)
}

pub fn to_ordinal_day_normal_year_5_test() {
  ordinal_day_test(day.from_gtempo_literal("2025-05-14"))
  |> should.equal(134)
}

pub fn to_ordinal_day_normal_year_6_test() {
  ordinal_day_test(day.from_gtempo_literal("2025-06-01"))
  |> should.equal(152)
}

pub fn to_ordinal_day_normal_year_7_test() {
  ordinal_day_test(day.from_gtempo_literal("2023-07-02"))
  |> should.equal(183)
}

pub fn to_ordinal_day_normal_year_8_test() {
  ordinal_day_test(day.from_gtempo_literal("2025-08-12"))
  |> should.equal(224)
}

pub fn to_ordinal_day_normal_year_9_test() {
  ordinal_day_test(day.from_gtempo_literal("2025-09-30"))
  |> should.equal(273)
}

pub fn to_ordinal_day_normal_year_10_test() {
  ordinal_day_test(day.from_gtempo_literal("2025-10-10"))
  |> should.equal(283)
}

pub fn to_ordinal_day_normal_year_11_test() {
  ordinal_day_test(day.from_gtempo_literal("2023-11-29"))
  |> should.equal(333)
}

pub fn to_ordinal_day_normal_year_12_test() {
  ordinal_day_test(day.from_gtempo_literal("2023-12-01"))
  |> should.equal(335)
}

// leap year -----------------------------------------
pub fn to_ordinal_day_leap_year_1_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-01-11"))
  |> should.equal(11)
}

pub fn to_ordinal_day_leap_year_2_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-02-29"))
  |> should.equal(60)
}

pub fn to_ordinal_day_leap_year_3_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-03-08"))
  |> should.equal(68)
}

pub fn to_ordinal_day_leap_year_4_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-04-16"))
  |> should.equal(107)
}

pub fn to_ordinal_day_leap_year_5_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-05-07"))
  |> should.equal(128)
}

pub fn to_ordinal_day_leap_year_6_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-06-28"))
  |> should.equal(180)
}

pub fn to_ordinal_day_leap_year_7_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-07-11"))
  |> should.equal(193)
}

pub fn to_ordinal_day_leap_year_8_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-08-20"))
  |> should.equal(233)
}

pub fn to_ordinal_day_leap_year_9_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-09-13"))
  |> should.equal(257)
}

pub fn to_ordinal_day_leap_year_10_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-10-30"))
  |> should.equal(304)
}

pub fn to_ordinal_day_leap_year_11_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-11-19"))
  |> should.equal(324)
}

pub fn to_ordinal_day_leap_year_12_test() {
  ordinal_day_test(day.from_gtempo_literal("2024-12-12"))
  |> should.equal(347)
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------------ prev_day_of_week ----------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn prev_day_of_week_1_test() {
  day.from_gtempo_literal("2025-02-22")
  |> iso_date.from_day
  |> iso_date.prev_day_of_week(iso_date.Monday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2025-02-17")
}

/// On Monday.
pub fn prev_day_of_week_2_test() {
  day.from_gtempo_literal("2025-04-14")
  |> iso_date.from_day
  |> iso_date.prev_day_of_week(iso_date.Monday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2025-04-07")
}

/// On Wednesday.
pub fn prev_day_of_week_3_test() {
  day.from_gtempo_literal("2025-05-14")
  |> iso_date.from_day
  |> iso_date.prev_day_of_week(iso_date.Monday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2025-05-12")
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------- most_recent_day_of_week ------------
// ----------------------------------------------------
// ----------------------------------------------------

/// On Sunday.
pub fn most_recent_day_of_week_1_test() {
  day.from_gtempo_literal("2025-07-21")
  |> iso_date.from_day
  |> iso_date.closest_next_day_of_week(iso_date.Monday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2025-07-21")
}
