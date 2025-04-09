import database/raw/raw_datetime_window
import gleam/json
import gleam/result
import gleam/string
import gleeunit/should
import tempo.{type DateTime}
import tempo/date
import tempo/datetime
import time/window/date_window
import time/window/datetime_window.{type DateTimeWindow}

fn datetime_with_border_time(str: String) -> DateTime {
  datetime.literal(string.append(str, "T23:59:59.999+00:00"))
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- JSON ------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

fn json_output(
  window window: DateTimeWindow,
  expected_output expected_output: String,
) {
  window
  |> datetime_window.to_json()
  |> json.to_string()
  |> should.equal(expected_output)
}

fn json_output_input(input_and_expected_output: DateTimeWindow) {
  let decoder = raw_datetime_window.decoder()
  input_and_expected_output
  |> datetime_window.to_json()
  |> json.to_string
  |> json.parse(using: decoder)
  |> result.map(raw_datetime_window.normalise)
  |> should.equal(Ok(Ok(input_and_expected_output)))
}

fn example_1() {
  datetime_window.new_with_final(
    start: datetime.literal("2025-03-09T00:00:00.000Z"),
    final: datetime.literal("2025-03-10T00:00:00.000Z"),
  )
}

pub fn example_1_output_test() {
  json_output(
    window: example_1(),
    expected_output: "{\"start\":{\"unix_milli\":1741478400000,\"offset\":0},\"final\":{\"unix_milli\":1741564800000,\"offset\":0}}",
  )
}

pub fn example_1_output_input_test() {
  json_output_input(example_1())
}

fn example_2() {
  datetime_window.new_with_final(
    start: datetime.literal("1988-12-16T00:00:00.000Z"),
    final: datetime.literal("1988-12-17T00:00:00.000Z"),
  )
}

pub fn example_2_output_test() {
  json_output(
    window: example_2(),
    expected_output: "{\"start\":{\"unix_milli\":598233600000,\"offset\":0},\"final\":{\"unix_milli\":598320000000,\"offset\":0}}",
  )
}

pub fn example_2_output_input_test() {
  json_output_input(example_2())
}

fn example_3() {
  datetime_window.new_with_final(
    start: datetime.literal("2032-03-09T00:00:00.000Z"),
    final: datetime.literal("2033-03-16T00:00:00.000Z"),
  )
}

pub fn example_3_output_test() {
  json_output(
    window: example_3(),
    expected_output: "{\"start\":{\"unix_milli\":1962403200000,\"offset\":0},\"final\":{\"unix_milli\":1994544000000,\"offset\":0}}",
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
  datetime_window.new(
    start: datetime.literal("1999-05-01T00:00:00.000Z"),
    end_excluding: datetime.literal("1999-06-23T00:00:00.000Z"),
  )
  |> datetime_window.truncate(behind: datetime.literal(
    "2000-01-01T00:00:00.000Z",
  ))
  |> should.equal(Error(datetime_window.FinalIsLaterThanOriginal))
}

///
///   |---------|
///   n---------n
/// 
///   (same final)
///   (Ok)
/// 
pub fn truncate_2_test() {
  datetime_window.new(
    start: datetime.literal("1999-05-01T00:00:00.000Z"),
    end_excluding: datetime.literal("1999-06-23T00:00:00.000Z"),
  )
  |> datetime_window.truncate(behind: datetime.literal(
    "1999-06-23T00:00:00.000Z",
  ))
  |> should.equal(
    Ok(datetime_window.new_with_final(
      start: datetime.literal("1999-05-01T00:00:00.000Z"),
      final: datetime_with_border_time("1999-06-22"),
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
  datetime_window.new(
    start: datetime.literal("1999-05-01T00:00:00.000Z"),
    end_excluding: datetime.literal("1999-06-23T00:00:00.000Z"),
  )
  |> datetime_window.truncate(behind: datetime.literal(
    "1999-06-02T00:00:00.000Z",
  ))
  |> should.equal(
    Ok(datetime_window.new_with_final(
      start: datetime.literal("1999-05-01T00:00:00.000Z"),
      final: datetime_with_border_time("1999-06-01"),
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
  datetime_window.new(
    start: datetime.literal("1999-05-01T00:00:00.000Z"),
    end_excluding: datetime.literal("1999-06-23T00:00:00.000Z"),
  )
  |> datetime_window.truncate(behind: datetime.literal(
    "1999-05-02T00:00:00.000Z",
  ))
  |> should.equal(
    Ok(datetime_window.new_with_final(
      start: datetime.literal("1999-05-01T00:00:00.000Z"),
      final: datetime_with_border_time("1999-05-01"),
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
  datetime_window.new(
    start: datetime.literal("1999-05-01T00:00:00.000Z"),
    end_excluding: datetime.literal("1999-06-23T00:00:00.000Z"),
  )
  |> datetime_window.truncate(behind: datetime.literal(
    "1998-02-02T00:00:00.000Z",
  ))
  |> should.equal(Error(datetime_window.FinalIsEarlierThanStart))
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
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_date(date.literal("2040-01-01"))
  |> should.equal(False)
}

///
///   |---------|
///              d
/// 
///   (False)
/// 
pub fn is_around_date_2_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_date(date.literal("2036-09-24"))
  |> should.equal(False)
}

///
///   |---------|
///             d
/// 
///   (True)
/// 
pub fn is_around_date_3_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_date(date.literal("2036-09-22"))
  |> should.equal(True)
}

///
///   |---------|
///              d
/// 
///   (False)
/// 
pub fn is_around_date_3x_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_date(date.literal("2036-09-23"))
  |> should.equal(False)
}

///
///   |---------|
///         d
/// 
///   (True)
/// 
pub fn is_around_date_4_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_date(date.literal("2036-08-22"))
  |> should.equal(True)
}

///
///   |---------|
///   d
/// 
///   (True)
/// 
pub fn is_around_date_5_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_date(date.literal("2036-08-01"))
  |> should.equal(True)
}

///
///    |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_date_6_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_date(date.literal("2036-07-31"))
  |> should.equal(False)
}

///
///       |---------|
///   d
/// 
///   (False)
/// 
pub fn is_around_date_7_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_date(date.literal("2030-11-11"))
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
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_datetime(datetime.literal(
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
pub fn is_around_datetime_2_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_datetime(datetime.literal(
    "2036-09-24T00:00:00.000Z",
  ))
  |> should.equal(False)
}

///
///   |---------|
///             d
/// 
///   (in by 1ms)
///   (True)
/// 
pub fn is_around_datetime_3_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_datetime(datetime_with_border_time("2036-09-22"))
  |> should.equal(True)
}

///
///   |---------|
///              d
///   
///   (off by 1ms)
///   (False)
/// 
pub fn is_around_datetime_3x_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_datetime(datetime.literal(
    "2036-09-23T00:00:00.000Z",
  ))
  |> should.equal(False)
}

///
///   |---------|
///         d
/// 
///   (True)
/// 
pub fn is_around_datetime_4_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_datetime(datetime.literal(
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
pub fn is_around_datetime_5_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_datetime(datetime.literal(
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
pub fn is_around_datetime_6_test() {
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_datetime(datetime.literal(
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
  datetime_window.new(
    start: datetime.literal("2036-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2036-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_around_datetime(datetime.literal(
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2016-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2016-09-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-09-23T00:00:00.000Z"),
    end_excluding: datetime.literal("2016-10-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-09-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2016-10-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-01-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-11-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-08-22T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-01T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-08-14T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-07-14T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-01T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-10-01T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-05-09T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-01T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-05-09T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-08-01T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_inside(datetime_window.new(
    start: datetime.literal("2015-05-09T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-07-15T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2016-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2016-09-23T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///               b------b  
///           
///   (off by 1ms)
///   (False)
/// 
pub fn is_overlapped_2_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-09-23T00:00:00.000Z"),
    end_excluding: datetime.literal("2016-10-23T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///              b------b            
/// 
///   (in by 1ms)
///   (True)
/// 
pub fn is_overlapped_2x_test() {
  datetime_window.new_with_final(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    final: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-09-23T00:00:00.000Z"),
    end_excluding: datetime.literal("2016-10-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-09-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2016-10-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-01-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-11-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-08-22T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-01T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-08-14T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-07-14T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-01T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-10-01T00:00:00.000Z"),
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
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-05-09T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-01T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///
///        a---------a
///  b-----b            
/// 
///   (in by 1ms)
///   (True)
/// 
pub fn is_overlapped_12_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new_with_final(
    start: datetime.literal("2015-05-09T00:00:00.000Z"),
    final: datetime.literal("2015-08-01T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///
///         a---------a
///  b-----b            
/// 
///   (out by 1ms)
///   (False)
/// 
pub fn is_overlapped_12x_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-05-09T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-08-01T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///
///          a---------a
///  b-----b            
/// 
///   (False)
/// 
pub fn is_overlapped_13_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped(by: datetime_window.new(
    start: datetime.literal("2015-05-09T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-07-15T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -------- is_overlapped_by_date_window ---------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///    t---------t
///                   d------d            
/// 
///   (False)
/// 
pub fn is_overlapped_by_date_window_1_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2016-08-01"),
    final: date.literal("2016-09-23"),
  ))
  |> should.equal(False)
}

///
///    t---------t
///               d------d  
///           
///   (off by 1ms)
///   (False)
/// 
pub fn is_overlapping_date_window_2_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-09-23"),
    final: date.literal("2016-10-23"),
  ))
  |> should.equal(False)
}

///
///    t---------t
///              d------d            
/// 
///   (in by 1ms)
///   (True)
/// 
pub fn is_overlapping_date_window_2x_test() {
  datetime_window.new_with_final(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    final: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-09-23"),
    final: date.literal("2016-10-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///           d------d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_3_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-09-01"),
    final: date.literal("2016-10-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///  d-------------d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_4_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-01-01"),
    final: date.literal("2015-11-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///    d---------d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_5_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///      d-----d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_6_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-08-22"),
    final: date.literal("2015-09-01"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///        d-----d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_7_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-08-14"),
    final: date.literal("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///        t-----t
///    d---------d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_8_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-07-14"),
    final: date.literal("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///    d-----d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_9_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-09-01"),
  ))
  |> should.equal(True)
}

///
///    t------t
///    d---------d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_10_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-08-01"),
    final: date.literal("2015-10-01"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///  d-----d            
/// 
///   (True)
/// 
pub fn is_overlapping_date_window_11_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-09-01"),
  ))
  |> should.equal(True)
}

///
///        t---------t
///  d-----d            
/// 
///   (in by 1ms)
///   (True)
/// 
pub fn is_overlapping_date_window_12_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-08-01"),
  ))
  |> should.equal(True)
}

///
///         t---------t
///  d-----d            
/// 
///   (out by 1ms)
///   (False)
/// 
pub fn is_overlapping_date_window_12x_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-07-31"),
  ))
  |> should.equal(False)
}

///
///          t---------t
///  d-----d            
/// 
///   (False)
/// 
pub fn is_overlapping_date_window_13_test() {
  datetime_window.new(
    start: datetime.literal("2015-08-01T00:00:00.000Z"),
    end_excluding: datetime.literal("2015-09-23T00:00:00.000Z"),
  )
  |> datetime_window.is_overlapped_by_date_window(by: date_window.new(
    start: date.literal("2015-05-09"),
    final: date.literal("2015-07-15"),
  ))
  |> should.equal(False)
}
