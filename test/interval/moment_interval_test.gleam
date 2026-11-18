import timepoint/day
import gleeunit/should
import timepoint/interval/day_interval
import timepoint/interval/moment_interval
import timepoint/moment

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
///   (Error(EndIsLaterThanOriginal))
///
pub fn truncate_1_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("1999-06-23T00:00:00.000Z"),
  )
  |> moment_interval.truncate(behind: moment.testing_rfc3339(
    "2000-01-01T00:00:00.000Z",
  ))
  |> should.equal(Error(moment_interval.ResultIntervalIsLarger))
}

///
///   |---------|
///             n
///
///   (same final)
///   (Ok)
///
pub fn truncate_2_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("1999-06-23T00:00:00.000Z"),
  )
  |> moment_interval.truncate(behind: moment.testing_rfc3339(
    "1999-06-23T00:00:00.000Z",
  ))
  |> should.equal(
    Ok(moment_interval.new(
      start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("1999-06-23T00:00:00.000Z"),
    )),
  )
}

///
///   |---------|
///        n
///
///   (earlier final)
///   (Ok)
///
pub fn truncate_3_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("1999-06-23T00:00:00.000Z"),
  )
  |> moment_interval.truncate(behind: moment.testing_rfc3339(
    "1999-06-02T00:00:00.000Z",
  ))
  |> should.equal(
    Ok(moment_interval.new(
      start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("1999-06-02T00:00:00.000Z"),
    )),
  )
}

///
///   |---------|
///     n
///
///   (same-day final)
///   (Ok)
///
pub fn truncate_4_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("1999-06-23T00:00:00.000Z"),
  )
  |> moment_interval.truncate(behind: moment.testing_rfc3339(
    "1999-05-02T00:00:00.000Z",
  ))
  |> should.equal(
    Ok(moment_interval.new(
      start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("1999-05-02T00:00:00.000Z"),
    )),
  )
}

///
///     |---------|
///     n
///
///   (Error(EndIsAtOrEarlierThanStart))
///
pub fn truncate_5_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("1999-06-23T00:00:00.000Z"),
  )
  |> moment_interval.truncate(behind: moment.testing_rfc3339(
    "1999-05-01T00:00:00.000Z",
  ))
  |> should.equal(Error(moment_interval.ResultIntervalIsZero))
}

///
///     |---------|
/// n
///
///   (Error(EndIsAtOrEarlierThanStart))
///
pub fn truncate_6_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("1999-05-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("1999-06-23T00:00:00.000Z"),
  )
  |> moment_interval.truncate(behind: moment.testing_rfc3339(
    "1998-02-02T00:00:00.000Z",
  ))
  |> should.equal(Error(moment_interval.ResultIntervalIsZero))
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
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_day(day.testing_iso8601("2040-01-01"))
  |> should.equal(False)
}

///
///   |---------|
///              d
///
///   (False)
///
pub fn is_around_day_2_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_day(day.testing_iso8601("2036-09-24"))
  |> should.equal(False)
}

///
///   |---------|
///             d
///
///   (True)
///
pub fn is_around_day_3_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_day(day.testing_iso8601("2036-09-22"))
  |> should.equal(True)
}

///
///   |---------|
///              d
///
///   (False)
///
pub fn is_around_day_3x_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_day(day.testing_iso8601("2036-09-23"))
  |> should.equal(False)
}

///
///   |---------|
///         d
///
///   (True)
///
pub fn is_around_day_4_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_day(day.testing_iso8601("2036-08-22"))
  |> should.equal(True)
}

///
///   |---------|
///   d
///
///   (True)
///
pub fn is_around_day_5_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_day(day.testing_iso8601("2036-08-01"))
  |> should.equal(True)
}

///
///    |---------|
///   d
///
///   (False)
///
pub fn is_around_day_6_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_day(day.testing_iso8601("2036-07-31"))
  |> should.equal(False)
}

///
///       |---------|
///   d
///
///   (False)
///
pub fn is_around_day_7_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_day(day.testing_iso8601("2030-11-11"))
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
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_moment(moment.testing_rfc3339(
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
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_moment(moment.testing_rfc3339(
    "2036-09-24T00:00:00.000Z",
  ))
  |> should.equal(False)
}

///
///   |---------|
///             d
///
///   (at end_excluding by 1ms)
///   (False)
///
pub fn is_around_moment_3_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_moment(moment.testing_rfc3339(
    "2036-09-23T00:00:00.000Z",
  ))
  |> should.equal(False)
}

