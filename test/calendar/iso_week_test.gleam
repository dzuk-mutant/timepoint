import calendar/iso_week
import day.{type Day}
import gleam/list
import gleam/order
import gleeunit/should
import interval/day_interval
import tempo/date as gtempo_date

fn day_to_string(sd: Day) -> String {
  sd
  |> day.to_gtempo_date
  |> gtempo_date.to_string
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- to_interval ------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn day_interval_from_date_1_test() {
  day.from_gtempo_literal("2025-02-22")
  |> iso_week.from_day
  |> iso_week.to_interval
  |> should.equal(day_interval.new(
    start: day.from_gtempo_literal("2025-02-17"),
    final: day.from_gtempo_literal("2025-02-23"),
  ))
}

/// On Monday.
pub fn day_interval_from_date_2_test() {
  day.from_gtempo_literal("2025-04-14")
  |> iso_week.from_day
  |> iso_week.to_interval
  |> should.equal(day_interval.new(
    start: day.from_gtempo_literal("2025-04-14"),
    final: day.from_gtempo_literal("2025-04-20"),
  ))
}

/// On Sunday.
pub fn day_interval_from_date_3_test() {
  day.from_gtempo_literal("2024-07-21")
  |> iso_week.from_day
  |> iso_week.to_interval
  |> should.equal(day_interval.new(
    start: day.from_gtempo_literal("2024-07-15"),
    final: day.from_gtempo_literal("2024-07-21"),
  ))
}

/// On Wednesday.
pub fn day_interval_from_date_4_test() {
  day.from_gtempo_literal("2025-05-14")
  |> iso_week.from_day
  |> iso_week.to_interval
  |> should.equal(day_interval.new(
    start: day.from_gtempo_literal("2025-05-12"),
    final: day.from_gtempo_literal("2025-05-18"),
  ))
}

// ----------------------------------------------------
// ----------------------------------------------------
// ----------------------- to_list --------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn week_list_from_date_1_test() {
  day.from_gtempo_literal("2025-02-22")
  |> iso_week.from_day
  |> iso_week.to_list
  |> list.map(day_to_string)
  |> should.equal([
    "2025-02-17", "2025-02-18", "2025-02-19", "2025-02-20", "2025-02-21",
    "2025-02-22", "2025-02-23",
  ])
}

pub fn week_list_from_date_monday_test() {
  day.from_gtempo_literal("2025-04-14")
  |> iso_week.from_day
  |> iso_week.to_list
  |> list.map(day_to_string)
  |> should.equal([
    "2025-04-14", "2025-04-15", "2025-04-16", "2025-04-17", "2025-04-18",
    "2025-04-19", "2025-04-20",
  ])
}

pub fn week_list_from_date_sunday_test() {
  day.from_gtempo_literal("2024-07-21")
  |> iso_week.from_day
  |> iso_week.to_list
  |> list.map(day_to_string)
  |> should.equal([
    "2024-07-15", "2024-07-16", "2024-07-17", "2024-07-18", "2024-07-19",
    "2024-07-20", "2024-07-21",
  ])
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------- list_from_inside_interval ------------
// ----------------------------------------------------
// ----------------------------------------------------

/// 
/// xx  xx  25  26  27  28  29
/// 30  31  01  02  03  04  05
/// 
/// -> One week
pub fn list_from_inside_interval_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-25"),
    final: day.from_gtempo_literal("2026-04-05"),
  )
  |> iso_week.list_from_inside_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-30"),
      final: day.from_gtempo_literal("2026-04-05"),
    ),
  ])
}

/// 
/// xx  xx  25  26  27  28  xx
/// 
/// -> No weeks
pub fn list_from_inside_interval_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-25"),
    final: day.from_gtempo_literal("2026-03-28"),
  )
  |> iso_week.list_from_inside_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([])
}

/// 
/// 23  24  25  26  27  28  29
/// 
/// -> One week
pub fn list_from_inside_interval_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-23"),
    final: day.from_gtempo_literal("2026-03-29"),
  )
  |> iso_week.list_from_inside_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-23"),
      final: day.from_gtempo_literal("2026-03-29"),
    ),
  ])
}

/// 
/// 23  24  25  26  27  28  29
/// 30  31  01  02  03  04  05
/// 
/// -> Two weeks
pub fn list_from_inside_interval_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-23"),
    final: day.from_gtempo_literal("2026-04-05"),
  )
  |> iso_week.list_from_inside_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-23"),
      final: day.from_gtempo_literal("2026-03-29"),
    ),

    day_interval.new(
      start: day.from_gtempo_literal("2026-03-30"),
      final: day.from_gtempo_literal("2026-04-05"),
    ),
  ])
}

/// xx  xx  xx  xx  20  21  22
/// 23  24  25  26  27  28  29
/// 30  31  01  02  03  04  05
/// 06  07  08  09  10  11  xx
/// -> Two weeks
pub fn list_from_inside_interval_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-20"),
    final: day.from_gtempo_literal("2026-04-11"),
  )
  |> iso_week.list_from_inside_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-23"),
      final: day.from_gtempo_literal("2026-03-29"),
    ),

    day_interval.new(
      start: day.from_gtempo_literal("2026-03-30"),
      final: day.from_gtempo_literal("2026-04-05"),
    ),
  ])
}

// ----------------------------------------------------
// ----------------------------------------------------
// ------------- list_from_around_interval ------------
// ----------------------------------------------------
// ----------------------------------------------------

/// 
/// xx  xx  25  26  27  28  29
/// 30  31  01  02  03  04  05
/// 
/// -> Two weeks
pub fn list_from_around_interval_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-25"),
    final: day.from_gtempo_literal("2026-04-05"),
  )
  |> iso_week.list_from_around_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-23"),
      final: day.from_gtempo_literal("2026-03-29"),
    ),
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-30"),
      final: day.from_gtempo_literal("2026-04-05"),
    ),
  ])
}

