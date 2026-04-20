//// From gleam/time/timestamp

import gleam/bit_array
import gleam/result
import offset.{type Offset}

const seconds_per_day: Int = 86_400

const seconds_per_hour: Int = 3600

const seconds_per_minute: Int = 60

const nanoseconds_per_second: Int = 1_000_000_000

/// The `:` character as a byte
const byte_colon: Int = 0x3A

/// The `-` character as a byte
const byte_minus: Int = 0x2D

/// The `0` character as a byte
const byte_zero: Int = 0x30

/// The `9` character as a byte
const byte_nine: Int = 0x39

/// The `t` character as a byte
const byte_t_lowercase: Int = 0x74

/// The `T` character as a byte
const byte_t_uppercase: Int = 0x54

/// The `T` character as a byte
const byte_space: Int = 0x20

/// The Julian seconds of the UNIX epoch (Julian day is 2_440_588)
const julian_seconds_unix_epoch: Int = 210_866_803_200

/// An intermediate format used by Timestamp and Moment.
pub type IntermediateStructure {
  IntermediateStructure(seconds: Int, nanoseconds: Int, offset: Offset)
}

/// Ensure the time is represented with `nanoseconds` being positive and less
/// than 1 second.
///
/// This function does not change the time that the timestamp refers to, it
/// only adjusts the values used to represent the time.
///
fn normalise(pt: IntermediateStructure) -> IntermediateStructure {
  let multiplier = 1_000_000_000
  let nanoseconds = pt.nanoseconds % multiplier
  let overflow = pt.nanoseconds - nanoseconds
  let seconds = pt.seconds + overflow / multiplier
  case nanoseconds >= 0 {
    True -> IntermediateStructure(..pt, seconds:, nanoseconds:)
    False ->
      IntermediateStructure(
        ..pt,
        seconds: seconds - 1,
        nanoseconds: multiplier + nanoseconds,
      )
  }
}

/// Parses an [RFC 3339 formatted time string][spec] into a `ParsedDateTime`.
///
/// [spec]: https://datatracker.ietf.org/doc/html/rfc3339#section-5.6
/// 
/// # Examples
///
/// ```gleam
/// let assert Ok(ts) = timestamp.parse_rfc3339("1970-01-01T00:00:01Z")
/// timestamp.to_unix_seconds_and_nanoseconds(ts)
/// // -> #(1, 0)
/// ```
/// 
/// Parsing an invalid timestamp returns an error.
/// 
/// ```gleam
/// let assert Error(Nil) = timestamp.parse_rfc3339("1995-10-31")
/// ```
///
/// ## Time zones
///
/// It may at first seem that the RFC 3339 format includes timezone
/// information, as it can specify an offset such as `Z` or `+3`, so why does
/// this function not return calendar time with a time zone? There are multiple
/// reasons:
///
/// - RFC 3339's timestamp format is based on calendar time, but it is
///   unambigous, so it can be converted into epoch time when being parsed. It
///   is always better to internally use epoch time to represent unambiguous
///   points in time, so we perform that conversion as a convenience and to
///   ensure that programmers with less time experience don't accidentally use
///   a less suitable time representation.
///
/// - RFC 3339's contains _calendar time offset_ information, not time zone
///   information. This is enough to convert it to an unambiguous timestamp,
///   but it is not enough information to reliably work with calendar time.
///   Without the time zone and the time zone database it's not possible to
///   know what time period that offset is valid for, so it cannot be used
///   without risk of bugs.
///
/// ## Behaviour details
/// 
/// - Follows the grammar specified in section 5.6 Internet Date/Time Format of 
///   RFC 3339 <https://datatracker.ietf.org/doc/html/rfc3339#section-5.6>.
/// - The `T` and `Z` characters may alternatively be lower case `t` or `z`, 
///   respectively.
/// - Full dates and full times must be separated by `T` or `t`. A space is also 
///   permitted.
/// - Leap seconds rules are not considered.  That is, any timestamp may 
///   specify digts `00` - `60` for the seconds.
/// - Any part of a fractional second that cannot be represented in the 
///   nanosecond precision is tructated.  That is, for the time string, 
///   `"1970-01-01T00:00:00.1234567899Z"`, the fractional second `.1234567899` 
///   will be represented as `123_456_789` in the `Timestamp`.
/// 
pub fn parse(input: String) -> Result(IntermediateStructure, Nil) {
  let bytes = bit_array.from_string(input)

  // Date 
  use #(year, bytes) <- result.try(parse_year(from: bytes))
  use bytes <- result.try(accept_byte(from: bytes, value: byte_minus))
  use #(month, bytes) <- result.try(parse_month(from: bytes))
  use bytes <- result.try(accept_byte(from: bytes, value: byte_minus))
  use #(day, bytes) <- result.try(parse_day(from: bytes, year:, month:))

  use bytes <- result.try(accept_date_time_separator(from: bytes))

  // Time 
  use #(hours, bytes) <- result.try(parse_hours(from: bytes))
  use bytes <- result.try(accept_byte(from: bytes, value: byte_colon))
  use #(minutes, bytes) <- result.try(parse_minutes(from: bytes))
  use bytes <- result.try(accept_byte(from: bytes, value: byte_colon))
  use #(seconds, bytes) <- result.try(parse_seconds(from: bytes))
  use #(second_fraction_as_nanoseconds, bytes) <- result.try(
    parse_second_fraction_as_nanoseconds(from: bytes),
  )

  // Offset
  use #(offset_seconds, bytes) <- result.try(parse_offset(from: bytes))

  // Done
  use Nil <- result.try(accept_empty(bytes))

  Ok(from_date_time(
    year:,
    month:,
    day:,
    hours:,
    minutes:,
    seconds:,
    second_fraction_as_nanoseconds:,
    offset_seconds:,
  ))
}

