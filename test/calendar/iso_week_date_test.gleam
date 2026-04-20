import calendar/iso_week_date
import day
import gleeunit/should

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------------- from_day -------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn from_date_1_test() {
  let day = day.testing_iso8601("2016-11-05")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2016,
    week_no: 44,
    day_no: 6,
    day:,
  ))
}

pub fn from_date_2_test() {
  let day = day.testing_iso8601("2024-09-11")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2024,
    week_no: 37,
    day_no: 3,
    day:,
  ))
}

pub fn from_date_3_test() {
  let day = day.testing_iso8601("1991-04-14")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 1991,
    week_no: 15,
    day_no: 7,
    day:,
  ))
}

pub fn from_date_4_test() {
  let day = day.testing_iso8601("1999-07-15")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 1999,
    week_no: 28,
    day_no: 4,
    day:,
  ))
}

pub fn from_date_5_test() {
  let day = day.testing_iso8601("2013-10-30")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2013,
    week_no: 44,
    day_no: 3,
    day:,
  ))
}

// border case 1 -------------------------------------

pub fn from_date_year_border_1_1_test() {
  let day = day.testing_iso8601("2024-12-30")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2025,
    week_no: 1,
    day_no: 1,
    day:,
  ))
}

pub fn from_date_year_border_1_2_test() {
  let day = day.testing_iso8601("2024-12-31")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2025,
    week_no: 1,
    day_no: 2,
    day:,
  ))
}

pub fn from_date_year_border_1_3_test() {
  let day = day.testing_iso8601("2025-01-01")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2025,
    week_no: 1,
    day_no: 3,
    day:,
  ))
}

// border case 2 -------------------------------------

pub fn from_date_year_border_2_1_test() {
  let day = day.testing_iso8601("2005-01-01")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2004,
    week_no: 53,
    day_no: 6,
    day:,
  ))
}

pub fn from_date_year_border_2_2_test() {
  let day = day.testing_iso8601("2005-01-02")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2004,
    week_no: 53,
    day_no: 7,
    day:,
  ))
}

// border case 3 -------------------------------------

pub fn from_date_year_border_3_1_test() {
  let day = day.testing_iso8601("2005-12-31")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2005,
    week_no: 52,
    day_no: 6,
    day:,
  ))
}

pub fn from_date_year_border_3_2_test() {
  let day = day.testing_iso8601("2006-01-01")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2005,
    week_no: 52,
    day_no: 7,
    day:,
  ))
}

pub fn from_date_year_border_3_3_test() {
  let day = day.testing_iso8601("2006-01-02")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2006,
    week_no: 1,
    day_no: 1,
    day:,
  ))
}

// border case 4 -------------------------------------

pub fn from_date_year_border_4_1_test() {
  let day = day.testing_iso8601("2007-12-30")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2007,
    week_no: 52,
    day_no: 7,
    day:,
  ))
}

pub fn from_date_year_border_4_2_test() {
  let day = day.testing_iso8601("2007-12-31")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2008,
    week_no: 1,
    day_no: 1,
    day:,
  ))
}

pub fn from_date_year_border_4_3_test() {
  let day = day.testing_iso8601("2008-01-01")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2008,
    week_no: 1,
    day_no: 2,
    day:,
  ))
}

// border case 5 -------------------------------------

pub fn from_date_year_border_5_1_test() {
  let day = day.testing_iso8601("2008-12-28")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2008,
    week_no: 52,
    day_no: 7,
    day:,
  ))
}

pub fn from_date_year_border_5_2_test() {
  let day = day.testing_iso8601("2008-12-29")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2009,
    week_no: 1,
    day_no: 1,
    day:,
  ))
}

pub fn from_date_year_border_5_3_test() {
  let day = day.testing_iso8601("2008-12-30")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2009,
    week_no: 1,
    day_no: 2,
    day:,
  ))
}

pub fn from_date_year_border_5_4_test() {
  let day = day.testing_iso8601("2008-12-31")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2009,
    week_no: 1,
    day_no: 3,
    day:,
  ))
}

pub fn from_date_year_border_5_5_test() {
  let day = day.testing_iso8601("2009-01-01")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2009,
    week_no: 1,
    day_no: 4,
    day:,
  ))
}

// border case 6 -------------------------------------

pub fn from_date_year_border_6_1_test() {
  let day = day.testing_iso8601("2009-12-31")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2009,
    week_no: 53,
    day_no: 4,
    day:,
  ))
}

pub fn from_date_year_border_6_2_test() {
  let day = day.testing_iso8601("2010-01-01")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2009,
    week_no: 53,
    day_no: 5,
    day:,
  ))
}

pub fn from_date_year_border_6_3_test() {
  let day = day.testing_iso8601("2010-01-02")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2009,
    week_no: 53,
    day_no: 6,
    day:,
  ))
}

pub fn from_date_year_border_6_4_test() {
  let day = day.testing_iso8601("2010-01-03")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2009,
    week_no: 53,
    day_no: 7,
    day:,
  ))
}

// border case 7 -------------------------------------

pub fn from_date_year_border_7_1_test() {
  let day = day.testing_iso8601("2023-12-31")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2023,
    week_no: 52,
    day_no: 7,
    day:,
  ))
}

pub fn from_date_year_border_7_2_test() {
  let day = day.testing_iso8601("2024-01-01")

  day
  |> iso_week_date.from_day
  |> should.equal(iso_week_date.unsafe_from_values(
    year: 2024,
    week_no: 1,
    day_no: 1,
    day:,
  ))
}

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------------- to record -------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn to_year_of_week_date_1_test() {
  day.testing_iso8601("2013-10-30")
  |> iso_week_date.from_day
  |> iso_week_date.to_year
  |> should.equal(2013)
}

pub fn to_ordinal_week_1_teat() {
  day.testing_iso8601("2013-10-30")
  |> iso_week_date.from_day
  |> iso_week_date.to_week_number
  |> should.equal(44)
}

pub fn to_normalised_day_of_week_number_1_teat() {
  day.testing_iso8601("2013-10-30")
  |> iso_week_date.from_day
  |> iso_week_date.to_day_number
  |> should.equal(3)
}
