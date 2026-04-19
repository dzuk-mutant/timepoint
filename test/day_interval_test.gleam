import day
import day_interval.{
  type DayInterval, PointAfterFinal, PointAtFinal, PointAtStart,
  PointBeforeStart, PointInside,
}
import gleam/json
import gleam/list
import gleam/result
import gleeunit/should
import moment
import tempo/date

pub fn new_single_1_test() {
  day_interval.new_single(day.from_gtempo_literal("2025-03-03"))
  |> should.equal(day_interval.new(
    start: day.from_gtempo_literal("2025-03-03"),
    final: day.from_gtempo_literal("2025-03-03"),
  ))
}

pub fn new_single_2_test() {
  day_interval.new_single(day.from_gtempo_literal("2013-10-30"))
  |> should.equal(day_interval.new(
    start: day.from_gtempo_literal("2013-10-30"),
    final: day.from_gtempo_literal("2013-10-30"),
  ))
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- JSON ------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

fn json_output(
  interval interval: DayInterval,
  expected_output expected_output: String,
) {
  interval
  |> day_interval.to_json()
  |> json.to_string()
  |> should.equal(expected_output)
}

fn json_output_input(input_and_expected_output: DayInterval) {
  let default =
    day_interval.new(start: day.from_unix_days(0), final: day.from_unix_days(0))
  let day_interval_decoder = day_interval.decoder()
  input_and_expected_output
  |> day_interval.to_json()
  |> json.to_string()
  |> json.parse(using: day_interval_decoder)
  |> result.unwrap(default)
  |> should.equal(input_and_expected_output)
}

fn example_1() {
  day_interval.new(
    start: day.from_gtempo_literal("2025-03-09"),
    final: day.from_gtempo_literal("2025-03-10"),
  )
}

pub fn example_1_output_input_test() {
  json_output_input(example_1())
}

fn example_2() {
  day_interval.new_single(day.from_gtempo_literal("1988-12-16"))
}

pub fn example_2_output_test() {
  json_output(
    interval: example_2(),
    expected_output: "{\"start\":6924,\"final\":6924}",
  )
}

pub fn example_2_output_input_test() {
  json_output_input(example_2())
}

fn example_3() {
  day_interval.new(
    start: day.from_gtempo_literal("2032-03-09"),
    final: day.from_gtempo_literal("2033-03-16"),
  )
}

pub fn example_3_output_input_test() {
  json_output_input(example_3())
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

fn json_i_erroneous(input: String) {
  let decoder = day_interval.decoder()
  input
  |> json.parse(using: decoder)
  |> result.is_error
  |> should.equal(True)
}

/// start is later than final.
pub fn json_i_erroneous_1_test() {
  "{\"start\":1,\"final\":0}"
  |> json_i_erroneous()
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- truncate ------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///   n--------------n
/// 
///   (Error(FinalIsLaterThanOriginal))
/// 
pub fn truncate_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("1999-05-01"),
    final: day.from_gtempo_literal("1999-06-23"),
  )
  |> day_interval.truncate(behind: day.from_gtempo_literal("2000-01-01"))
  |> should.equal(Error(day_interval.FinalIsLaterThanOriginal))
}

///
///   |---------|
///   n---------n
/// 
///   (same final)
///   (Ok)
/// 
pub fn truncate_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("1999-05-01"),
    final: day.from_gtempo_literal("1999-06-23"),
  )
  |> day_interval.truncate(behind: day.from_gtempo_literal("1999-06-24"))
  |> should.equal(
    Ok(day_interval.new(
      start: day.from_gtempo_literal("1999-05-01"),
      final: day.from_gtempo_literal("1999-06-23"),
    )),
  )
}

///
///   |---------|
///   n-----n
/// 
///   (earlier final)
///   (Ok)
/// 
pub fn truncate_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("1999-05-01"),
    final: day.from_gtempo_literal("1999-06-23"),
  )
  |> day_interval.truncate(behind: day.from_gtempo_literal("1999-06-02"))
  |> should.equal(
    Ok(day_interval.new(
      start: day.from_gtempo_literal("1999-05-01"),
      final: day.from_gtempo_literal("1999-06-01"),
    )),
  )
}