///
///   |---------|
///              d
///
///   (off by 1ms)
///   (False)
///
pub fn is_around_moment_3x_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_moment(moment.testing_rfc3339(
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
pub fn is_around_moment_4_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_moment(moment.testing_rfc3339(
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
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_moment(moment.testing_rfc3339(
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
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_moment(moment.testing_rfc3339(
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
  moment_interval.new(
    start: moment.testing_rfc3339("2036-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2036-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_around_moment(moment.testing_rfc3339(
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2016-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2016-09-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2016-10-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-09-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2016-10-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-01-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-11-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-08-22T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-08-14T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-07-14T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-10-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-05-09T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-05-09T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_inside(moment_interval.new(
    start: moment.testing_rfc3339("2015-05-09T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-07-15T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2016-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2016-09-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2016-10-23T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///              b------b
///
///   (end_excluding on start)
///   (False)
///
pub fn is_overlapped_2x_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2016-10-23T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///
///    a---------a
///           b------b
///
///   (True)
///
pub fn is_overlapped_3_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-09-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2016-10-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-01-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-11-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-08-22T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-08-14T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-07-14T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-10-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-05-09T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-01T00:00:00.000Z"),
  ))
  |> should.equal(True)
}

///
///        a---------a
///  b-----b
///
///   (start on end_excluding)
///   (False)
///
pub fn is_overlapped_12_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-05-09T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

///
///         a---------a
///  b-----b
///
///   (out by 1ms)
///   (False)
///
pub fn is_overlapped_12x_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-05-09T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
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
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped(by: moment_interval.new(
    start: moment.testing_rfc3339("2015-05-09T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-07-15T00:00:00.000Z"),
  ))
  |> should.equal(False)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -------- is_overlapped_by_day_interval ---------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///    t---------t
///                   d------d
///
///   (False)
///
pub fn is_overlapped_by_day_interval_1_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2016-08-01"),
    final: day.testing_iso8601("2016-09-23"),
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
pub fn is_overlapping_day_interval_2_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-09-23"),
    final: day.testing_iso8601("2016-10-23"),
  ))
  |> should.equal(False)
}

///
///    t---------t
///              d------d
///
///   (at end_excluding by 1ms)
///   (False)
///
pub fn is_overlapping_day_interval_2x_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-09-23"),
    final: day.testing_iso8601("2016-10-23"),
  ))
  |> should.equal(False)
}

///
///    t---------t
///           d------d
///
///   (True)
///
pub fn is_overlapping_day_interval_3_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-09-01"),
    final: day.testing_iso8601("2016-10-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///  d-------------d
///
///   (True)
///
pub fn is_overlapping_day_interval_4_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-01-01"),
    final: day.testing_iso8601("2015-11-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///    d---------d
///
///   (True)
///
pub fn is_overlapping_day_interval_5_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-08-01"),
    final: day.testing_iso8601("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///      d-----d
///
///   (True)
///
pub fn is_overlapping_day_interval_6_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-08-22"),
    final: day.testing_iso8601("2015-09-01"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///        d-----d
///
///   (True)
///
pub fn is_overlapping_day_interval_7_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-08-14"),
    final: day.testing_iso8601("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///        t-----t
///    d---------d
///
///   (True)
///
pub fn is_overlapping_day_interval_8_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-07-14"),
    final: day.testing_iso8601("2015-09-23"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///    d-----d
///
///   (True)
///
pub fn is_overlapping_day_interval_9_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-08-01"),
    final: day.testing_iso8601("2015-09-01"),
  ))
  |> should.equal(True)
}

///
///    t------t
///    d---------d
///
///   (True)
///
pub fn is_overlapping_day_interval_10_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-08-01"),
    final: day.testing_iso8601("2015-10-01"),
  ))
  |> should.equal(True)
}

///
///    t---------t
///  d-----d
///
///   (True)
///
pub fn is_overlapping_day_interval_11_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-05-09"),
    final: day.testing_iso8601("2015-09-01"),
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
pub fn is_overlapping_day_interval_12_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-05-09"),
    final: day.testing_iso8601("2015-08-01"),
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
pub fn is_overlapping_day_interval_12a_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2025-02-02T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2025-02-04T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2025-02-03"),
    final: day.testing_iso8601("2025-02-25"),
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
pub fn is_overlapping_day_interval_12x_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-05-09"),
    final: day.testing_iso8601("2015-07-31"),
  ))
  |> should.equal(False)
}

///
///          t---------t
///  d-----d
///
///   (False)
///
pub fn is_overlapping_day_interval_13_test() {
  moment_interval.new(
    start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
    end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
  )
  |> moment_interval.is_overlapped_by_day_interval(by: day_interval.new(
    start: day.testing_iso8601("2015-05-09"),
    final: day.testing_iso8601("2015-07-15"),
  ))
  |> should.equal(False)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// --------------- is_contiguous -----------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

///
///    a-------a
///                   b------b
///
///   (False)
///
pub fn is_contiguous_1_test() {
  let a =
    moment_interval.new(
      start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
    )

  let b =
    moment_interval.new(
      start: moment.testing_rfc3339("2016-08-01T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("2016-09-23T00:00:00.000Z"),
    )

  moment_interval.is_contiguous(a, before: b)
  |> should.equal(False)
}

///
///    a---------a
///               b------b
///
///   (False)
///
pub fn is_contiguous_2_test() {
  let a =
    moment_interval.new(
      // one microsecond ahead
      start: moment.testing_rfc3339("2015-07-23T00:00:00.001Z"),
      end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
    )

  let b =
    moment_interval.new(
      start: moment.testing_rfc3339("2015-09-24T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("2015-09-26T00:00:00.000Z"),
    )

  moment_interval.is_contiguous(a, before: b)
  |> should.equal(False)
}

///
///    a---------a
///              b------b
///
///   (True)
///
pub fn is_contiguous_3_test() {
  let a =
    moment_interval.new(
      start: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("2015-09-24T00:00:00.000Z"),
    )

  let b =
    moment_interval.new(
      start: moment.testing_rfc3339("2015-09-24T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("2015-09-29T00:00:00.000Z"),
    )

  moment_interval.is_contiguous(a, before: b)
  |> should.equal(True)
}

///
///    a---------a
///            b------b
///
///   (False)
///
pub fn is_contiguous_4_test() {
  let a =
    moment_interval.new(
      // 2h behind
      start: moment.testing_rfc3339("2015-09-22T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("2016-09-23T00:00:00.000Z"),
    )

  let b =
    moment_interval.new(
      start: moment.testing_rfc3339("2015-08-01T00:00:00.000Z"),
      end_excluding: moment.testing_rfc3339("2015-09-23T00:00:00.000Z"),
    )

  moment_interval.is_contiguous(a, before: b)
  |> should.equal(False)
}