fn parse_year(from bytes: BitArray) -> Result(#(Int, BitArray), Nil) {
  parse_digits(from: bytes, count: 4)
}

fn parse_month(from bytes: BitArray) -> Result(#(Int, BitArray), Nil) {
  use #(month, bytes) <- result.try(parse_digits(from: bytes, count: 2))
  case 1 <= month && month <= 12 {
    True -> Ok(#(month, bytes))
    False -> Error(Nil)
  }
}

fn parse_day(
  from bytes: BitArray,
  year year,
  month month,
) -> Result(#(Int, BitArray), Nil) {
  use #(day, bytes) <- result.try(parse_digits(from: bytes, count: 2))

  use max_day <- result.try(case month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 -> Ok(31)
    4 | 6 | 9 | 11 -> Ok(30)
    2 -> {
      case is_leap_year(year) {
        True -> Ok(29)
        False -> Ok(28)
      }
    }
    _ -> Error(Nil)
  })

  case 1 <= day && day <= max_day {
    True -> Ok(#(day, bytes))
    False -> Error(Nil)
  }
}

// Implementation from RFC 3339 Appendix C
fn is_leap_year(year: Int) -> Bool {
  year % 4 == 0 && { year % 100 != 0 || year % 400 == 0 }
}

fn parse_hours(from bytes: BitArray) -> Result(#(Int, BitArray), Nil) {
  use #(hours, bytes) <- result.try(parse_digits(from: bytes, count: 2))
  case 0 <= hours && hours <= 23 {
    True -> Ok(#(hours, bytes))
    False -> Error(Nil)
  }
}

fn parse_minutes(from bytes: BitArray) -> Result(#(Int, BitArray), Nil) {
  use #(minutes, bytes) <- result.try(parse_digits(from: bytes, count: 2))
  case 0 <= minutes && minutes <= 59 {
    True -> Ok(#(minutes, bytes))
    False -> Error(Nil)
  }
}

fn parse_seconds(from bytes: BitArray) -> Result(#(Int, BitArray), Nil) {
  use #(seconds, bytes) <- result.try(parse_digits(from: bytes, count: 2))
  // Max of 60 for leap seconds.  We don't bother to check if this leap second
  // actually occurred in the past or not.
  case 0 <= seconds && seconds <= 60 {
    True -> Ok(#(seconds, bytes))
    False -> Error(Nil)
  }
}

// Truncates any part of the fraction that is beyond the nanosecond precision.
fn parse_second_fraction_as_nanoseconds(from bytes: BitArray) {
  case bytes {
    <<".", byte, remaining_bytes:bytes>>
      if byte_zero <= byte && byte <= byte_nine
    -> {
      do_parse_second_fraction_as_nanoseconds(
        from: <<byte, remaining_bytes:bits>>,
        acc: 0,
        power: nanoseconds_per_second,
      )
    }
    // bytes starts with a ".", which should introduce a fraction, but it does
    // not, and so it is an ill-formed input.
    <<".", _:bytes>> -> Error(Nil)
    // bytes does not start with a "." so there is no fraction.  Call this 0
    // nanoseconds.
    _ -> Ok(#(0, bytes))
  }
}

fn do_parse_second_fraction_as_nanoseconds(
  from bytes: BitArray,
  acc acc: Int,
  power power: Int,
) -> Result(#(Int, BitArray), a) {
  // Each digit place to the left in the fractional second is 10x fewer
  // nanoseconds.
  let power = power / 10

  case bytes {
    <<byte, remaining_bytes:bytes>>
      if byte_zero <= byte && byte <= byte_nine && power < 1
    -> {
      // We already have the max precision for nanoseconds. Truncate any
      // remaining digits.
      do_parse_second_fraction_as_nanoseconds(
        from: remaining_bytes,
        acc:,
        power:,
      )
    }
    <<byte, remaining_bytes:bytes>> if byte_zero <= byte && byte <= byte_nine -> {
      // We have not yet reached the precision limit. Parse the next digit.
      let digit = byte - 0x30
      do_parse_second_fraction_as_nanoseconds(
        from: remaining_bytes,
        acc: acc + digit * power,
        power:,
      )
    }
    _ -> Ok(#(acc, bytes))
  }
}

fn parse_offset(from bytes: BitArray) -> Result(#(Int, BitArray), Nil) {
  case bytes {
    <<"Z", remaining_bytes:bytes>> | <<"z", remaining_bytes:bytes>> ->
      Ok(#(0, remaining_bytes))
    _ -> parse_numeric_offset(bytes)
  }
}

fn parse_numeric_offset(from bytes: BitArray) -> Result(#(Int, BitArray), Nil) {
  use #(sign, bytes) <- result.try(parse_sign(from: bytes))
  use #(hours, bytes) <- result.try(parse_hours(from: bytes))
  use bytes <- result.try(accept_byte(from: bytes, value: byte_colon))
  use #(minutes, bytes) <- result.try(parse_minutes(from: bytes))

  let offset_seconds = offset_to_seconds(sign, hours:, minutes:)

  Ok(#(offset_seconds, bytes))
}

fn parse_sign(from bytes) {
  case bytes {
    <<"+", remaining_bytes:bytes>> -> Ok(#("+", remaining_bytes))
    <<"-", remaining_bytes:bytes>> -> Ok(#("-", remaining_bytes))
    _ -> Error(Nil)
  }
}

fn offset_to_seconds(sign, hours hours, minutes minutes) {
  let abs_seconds = hours * seconds_per_hour + minutes * seconds_per_minute

  case sign {
    "-" -> -abs_seconds
    _ -> abs_seconds
  }
}

/// Parse and return the given number of digits from the given bytes.
/// 
fn parse_digits(
  from bytes: BitArray,
  count count: Int,
) -> Result(#(Int, BitArray), Nil) {
  do_parse_digits(from: bytes, count:, acc: 0, k: 0)
}

fn do_parse_digits(
  from bytes: BitArray,
  count count: Int,
  acc acc: Int,
  k k: Int,
) -> Result(#(Int, BitArray), Nil) {
  case bytes {
    _ if k >= count -> Ok(#(acc, bytes))
    <<byte, remaining_bytes:bytes>> if byte_zero <= byte && byte <= byte_nine ->
      do_parse_digits(
        from: remaining_bytes,
        count:,
        acc: acc * 10 + { byte - 0x30 },
        k: k + 1,
      )
    _ -> Error(Nil)
  }
}

/// Accept the given value from `bytes` and move past it if found.
/// 
fn accept_byte(from bytes: BitArray, value value: Int) -> Result(BitArray, Nil) {
  case bytes {
    <<byte, remaining_bytes:bytes>> if byte == value -> Ok(remaining_bytes)
    _ -> Error(Nil)
  }
}

fn accept_date_time_separator(from bytes: BitArray) -> Result(BitArray, Nil) {
  case bytes {
    <<byte, remaining_bytes:bytes>>
      if byte == byte_t_uppercase
      || byte == byte_t_lowercase
      || byte == byte_space
    -> Ok(remaining_bytes)
    _ -> Error(Nil)
  }
}

fn accept_empty(from bytes: BitArray) -> Result(Nil, Nil) {
  case bytes {
    <<>> -> Ok(Nil)
    _ -> Error(Nil)
  }
}

/// Note: The caller of this function must ensure that all inputs are valid.
/// 
fn from_date_time(
  year year: Int,
  month month: Int,
  day day: Int,
  hours hours: Int,
  minutes minutes: Int,
  seconds seconds: Int,
  second_fraction_as_nanoseconds second_fraction_as_nanoseconds: Int,
  offset_seconds offset_seconds: Int,
) -> IntermediateStructure {
  let julian_seconds =
    julian_seconds_from_parts(year:, month:, day:, hours:, minutes:, seconds:)

  let julian_seconds_since_epoch = julian_seconds - julian_seconds_unix_epoch

  IntermediateStructure(
    seconds: julian_seconds_since_epoch - offset_seconds,
    nanoseconds: second_fraction_as_nanoseconds,
    offset: offset.from_seconds(offset_seconds),
  )
  |> normalise
}

/// `julian_seconds_from_parts(year, month, day, hours, minutes, seconds)` 
/// returns the number of Julian 
/// seconds represented by the given arguments.
/// 
/// Note: It is the callers responsibility to ensure the inputs are valid.
/// 
/// See https://www.tondering.dk/claus/cal/julperiod.php#formula
/// 
fn julian_seconds_from_parts(
  year year: Int,
  month month: Int,
  day day: Int,
  hours hours: Int,
  minutes minutes: Int,
  seconds seconds: Int,
) {
  let julian_day_seconds =
    julian_day_from_ymd(year:, month:, day:) * seconds_per_day

  julian_day_seconds
  + { hours * seconds_per_hour }
  + { minutes * seconds_per_minute }
  + seconds
}

/// Note: It is the callers responsibility to ensure the inputs are valid.
/// 
/// See https://www.tondering.dk/claus/cal/julperiod.php#formula
/// 
fn julian_day_from_ymd(year year: Int, month month: Int, day day: Int) -> Int {
  let adjustment = { 14 - month } / 12
  let adjusted_year = year + 4800 - adjustment
  let adjusted_month = month + 12 * adjustment - 3

  day
  + { { 153 * adjusted_month } + 2 }
  / 5
  + 365
  * adjusted_year
  + { adjusted_year / 4 }
  - { adjusted_year / 100 }
  + { adjusted_year / 400 }
  - 32_045
}