///
///   |---------|
///   nn
/// 
///   (same-day final)
///   (Ok)
/// 
pub fn truncate_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("1999-05-01"),
    final: day.from_gtempo_literal("1999-06-23"),
  )
  |> day_interval.truncate(behind: day.from_gtempo_literal("1999-05-02"))
  |> should.equal(
    Ok(day_interval.new(
      start: day.from_gtempo_literal("1999-05-01"),
      final: day.from_gtempo_literal("1999-05-01"),
    )),
  )
}

///
///     |---------|
/// n---n
/// 
///   (Ok)
/// 
pub fn truncate_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("1999-05-01"),
    final: day.from_gtempo_literal("1999-06-23"),
  )
  |> day_interval.truncate(behind: day.from_gtempo_literal("1998-02-02"))
  |> should.equal(Error(day_interval.FinalIsEarlierThanStart))
}

//-------------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- length -------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

pub fn length_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2025-03-05"),
    final: day.from_gtempo_literal("2025-03-05"),
  )
  |> day_interval.length()
  |> should.equal(1)
}

pub fn length_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2025-03-05"),
    final: day.from_gtempo_literal("2025-03-15"),
  )
  |> day_interval.length()
  |> should.equal(11)
}

pub fn length_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2026-01-01"),
    final: day.from_gtempo_literal("2026-01-02"),
  )
  |> day_interval.length()
  |> should.equal(2)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -------------- to_list ----------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

pub fn to_list_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2025-03-05"),
    final: day.from_gtempo_literal("2025-03-05"),
  )
  |> day_interval.to_list()
  |> list.map(day.to_gtempo_date)
  |> list.map(date.to_string)
  |> should.equal(["2025-03-05"])
}

pub fn to_list_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2025-03-05"),
    final: day.from_gtempo_literal("2025-03-09"),
  )
  |> day_interval.to_list()
  |> list.map(day.to_gtempo_date)
  |> list.map(date.to_string)
  |> should.equal([
    "2025-03-05", "2025-03-06", "2025-03-07", "2025-03-08", "2025-03-09",
  ])
}

pub fn to_list_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2024-10-05"),
    final: day.from_gtempo_literal("2024-10-10"),
  )
  |> day_interval.to_list()
  |> list.map(day.to_gtempo_date)
  |> list.map(date.to_string)
  |> should.equal([
    "2024-10-05", "2024-10-06", "2024-10-07", "2024-10-08", "2024-10-09",
    "2024-10-10",
  ])
}

pub fn to_list_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("1989-12-30"),
    final: day.from_gtempo_literal("1990-01-07"),
  )
  |> day_interval.to_list()
  |> list.map(day.to_gtempo_date)
  |> list.map(date.to_string)
  |> should.equal([
    "1989-12-30", "1989-12-31", "1990-01-01", "1990-01-02", "1990-01-03",
    "1990-01-04", "1990-01-05", "1990-01-06", "1990-01-07",
  ])
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ----- to_collision_with_day ------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///                 d
/// 
///   (PointAfterFinal)
/// 
pub fn to_collision_with_day_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_day(day.from_gtempo_literal("2040-01-01"))
  |> should.equal(PointAfterFinal)
}

///
///   |---------|
///              d
/// 
///   (PointAfterFinal)
/// 
pub fn to_collision_with_day_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_day(day.from_gtempo_literal("2036-09-24"))
  |> should.equal(PointAfterFinal)
}

///
///   |---------|
///             d
/// 
///   (PointAtFinal)
/// 
pub fn to_collision_with_day_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_day(day.from_gtempo_literal("2036-09-23"))
  |> should.equal(PointAtFinal)
}

///
///   |---------|
///         d
/// 
///   (PointInside)
/// 
pub fn to_collision_with_day_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_day(day.from_gtempo_literal("2036-08-22"))
  |> should.equal(PointInside)
}

///
///   |---------|
///   d
/// 
///   (PointAtStart)
/// 
pub fn to_collision_with_day_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_day(day.from_gtempo_literal("2036-08-01"))
  |> should.equal(PointAtStart)
}

