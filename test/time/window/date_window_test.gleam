import database/raw/raw_date_window
import gleam/json
import gleam/list
import gleam/result
import gleeunit/should
import tempo/date
import tempo/datetime
import time/window/collision.{
  PointAfterFinal, PointAtFinal, PointAtStart, PointBeforeStart, PointInside,
}
import time/window/date_window.{type DateWindow}

pub fn new_single_1_test() {
  date_window.new_single(date.literal("2025-03-03"))
  |> should.equal(date_window.new(
    start: date.literal("2025-03-03"),
    final: date.literal("2025-03-03"),
  ))
}

pub fn new_single_2_test() {
  date_window.new_single(date.literal("2013-10-30"))
  |> should.equal(date_window.new(
    start: date.literal("2013-10-30"),
    final: date.literal("2013-10-30"),
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
  window window: DateWindow,
  expected_output expected_output: String,
) {
  window
  |> date_window.to_json()
  |> json.to_string()
  |> should.equal(expected_output)
}

fn json_output_input(input_and_expected_output: DateWindow) {
  let raw_date_window_decoder = raw_date_window.decoder()
  input_and_expected_output
  |> date_window.to_json()
  |> json.to_string()
  |> json.parse(using: raw_date_window_decoder)
  |> result.map(raw_date_window.normalise)
  |> should.equal(Ok(Ok(input_and_expected_output)))
}

fn example_1() {
  date_window.new(
    start: date.literal("2025-03-09"),
    final: date.literal("2025-03-10"),
  )
}

pub fn example_1_output_input_test() {
  json_output_input(example_1())
}

fn example_2() {
  date_window.new_single(date.literal("1988-12-16"))
}

pub fn example_2_output_test() {
  json_output(
    window: example_2(),
    expected_output: "{\"start\":726087,\"final\":726087}",
  )
}

pub fn example_2_output_input_test() {
  json_output_input(example_2())
}

fn example_3() {
  date_window.new(
    start: date.literal("2032-03-09"),
    final: date.literal("2033-03-16"),
  )
}

pub fn example_3_output_input_test() {
  json_output_input(example_3())
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
  date_window.new(
    start: date.literal("1999-05-01"),
    final: date.literal("1999-06-23"),
  )
  |> date_window.truncate(behind: date.literal("2000-01-01"))
  |> should.equal(Error(date_window.FinalIsLaterThanOriginal))
}

///
///   |---------|
///   n---------n
/// 
///   (same final)
///   (Ok)
/// 
pub fn truncate_2_test() {
  date_window.new(
    start: date.literal("1999-05-01"),
    final: date.literal("1999-06-23"),
  )
  |> date_window.truncate(behind: date.literal("1999-06-24"))
  |> should.equal(
    Ok(date_window.new(
      start: date.literal("1999-05-01"),
      final: date.literal("1999-06-23"),
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
  date_window.new(
    start: date.literal("1999-05-01"),
    final: date.literal("1999-06-23"),
  )
  |> date_window.truncate(behind: date.literal("1999-06-02"))
  |> should.equal(
    Ok(date_window.new(
      start: date.literal("1999-05-01"),
      final: date.literal("1999-06-01"),
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
  date_window.new(
    start: date.literal("1999-05-01"),
    final: date.literal("1999-06-23"),
  )
  |> date_window.truncate(behind: date.literal("1999-05-02"))
  |> should.equal(
    Ok(date_window.new(
      start: date.literal("1999-05-01"),
      final: date.literal("1999-05-01"),
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
  date_window.new(
    start: date.literal("1999-05-01"),
    final: date.literal("1999-06-23"),
  )
  |> date_window.truncate(behind: date.literal("1998-02-02"))
  |> should.equal(Error(date_window.FinalIsEarlierThanStart))
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -------------- to_date_list ----------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

pub fn to_date_list_1_test() {
  date_window.new(
    start: date.literal("2025-03-05"),
    final: date.literal("2025-03-05"),
  )
  |> date_window.to_date_list()
  |> list.map(date.to_string)
  |> should.equal(["2025-03-05"])
}

pub fn to_date_list_2_test() {
  date_window.new(
    start: date.literal("2025-03-05"),
    final: date.literal("2025-03-09"),
  )
  |> date_window.to_date_list()
  |> list.map(date.to_string)
  |> should.equal([
    "2025-03-05", "2025-03-06", "2025-03-07", "2025-03-08", "2025-03-09",
  ])
}

pub fn to_date_list_3_test() {
  date_window.new(
    start: date.literal("2024-10-05"),
    final: date.literal("2024-10-10"),
  )
  |> date_window.to_date_list()
  |> list.map(date.to_string)
  |> should.equal([
    "2024-10-05", "2024-10-06", "2024-10-07", "2024-10-08", "2024-10-09",
    "2024-10-10",
  ])
}

pub fn to_date_list_4_test() {
  date_window.new(
    start: date.literal("1989-12-30"),
    final: date.literal("1990-01-07"),
  )
  |> date_window.to_date_list()
  |> list.map(date.to_string)
  |> should.equal([
    "1989-12-30", "1989-12-31", "1990-01-01", "1990-01-02", "1990-01-03",
    "1990-01-04", "1990-01-05", "1990-01-06", "1990-01-07",
  ])
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ----- to_point_collision_with_date ------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///                 d
/// 
///   (PointAfterFinal)
/// 
pub fn to_point_collision_with_date_1_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_date(date.literal("2040-01-01"))
  |> should.equal(PointAfterFinal)
}

///
///   |---------|
///              d
/// 
///   (PointAfterFinal)
/// 
pub fn to_point_collision_with_date_2_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_date(date.literal("2036-09-24"))
  |> should.equal(PointAfterFinal)
}

///
///   |---------|
///             d
/// 
///   (PointAtFinal)
/// 
pub fn to_point_collision_with_date_3_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_date(date.literal("2036-09-23"))
  |> should.equal(PointAtFinal)
}

///
///   |---------|
///         d
/// 
///   (PointInside)
/// 
pub fn to_point_collision_with_date_4_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_date(date.literal("2036-08-22"))
  |> should.equal(PointInside)
}

///
///   |---------|
///   d
/// 
///   (PointAtStart)
/// 
pub fn to_point_collision_with_date_5_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_date(date.literal("2036-08-01"))
  |> should.equal(PointAtStart)
}

///
///    |---------|
///   d
/// 
///   (False)
/// 
pub fn to_point_collision_with_date_6_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_date(date.literal("2036-07-31"))
  |> should.equal(PointBeforeStart)
}

///
///       |---------|
///   d
/// 
///   (PointBeforeStart)
/// 
pub fn to_point_collision_with_date_7_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_date(date.literal("2030-11-11"))
  |> should.equal(PointBeforeStart)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------- to_point_collision_with_datetime --------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///                 d
/// 
///   (PointAfterFinal)
/// 
pub fn to_point_collision_with_datetime_1_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_datetime(datetime.literal(
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
pub fn to_point_collision_with_datetime_2_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_datetime(datetime.literal(
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
pub fn to_point_collision_with_datetime_3_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_datetime(datetime.literal(
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
pub fn to_point_collision_with_datetime_4_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_datetime(datetime.literal(
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
pub fn to_point_collision_with_datetime_5_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_datetime(datetime.literal(
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
pub fn to_point_collision_with_datetime_6_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_datetime(datetime.literal(
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
pub fn to_point_collision_with_datetime_7_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.to_point_collision_with_datetime(datetime.literal(
    "2030-11-11T00:00:00.000Z",
  ))
  |> should.equal(PointBeforeStart)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- is_around_date ---------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///                 d
/// 
///   (False)
/// 
pub fn is_around_date_1_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_date(date.literal("2040-01-01"))
  |> should.equal(False)
}

///
///   |---------|
///              d
/// 
///   (False)
/// 
pub fn is_around_date_2_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_date(date.literal("2036-09-24"))
  |> should.equal(False)
}

///
///   |---------|
///             d
/// 
///   (True)
/// 
pub fn is_around_date_3_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_date(date.literal("2036-09-23"))
  |> should.equal(True)
}

///
///   |---------|
///         d
/// 
///   (True)
/// 
pub fn is_around_date_4_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_date(date.literal("2036-08-22"))
  |> should.equal(True)
}

///
///   |---------|
///   d
/// 
///   (True)
/// 
pub fn is_around_date_5_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_date(date.literal("2036-08-01"))
  |> should.equal(True)
}

///
///    |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_date_6_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_date(date.literal("2036-07-31"))
  |> should.equal(False)
}

///
///       |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_date_7_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_date(date.literal("2030-11-11"))
  |> should.equal(False)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------- is_around_datetime --------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///   |---------|
///                 d
/// 
///   (False)
/// 
pub fn is_around_datetime_1_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_datetime(datetime.literal("2040-01-01T00:00:00.000Z"))
  |> should.equal(False)
}

///
///   |---------|
///              d
/// 
///   (False)
/// 
pub fn is_around_datetime_2_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_datetime(datetime.literal("2036-09-24T00:00:00.000Z"))
  |> should.equal(False)
}

///
///   |---------|
///             d
/// 
///   (True)
/// 
pub fn is_around_datetime_3_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_datetime(datetime.literal(
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
pub fn is_around_datetime_4_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_datetime(datetime.literal("2036-08-22T00:00:00.000Z"))
  |> should.equal(True)
}

///
///   |---------|
///   d
/// 
///   (True)
/// 
pub fn is_around_datetime_5_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_datetime(datetime.literal("2036-08-01T00:00:00.000Z"))
  |> should.equal(True)
}

///
///    |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_datetime_6_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_datetime(datetime.literal(
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
pub fn is_around_datetime_7_test() {
  date_window.new(
    start: date.literal("2036-08-01"),
    final: date.literal("2036-09-23"),
  )
  |> date_window.is_around_datetime(datetime.literal("2030-11-11T00:00:00.000Z"))
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2016-08-01"),
    final: date.literal("2016-09-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-09-23"),
    final: date.literal("2016-10-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-09-01"),
    final: date.literal("2016-10-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-01-01"),
    final: date.literal("2015-11-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-08-22"),
    final: date.literal("2015-09-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-08-14"),
    final: date.literal("2015-09-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-07-14"),
    final: date.literal("2015-09-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-10-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-09-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-08-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_inside(date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-07-15"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2016-08-01"),
    final: date.literal("2016-09-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-09-23"),
    final: date.literal("2016-10-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-09-01"),
    final: date.literal("2016-10-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-01-01"),
    final: date.literal("2015-11-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-08-22"),
    final: date.literal("2015-09-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-08-14"),
    final: date.literal("2015-09-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-07-14"),
    final: date.literal("2015-09-23"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-10-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-09-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-08-01"),
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
  date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  )
  |> date_window.is_overlapped(by: date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-07-15"),
  ))
  |> should.equal(False)
}
