import calendar/iso_date
import day.{type Day}
import gleeunit/should

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------- to_month_number ------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn to_month_number_1_test() {
  day.from_gtempo_literal("2025-01-01")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(1)
}

pub fn to_month_number_2_test() {
  day.from_gtempo_literal("2025-02-01")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(2)
}

pub fn to_month_number_3_test() {
  day.from_gtempo_literal("2025-03-01")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(3)
}

pub fn to_month_number_4_test() {
  day.from_gtempo_literal("2025-04-04")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(4)
}

pub fn to_month_number_5_test() {
  day.from_gtempo_literal("2025-05-05")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(5)
}

pub fn to_month_number_6_test() {
  day.from_gtempo_literal("2025-06-06")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(6)
}

pub fn to_month_number_7_test() {
  day.from_gtempo_literal("2025-07-07")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(7)
}

pub fn to_month_number_8_test() {
  day.from_gtempo_literal("2025-08-08")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(8)
}

pub fn to_month_number_9_test() {
  day.from_gtempo_literal("2025-09-09")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(9)
}

pub fn to_month_number_10_test() {
  day.from_gtempo_literal("2025-10-01")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(10)
}

pub fn to_month_number_11_test() {
  day.from_gtempo_literal("2025-11-01")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(11)
}

pub fn to_month_number_12_test() {
  day.from_gtempo_literal("2025-12-01")
  |> iso_date.from_day
  |> iso_date.to_month_number()
  |> should.equal(12)
}

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
// ------------- to_day_of_week_number ----------------
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

/// On a Tuesday.
pub fn prev_day_of_week_4_test() {
  day.from_gtempo_literal("2026-02-17")
  |> iso_date.from_day
  |> iso_date.prev_day_of_week(iso_date.Tuesday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-02-10")
}

/// On a Tuesday.
pub fn prev_day_of_week_5_test() {
  day.from_gtempo_literal("2019-04-02")
  |> iso_date.from_day
  |> iso_date.prev_day_of_week(iso_date.Monday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2019-04-01")
}

/// On a Saturday.
pub fn prev_day_of_week_6_test() {
  day.from_gtempo_literal("2019-06-15")
  |> iso_date.from_day
  |> iso_date.prev_day_of_week(iso_date.Sunday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2019-06-09")
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------------ next_day_of_week ----------------
// ----------------------------------------------------
// ----------------------------------------------------

/// On a Wednesday
pub fn next_day_of_week_1_test() {
  day.from_gtempo_literal("2026-04-22")
  |> iso_date.from_day
  |> iso_date.next_day_of_week(iso_date.Thursday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-23")
}

/// On a Sunday
pub fn next_day_of_week_2_test() {
  day.from_gtempo_literal("2026-04-12")
  |> iso_date.from_day
  |> iso_date.next_day_of_week(iso_date.Saturday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-18")
}

/// On a Monday
pub fn next_day_of_week_3_test() {
  day.from_gtempo_literal("2026-04-20")
  |> iso_date.from_day
  |> iso_date.next_day_of_week(iso_date.Thursday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-23")
}

/// On a Tuesday
pub fn next_day_of_week_4_test() {
  day.from_gtempo_literal("2026-04-07")
  |> iso_date.from_day
  |> iso_date.next_day_of_week(iso_date.Tuesday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-14")
}

// ----------------------------------------------------
// ----------------------------------------------------
// -------------- closest_prev_day_of_week ------------
// ----------------------------------------------------
// ----------------------------------------------------

/// On Thursday.
pub fn closest_prev_day_of_week_1_test() {
  day.from_gtempo_literal("2026-04-09")
  |> iso_date.from_day
  |> iso_date.closest_prev_day_of_week(iso_date.Monday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-06")
}

/// On Saturday (same day).
pub fn closest_prev_day_of_week_2_test() {
  day.from_gtempo_literal("2026-04-18")
  |> iso_date.from_day
  |> iso_date.closest_prev_day_of_week(iso_date.Saturday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-18")
}

/// On Monday
pub fn closest_prev_day_of_week_3_test() {
  day.from_gtempo_literal("2026-04-27")
  |> iso_date.from_day
  |> iso_date.closest_prev_day_of_week(iso_date.Thursday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-23")
}

// ----------------------------------------------------
// ----------------------------------------------------
// -------------- closest_next_day_of_week ------------
// ----------------------------------------------------
// ----------------------------------------------------

/// On Sunday.
pub fn closest_next_day_of_week_1_test() {
  day.from_gtempo_literal("2025-07-21")
  |> iso_date.from_day
  |> iso_date.closest_next_day_of_week(iso_date.Monday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2025-07-21")
}

/// On Friday.
pub fn closest_next_day_of_week_2_test() {
  day.from_gtempo_literal("2026-05-01")
  |> iso_date.from_day
  |> iso_date.closest_next_day_of_week(iso_date.Friday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-05-01")
}

/// On Wednesday.
pub fn closest_next_day_of_week_3_test() {
  day.from_gtempo_literal("2026-04-22")
  |> iso_date.from_day
  |> iso_date.closest_next_day_of_week(iso_date.Thursday)
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-23")
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------------ last_of_month -------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn last_of_month_1_test() {
  day.from_gtempo_literal("2026-04-28")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-04-30")
}

pub fn last_of_month_2_test() {
  day.from_gtempo_literal("2026-05-05")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-05-31")
}

pub fn last_of_month_3_test() {
  day.from_gtempo_literal("2026-06-17")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-06-30")
}

pub fn last_of_month_4_test() {
  day.from_gtempo_literal("2026-07-01")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-07-31")
}

pub fn last_of_month_5_test() {
  day.from_gtempo_literal("2026-08-31")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-08-31")
}

pub fn last_of_month_6_test() {
  day.from_gtempo_literal("2026-09-09")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-09-30")
}

pub fn last_of_month_7_test() {
  day.from_gtempo_literal("2026-10-30")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-10-31")
}

pub fn last_of_month_8_test() {
  day.from_gtempo_literal("2026-11-16")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-11-30")
}

pub fn last_of_month_9_test() {
  day.from_gtempo_literal("2026-12-04")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-12-31")
}

pub fn last_of_month_10_test() {
  day.from_gtempo_literal("2026-01-04")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-01-31")
}

pub fn last_of_month_11_test() {
  day.from_gtempo_literal("2026-02-04")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-02-28")
}

pub fn last_of_month_12_test() {
  day.from_gtempo_literal("2026-03-04")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2026-03-31")
}

/// Leap year on February.
pub fn last_of_month_13_test() {
  day.from_gtempo_literal("2024-02-25")
  |> iso_date.from_day
  |> iso_date.last_of_month
  |> iso_date.to_day
  |> day.to_string
  |> should.equal("2024-02-29")
}
