import gleam/order
import gleeunit/should
import tempo/date
import time/extra/date as date_extra

// ----------------------------------------------------
// ----------------------------------------------------
// ------------- most_recent_monday_behind ------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn most_recent_monday_behind_1_test() {
  date.literal("2025-02-22")
  |> date_extra.most_recent_monday_behind()
  |> date.to_string
  |> should.equal("2025-02-17")
}

/// On Monday.
pub fn most_recent_monday_behind_2_test() {
  date.literal("2025-04-14")
  |> date_extra.most_recent_monday_behind()
  |> date.to_string
  |> should.equal("2025-04-14")
}

/// On Sunday.
pub fn most_recent_monday_behind_3_test() {
  date.literal("2025-07-21")
  |> date_extra.most_recent_monday_behind()
  |> date.to_string
  |> should.equal("2025-07-21")
}

/// On Wednesday.
pub fn most_recent_monday_behind_4_test() {
  date.literal("2025-05-14")
  |> date_extra.most_recent_monday_behind()
  |> date.to_string
  |> should.equal("2025-05-12")
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------------ is_one_day_after ----------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn date_is_one_day_after_1_test() {
  date.literal("2024-03-04")
  |> date_extra.is_one_day_after(from: date.literal("2024-03-03"))
  |> should.equal(True)
}

pub fn date_is_one_day_after_2_test() {
  date.literal("1999-12-31")
  |> date_extra.is_one_day_after(from: date.literal("1999-12-30"))
  |> should.equal(True)
}

pub fn date_is_one_day_after_3_test() {
  date.literal("2034-06-07")
  |> date_extra.is_one_day_after(from: date.literal("1999-12-30"))
  |> should.equal(False)
}

pub fn date_is_one_day_after_4_test() {
  date.literal("2034-06-07")
  |> date_extra.is_one_day_after(from: date.literal("2034-06-08"))
  |> should.equal(False)
}

// ----------------------------------------------------
// ----------------------------------------------------
// -------------------- order_reverse -----------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn order_reverse_1_test() {
  date_extra.order_reverse(
    date.literal("2034-06-08"),
    date.literal("2034-07-07"),
  )
  |> should.equal(order.Gt)
}

pub fn order_reverse_2_test() {
  date_extra.order_reverse(
    date.literal("2025-03-04"),
    date.literal("2022-01-01"),
  )
  |> should.equal(order.Lt)
}

pub fn order_reverse_3_test() {
  date_extra.order_reverse(
    date.literal("2034-06-08"),
    date.literal("2034-06-08"),
  )
  |> should.equal(order.Eq)
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------------ to_ordinal_day -----------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn to_ordinal_day_1_test() {
  date_extra.to_ordinal_day(date.literal("2016-11-05"))
  |> should.equal(310)
}

// explicitly normal year -----------------------------------------

pub fn to_ordinal_day_normal_year_1_test() {
  date_extra.to_ordinal_day(date.literal("2025-01-31"))
  |> should.equal(31)
}

pub fn to_ordinal_day_normal_year_2_test() {
  date_extra.to_ordinal_day(date.literal("2025-02-10"))
  |> should.equal(41)
}

pub fn to_ordinal_day_normal_year_3_test() {
  date_extra.to_ordinal_day(date.literal("2025-03-29"))
  |> should.equal(88)
}

pub fn to_ordinal_day_normal_year_4_test() {
  date_extra.to_ordinal_day(date.literal("2023-04-27"))
  |> should.equal(117)
}

pub fn to_ordinal_day_normal_year_5_test() {
  date_extra.to_ordinal_day(date.literal("2025-05-14"))
  |> should.equal(134)
}

pub fn to_ordinal_day_normal_year_6_test() {
  date_extra.to_ordinal_day(date.literal("2025-06-01"))
  |> should.equal(152)
}

pub fn to_ordinal_day_normal_year_7_test() {
  date_extra.to_ordinal_day(date.literal("2023-07-02"))
  |> should.equal(183)
}

pub fn to_ordinal_day_normal_year_8_test() {
  date_extra.to_ordinal_day(date.literal("2025-08-12"))
  |> should.equal(224)
}

pub fn to_ordinal_day_normal_year_9_test() {
  date_extra.to_ordinal_day(date.literal("2025-09-30"))
  |> should.equal(273)
}

pub fn to_ordinal_day_normal_year_10_test() {
  date_extra.to_ordinal_day(date.literal("2025-10-10"))
  |> should.equal(283)
}

pub fn to_ordinal_day_normal_year_11_test() {
  date_extra.to_ordinal_day(date.literal("2023-11-29"))
  |> should.equal(333)
}

pub fn to_ordinal_day_normal_year_12_test() {
  date_extra.to_ordinal_day(date.literal("2023-12-01"))
  |> should.equal(335)
}

// leap year -----------------------------------------
pub fn to_ordinal_day_leap_year_1_test() {
  date_extra.to_ordinal_day(date.literal("2024-01-11"))
  |> should.equal(11)
}

pub fn to_ordinal_day_leap_year_2_test() {
  date_extra.to_ordinal_day(date.literal("2024-02-29"))
  |> should.equal(60)
}

pub fn to_ordinal_day_leap_year_3_test() {
  date_extra.to_ordinal_day(date.literal("2024-03-08"))
  |> should.equal(68)
}

pub fn to_ordinal_day_leap_year_4_test() {
  date_extra.to_ordinal_day(date.literal("2024-04-16"))
  |> should.equal(107)
}

pub fn to_ordinal_day_leap_year_5_test() {
  date_extra.to_ordinal_day(date.literal("2024-05-07"))
  |> should.equal(128)
}

pub fn to_ordinal_day_leap_year_6_test() {
  date_extra.to_ordinal_day(date.literal("2024-06-28"))
  |> should.equal(180)
}

pub fn to_ordinal_day_leap_year_7_test() {
  date_extra.to_ordinal_day(date.literal("2024-07-11"))
  |> should.equal(193)
}

pub fn to_ordinal_day_leap_year_8_test() {
  date_extra.to_ordinal_day(date.literal("2024-08-20"))
  |> should.equal(233)
}

pub fn to_ordinal_day_leap_year_9_test() {
  date_extra.to_ordinal_day(date.literal("2024-09-13"))
  |> should.equal(257)
}

pub fn to_ordinal_day_leap_year_10_test() {
  date_extra.to_ordinal_day(date.literal("2024-10-30"))
  |> should.equal(304)
}

pub fn to_ordinal_day_leap_year_11_test() {
  date_extra.to_ordinal_day(date.literal("2024-11-19"))
  |> should.equal(324)
}

pub fn to_ordinal_day_leap_year_12_test() {
  date_extra.to_ordinal_day(date.literal("2024-12-12"))
  |> should.equal(347)
}