///
///    |---------|
///   d
/// 
///   (False)
/// 
pub fn to_collision_with_day_6_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_day(day.from_gtempo_literal("2036-07-31"))
  |> should.equal(PointBeforeStart)
}

///
///       |---------|
///   d
/// 
///   (PointBeforeStart)
/// 
pub fn to_collision_with_day_7_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_day(day.from_gtempo_literal("2030-11-11"))
  |> should.equal(PointBeforeStart)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------- to_collision_with_moment --------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///                 d
/// 
///   (PointAfterFinal)
/// 
pub fn to_collision_with_moment_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_moment(moment.from_gtempo_literal(
    "2040-01-01T00:00:00.000Z",
  ))
  |> should.equal(PointAfterFinal)
}

///
///   |---------|
///              d
/// 
///   (PointAfterFinal)
/// 
pub fn to_collision_with_moment_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_moment(moment.from_gtempo_literal(
    "2036-09-24T00:00:00.000Z",
  ))
  |> should.equal(PointAfterFinal)
}

///
///   |---------|
///             d
/// 
///   (PointAtFinal)
/// 
pub fn to_collision_with_moment_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_moment(moment.from_gtempo_literal(
    "2036-09-23T23:59:59.999+00:00",
  ))
  |> should.equal(PointAtFinal)
}

///
///   |---------|
///         d
/// 
///   (PointInside)
/// 
pub fn to_collision_with_moment_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_moment(moment.from_gtempo_literal(
    "2036-08-22T00:00:00.000Z",
  ))
  |> should.equal(PointInside)
}

///
///   |---------|
///   d
/// 
///   (PointAtStart)
/// 
pub fn to_collision_with_moment_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_moment(moment.from_gtempo_literal(
    "2036-08-01T00:00:00.000Z",
  ))
  |> should.equal(PointAtStart)
}

///
///    |---------|
///   d
/// 
///   (PointBeforeStart)
/// 
pub fn to_collision_with_moment_6_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_moment(moment.from_gtempo_literal(
    "2036-07-31T23:59:59.999+00:00",
  ))
  |> should.equal(PointBeforeStart)
}

///
///       |---------|
///   d
/// 
///   (PointBeforeStart)
/// 
pub fn to_collision_with_moment_7_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.to_collision_with_moment(moment.from_gtempo_literal(
    "2030-11-11T00:00:00.000Z",
  ))
  |> should.equal(PointBeforeStart)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- is_around_day ---------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///                 d
/// 
///   (False)
/// 
pub fn is_around_day_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_day(day.from_gtempo_literal("2040-01-01"))
  |> should.equal(False)
}

///
///   |---------|
///              d
/// 
///   (False)
/// 
pub fn is_around_day_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_day(day.from_gtempo_literal("2036-09-24"))
  |> should.equal(False)
}

///
///   |---------|
///             d
/// 
///   (True)
/// 
pub fn is_around_day_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_day(day.from_gtempo_literal("2036-09-23"))
  |> should.equal(True)
}

///
///   |---------|
///         d
/// 
///   (True)
/// 
pub fn is_around_day_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_day(day.from_gtempo_literal("2036-08-22"))
  |> should.equal(True)
}

///
///   |---------|
///   d
/// 
///   (True)
/// 
pub fn is_around_day_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_day(day.from_gtempo_literal("2036-08-01"))
  |> should.equal(True)
}

///
///    |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_day_6_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_day(day.from_gtempo_literal("2036-07-31"))
  |> should.equal(False)
}

///
///       |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_day_7_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_day(day.from_gtempo_literal("2030-11-11"))
  |> should.equal(False)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------- is_around_moment --------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///                 d
/// 
///   (False)
/// 
pub fn is_around_moment_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_moment(moment.from_gtempo_literal(
    "2040-01-01T00:00:00.000Z",
  ))
  |> should.equal(False)
}

///
///   |---------|
///              d
/// 
///   (False)
/// 
pub fn is_around_moment_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_moment(moment.from_gtempo_literal(
    "2036-09-24T00:00:00.000Z",
  ))
  |> should.equal(False)
}

