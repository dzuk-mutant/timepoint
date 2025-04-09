import gleeunit/should
import tempo/date
import time/week_date

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------------- from_date -------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn from_date_1_test() {
  date.literal("2016-11-05")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2016, week: 44, day: 6))
}

pub fn from_date_2_test() {
  date.literal("2024-09-11")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2024, week: 37, day: 3))
}

pub fn from_date_3_test() {
  date.literal("1991-04-14")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 1991, week: 15, day: 7))
}

pub fn from_date_4_test() {
  date.literal("1999-07-15")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 1999, week: 28, day: 4))
}

pub fn from_date_5_test() {
  date.literal("2013-10-30")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2013, week: 44, day: 3))
}

// border case 1 -------------------------------------

pub fn from_date_year_border_1_1_test() {
  date.literal("2024-12-30")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2025, week: 1, day: 1))
}

pub fn from_date_year_border_1_2_test() {
  date.literal("2024-12-31")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2025, week: 1, day: 2))
}

pub fn from_date_year_border_1_3_test() {
  date.literal("2025-01-01")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2025, week: 1, day: 3))
}

// border case 2 -------------------------------------

pub fn from_date_year_border_2_1_test() {
  date.literal("2005-01-01")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2004, week: 53, day: 6))
}

pub fn from_date_year_border_2_2_test() {
  date.literal("2005-01-02")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2004, week: 53, day: 7))
}

// border case 3 -------------------------------------

pub fn from_date_year_border_3_1_test() {
  date.literal("2005-12-31")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2005, week: 52, day: 6))
}

pub fn from_date_year_border_3_2_test() {
  date.literal("2006-01-01")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2005, week: 52, day: 7))
}

pub fn from_date_year_border_3_3_test() {
  date.literal("2006-01-02")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2006, week: 1, day: 1))
}

// border case 4 -------------------------------------

pub fn from_date_year_border_4_1_test() {
  date.literal("2007-12-30")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2007, week: 52, day: 7))
}

pub fn from_date_year_border_4_2_test() {
  date.literal("2007-12-31")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2008, week: 1, day: 1))
}

pub fn from_date_year_border_4_3_test() {
  date.literal("2008-01-01")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2008, week: 1, day: 2))
}

// border case 5 -------------------------------------

pub fn from_date_year_border_5_1_test() {
  date.literal("2008-12-28")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2008, week: 52, day: 7))
}

pub fn from_date_year_border_5_2_test() {
  date.literal("2008-12-29")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2009, week: 1, day: 1))
}

pub fn from_date_year_border_5_3_test() {
  date.literal("2008-12-30")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2009, week: 1, day: 2))
}

pub fn from_date_year_border_5_4_test() {
  date.literal("2008-12-31")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2009, week: 1, day: 3))
}

pub fn from_date_year_border_5_5_test() {
  date.literal("2009-01-01")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2009, week: 1, day: 4))
}

// border case 6 -------------------------------------

pub fn from_date_year_border_6_1_test() {
  date.literal("2009-12-31")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2009, week: 53, day: 4))
}

pub fn from_date_year_border_6_2_test() {
  date.literal("2010-01-01")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2009, week: 53, day: 5))
}

pub fn from_date_year_border_6_3_test() {
  date.literal("2010-01-02")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2009, week: 53, day: 6))
}

pub fn from_date_year_border_6_4_test() {
  date.literal("2010-01-03")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2009, week: 53, day: 7))
}

// border case 7 -------------------------------------

pub fn from_date_year_border_7_1_test() {
  date.literal("2023-12-31")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2023, week: 52, day: 7))
}

pub fn from_date_year_border_7_2_test() {
  date.literal("2024-01-01")
  |> week_date.from_date
  |> should.equal(week_date.unsafe_from_values(year: 2024, week: 1, day: 1))
}

// ----------------------------------------------------
// ----------------------------------------------------
// ---------------------- to record -------------------
// ----------------------------------------------------
// ----------------------------------------------------

pub fn to_year_of_week_date_1_test() {
  date.literal("2013-10-30")
  |> week_date.from_date
  |> week_date.to_year
  |> should.equal(2013)
}

pub fn to_ordinal_week_1_teat() {
  date.literal("2013-10-30")
  |> week_date.from_date
  |> week_date.to_week
  |> should.equal(44)
}

pub fn to_normalised_day_of_week_number_1_teat() {
  date.literal("2013-10-30")
  |> week_date.from_date
  |> week_date.to_day
  |> should.equal(3)
}