/// 
/// xx  xx  25  26  27  28  xx
/// 
/// -> One week
pub fn list_from_around_interval_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-25"),
    final: day.from_gtempo_literal("2026-03-28"),
  )
  |> iso_week.list_from_around_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-23"),
      final: day.from_gtempo_literal("2026-03-29"),
    ),
  ])
}

/// 
/// 23  24  25  26  27  28  29
/// 
/// -> One week
pub fn list_from_around_interval_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-23"),
    final: day.from_gtempo_literal("2026-03-29"),
  )
  |> iso_week.list_from_around_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-23"),
      final: day.from_gtempo_literal("2026-03-29"),
    ),
  ])
}

/// 
/// 23  24  25  26  27  28  29
/// 30  31  01  02  03  04  05
/// 
/// -> Two weeks
pub fn list_from_around_interval_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-23"),
    final: day.from_gtempo_literal("2026-04-05"),
  )
  |> iso_week.list_from_around_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-23"),
      final: day.from_gtempo_literal("2026-03-29"),
    ),

    day_interval.new(
      start: day.from_gtempo_literal("2026-03-30"),
      final: day.from_gtempo_literal("2026-04-05"),
    ),
  ])
}

/// xx  xx  xx  xx  20  21  22
/// 23  24  25  26  27  28  29
/// 30  31  01  02  03  04  05
/// 06  07  08  09  10  11  xx
/// -> Four weeks
pub fn list_from_around_interval_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-03-20"),
    final: day.from_gtempo_literal("2026-04-11"),
  )
  |> iso_week.list_from_around_interval
  |> list.map(iso_week.to_interval)
  |> should.equal([
    day_interval.new(
      start: day.from_gtempo_literal("2026-03-16"),
      final: day.from_gtempo_literal("2026-03-22"),
    ),

    day_interval.new(
      start: day.from_gtempo_literal("2026-03-23"),
      final: day.from_gtempo_literal("2026-03-29"),
    ),

    day_interval.new(
      start: day.from_gtempo_literal("2026-03-30"),
      final: day.from_gtempo_literal("2026-04-05"),
    ),

    day_interval.new(
      start: day.from_gtempo_literal("2026-04-06"),
      final: day.from_gtempo_literal("2026-04-12"),
    ),
  ])
}

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------- to_monday ---------------
// ----------------------------------------------------
// ----------------------------------------------------

/// 30  31  01  02  03  04  05
/// ^^
pub fn to_monday_1_test() {
  iso_week.from_day(day.from_gtempo_literal("2026-04-05"))
  |> iso_week.to_monday
  |> should.equal(day.from_gtempo_literal("2026-03-30"))
}

/// 23  24  25  26  27  28  29
/// ^^
pub fn to_monday_2_test() {
  iso_week.from_day(day.from_gtempo_literal("2026-03-26"))
  |> iso_week.to_monday
  |> should.equal(day.from_gtempo_literal("2026-03-23"))
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- to_list ----------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// 23  24  25  26  27  28  29
/// 
pub fn to_list_1_test() {
  iso_week.from_day(day.from_gtempo_literal("2026-03-27"))
  |> iso_week.to_list
  |> should.equal(
    [
      "2026-03-23",
      "2026-03-24",
      "2026-03-25",
      "2026-03-26",
      "2026-03-27",
      "2026-03-28",
      "2026-03-29",
    ]
    |> list.map(day.from_gtempo_literal),
  )
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- is_equal ---------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// 23  24  25  26  27  28  29
/// 
pub fn is_equal_1_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))

  week_a
  |> iso_week.is_equal(to: week_b)
  |> should.equal(True)
}

/// 23  24  25  26  27  28  29
/// 
pub fn is_equal_2_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-03-28"))

  week_a
  |> iso_week.is_equal(to: week_b)
  |> should.equal(True)
}

/// 23  24  25  26  27  28  29
/// 
pub fn is_equal_3_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-02-28"))

  week_a
  |> iso_week.is_equal(to: week_b)
  |> should.equal(False)
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- compare ---------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// 23  24  25  26  27  28  29
/// 
pub fn compare_1_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))

  week_a
  |> iso_week.compare(to: week_b)
  |> should.equal(order.Eq)
}

/// 23  24  25  26  27  28  29
/// 
pub fn compare_2_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-02-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))

  week_a
  |> iso_week.compare(to: week_b)
  |> should.equal(order.Lt)
}

/// 23  24  25  26  27  28  29
/// 
pub fn compare_3_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-04-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))

  week_a
  |> iso_week.compare(to: week_b)
  |> should.equal(order.Gt)
}

// ----------------------------------------------------
// ----------------------------------------------------
// ----------------- compare_reverse ------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// 23  24  25  26  27  28  29
/// 
pub fn compare_reverse_1_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))

  week_a
  |> iso_week.compare_reverse(to: week_b)
  |> should.equal(order.Eq)
}

/// 23  24  25  26  27  28  29
/// 
pub fn compare_reverse_2_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-02-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))

  week_a
  |> iso_week.compare_reverse(to: week_b)
  |> should.equal(order.Gt)
}

/// 23  24  25  26  27  28  29
/// 
pub fn compare_reverse_3_test() {
  let week_a = iso_week.from_day(day.from_gtempo_literal("2026-04-27"))
  let week_b = iso_week.from_day(day.from_gtempo_literal("2026-03-27"))

  week_a
  |> iso_week.compare_reverse(to: week_b)
  |> should.equal(order.Lt)
}