///
///   |---------|
///             d
/// 
///   (True)
/// 
pub fn is_around_moment_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_moment(moment.from_gtempo_literal(
    "2036-09-23T23:59:59.999+00:00",
  ))
  |> should.equal(True)
}

///
///   |---------|
///         d
/// 
///   (True)
/// 
pub fn is_around_moment_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_moment(moment.from_gtempo_literal(
    "2036-08-22T00:00:00.000Z",
  ))
  |> should.equal(True)
}

///
///   |---------|
///   d
/// 
///   (True)
/// 
pub fn is_around_moment_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_moment(moment.from_gtempo_literal(
    "2036-08-01T00:00:00.000Z",
  ))
  |> should.equal(True)
}

///
///    |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_moment_6_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_moment(moment.from_gtempo_literal(
    "2036-07-31T23:59:59.999+00:00",
  ))
  |> should.equal(False)
}

///
///       |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_moment_7_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2036-08-01"),
    final: day.from_gtempo_literal("2036-09-23"),
  )
  |> day_interval.is_around_moment(moment.from_gtempo_literal(
    "2030-11-11T00:00:00.000Z",
  ))
  |> should.equal(False)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------ is_inside ------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///    a---------a
///                   b------b            
/// 
///   (False)
/// 
pub fn is_inside_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2016-08-01"),
    final: day.from_gtempo_literal("2016-09-23"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///              b------b            
/// 
///   (False)
/// 
pub fn is_inside_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-09-23"),
    final: day.from_gtempo_literal("2016-10-23"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///           b------b            
/// 
///   (False)
/// 
pub fn is_inside_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-09-01"),
    final: day.from_gtempo_literal("2016-10-23"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///  b-------------b            
/// 
///   (True)
/// 
pub fn is_inside_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-01-01"),
    final: day.from_gtempo_literal("2015-11-23"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///    b---------b            
/// 
///   (True)
/// 
pub fn is_inside_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///      b-----b            
/// 
///   (False)
/// 
pub fn is_inside_6_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-08-22"),
    final: day.from_gtempo_literal("2015-09-01"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///        b-----b            
/// 
///   (False)
/// 
pub fn is_inside_7_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-08-14"),
    final: day.from_gtempo_literal("2015-09-23"),
  ))
  |> should.equal(False)
}

///
///        a-----a
///    b---------b            
/// 
///   (True)
/// 
pub fn is_inside_8_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-07-14"),
    final: day.from_gtempo_literal("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///    b-----b            
/// 
///   (False)
/// 
pub fn is_inside_9_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-01"),
  ))
  |> should.equal(False)
}

///
///    a------a
///    b---------b            
/// 
///   (True)
/// 
pub fn is_inside_10_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-10-01"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///  b-----b            
/// 
///   (False)
/// 
pub fn is_inside_11_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-05-09"),
    final: day.from_gtempo_literal("2015-09-01"),
  ))
  |> should.equal(False)
}

///
///        a---------a
///  b-----b            
/// 
///   (False)
/// 
pub fn is_inside_12_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-05-09"),
    final: day.from_gtempo_literal("2015-08-01"),
  ))
  |> should.equal(False)
}

///
///          a---------a
///  b-----b            
/// 
///   (False)
/// 
pub fn is_inside_13_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_inside(day_interval.new(
    start: day.from_gtempo_literal("2015-05-09"),
    final: day.from_gtempo_literal("2015-07-15"),
  ))
  |> should.equal(False)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- is_overlapped ----------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///    a---------a
///                   b------b            
/// 
///   (False)
/// 
pub fn is_overlapped_1_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2016-08-01"),
    final: day.from_gtempo_literal("2016-09-23"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///              b------b            
/// 
///   (True)
/// 
pub fn is_overlapped_2_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-09-23"),
    final: day.from_gtempo_literal("2016-10-23"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///           b------b            
/// 
///   (True)
/// 
pub fn is_overlapped_3_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-09-01"),
    final: day.from_gtempo_literal("2016-10-23"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///  b-------------b            
/// 
///   (True)
/// 
pub fn is_overlapped_4_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-01-01"),
    final: day.from_gtempo_literal("2015-11-23"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///    b---------b            
/// 
///   (True)
/// 
pub fn is_overlapped_5_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///      b-----b            
/// 
///   (True)
/// 
pub fn is_overlapped_6_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-08-22"),
    final: day.from_gtempo_literal("2015-09-01"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///        b-----b            
/// 
///   (True)
/// 
pub fn is_overlapped_7_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-08-14"),
    final: day.from_gtempo_literal("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///        a-----a
///    b---------b            
/// 
///   (True)
/// 
pub fn is_overlapped_8_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-07-14"),
    final: day.from_gtempo_literal("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///    b-----b            
/// 
///   (True)
/// 
pub fn is_overlapped_9_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-01"),
  ))
  |> should.equal(True)
}

///
///    a------a
///    b---------b            
/// 
///   (True)
/// 
pub fn is_overlapped_10_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-10-01"),
  ))
  |> should.equal(True)
}

///
///    a---------a
///  b-----b            
/// 
///   (True)
/// 
pub fn is_overlapped_11_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-05-09"),
    final: day.from_gtempo_literal("2015-09-01"),
  ))
  |> should.equal(True)
}

///
///        a---------a
///  b-----b            
/// 
///   (True)
/// 
pub fn is_overlapped_12_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-05-09"),
    final: day.from_gtempo_literal("2015-08-01"),
  ))
  |> should.equal(True)
}

///
///          a---------a
///  b-----b            
/// 
///   (False)
/// 
pub fn is_overlapped_13_test() {
  day_interval.new(
    start: day.from_gtempo_literal("2015-08-01"),
    final: day.from_gtempo_literal("2015-09-23"),
  )
  |> day_interval.is_overlapped(by: day_interval.new(
    start: day.from_gtempo_literal("2015-05-09"),
    final: day.from_gtempo_literal("2015-07-15"),
  ))
  |> should.equal(False)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- is_contiguous ----------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///    a---------a
///                   b------b            
/// 
///   (False)
/// 
pub fn is_contiguous_1_test() {
  let a =
    day_interval.new(
      start: day.from_gtempo_literal("2015-08-01"),
      final: day.from_gtempo_literal("2015-09-23"),
    )
  let b =
    day_interval.new(
      start: day.from_gtempo_literal("2016-08-01"),
      final: day.from_gtempo_literal("2016-09-23"),
    )

  day_interval.is_contiguous(a, before: b)
  |> should.equal(False)
}

///
///    a---------a
///               b------b            
/// 
///   (True)
/// 
pub fn is_contiguous_2_test() {
  let a =
    day_interval.new(
      start: day.from_gtempo_literal("2015-08-01"),
      final: day.from_gtempo_literal("2015-09-23"),
    )
  let b =
    day_interval.new(
      start: day.from_gtempo_literal("2015-09-24"),
      final: day.from_gtempo_literal("2016-09-23"),
    )

  day_interval.is_contiguous(a, before: b)
  |> should.equal(True)
}

///
///    a---------a
///              b------b            
/// 
///   (False)
/// 
pub fn is_contiguous_3_test() {
  let a =
    day_interval.new(
      start: day.from_gtempo_literal("2015-08-01"),
      final: day.from_gtempo_literal("2015-09-23"),
    )
  let b =
    day_interval.new(
      start: day.from_gtempo_literal("2015-09-23"),
      final: day.from_gtempo_literal("2016-09-23"),
    )
  day_interval.is_contiguous(a, before: b)
  |> should.equal(False)
}

///
///    a---------a
///          b------b            
/// 
///   (False)
/// 
pub fn is_contiguous_4_test() {
  let a =
    day_interval.new(
      start: day.from_gtempo_literal("2015-08-01"),
      final: day.from_gtempo_literal("2015-09-23"),
    )

  let b =
    day_interval.new(
      start: day.from_gtempo_literal("2015-09-13"),
      final: day.from_gtempo_literal("2016-09-23"),
    )

  day_interval.is_contiguous(a, before: b)
  |> should.equal(False)
}
