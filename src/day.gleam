import duration_extra
import gleam/dynamic/decode.{type Decoder}
import gleam/int
import gleam/json.{type Json}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result
import gleam/time/timestamp
import moment.{type Moment}
import offset

/// A Day is an abstract representation of a specific day on Earth.
/// 
/// This could be...
/// - A specific solar/calendar day from the perspective of one place
/// on earth.
/// - A specific solar/calendar day from the perspective of one person
/// (eg. if they are travelling and moving across Offsets)
/// 
/// Day is roughly analogous to a Date type in other systems - a
/// Day carries the same information as `2026-04-19` does, but
/// with important distinctions:
/// 
/// - It's impossible to create an invalid Day.
/// - There is no specific calendar representation attached.
/// 
/// If you want to work in a specific calendar, you need
/// to cast the Day into that specific system.
pub opaque type Day {
  Day(unix_days: Int)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Casts a Moment into a Day.
/// 
/// ## Examples
/// 
/// ```gleam
/// timestamp.from_unix_seconds(0)
/// |> moment.from_timestamp(with: offset.from_mins(60))
/// |> day.from_moment()
/// |> iso_date.from_day()
/// ```
pub fn from_moment(moment: Moment) -> Day {
  let offset_shift =
    moment
    |> moment.to_offset
    |> offset.to_duration

  let shifted_timestamp =
    moment
    |> moment.to_timestamp
    |> timestamp.add(offset_shift)

  // duration from epoch
  timestamp.difference(timestamp.from_unix_seconds(0), shifted_timestamp)
  |> duration_extra.as_days
  |> from_unix_days
}

/// Creates a Day from an ISO 8601 formatted-string.
/// 
/// ## Examples
/// 
/// ```gleam
/// day.parse_iso8601("2026-04-20")
/// |> result.map(day.to_unix_days)
/// // Ok(20_563)
/// ```
pub fn parse_iso8601(string: String) -> Result(Day, Nil) {
  use ts <- result.try(timestamp.parse_rfc3339(string <> "T00:00:00Z"))

  ts
  |> moment.from_timestamp(with: offset.from_minutes(0))
  |> from_moment
  |> Ok
}

/// Often when testing date functions, you're creating dates
/// **a lot** of the time and unwrapping Results is unecessary
/// for the test case. This is a version of `parse_iso8601` that
/// simply panics when the input is wrong.
/// 
/// Use for testing only.
pub fn testing_iso8601(string: String) -> Day {
  case parse_iso8601(string) {
    Ok(day) -> day
    Error(_) -> panic as "incorrect testing ISO 8601 string"
  }
}

// -----------------------------------------------------

/// Converts an Int representing the number of days
/// from the Unix Epoch (1st January 1970) into a Day.
pub fn from_unix_days(unix_days: Int) -> Day {
  Day(unix_days:)
}

/// Converts a Day into an Int representing days
/// from the Unix Epoch (1st January 1970).
pub fn to_unix_days(day: Day) -> Int {
  day.unix_days
}

// -----------------------------------------------------

/// 1st January 1970
const unix_epoch_as_rata_die: Int = 719_163

/// Creates a Day from an Int representing Rata Die days.
/// 
/// Rata die is the number of days from 1st January, 1 CE.
pub fn from_rata_die(rata_die: Int) -> Day {
  rata_die
  |> int.subtract(unix_epoch_as_rata_die)
  |> fn(d) { Day(unix_days: d) }
}

/// Converts a Day into an Int representing Rata Die days.
/// 
/// Rata die is the number of days from 1st January, 1 CE.
pub fn to_rata_die(day: Day) -> Int {
  day.unix_days
  |> int.add(unix_epoch_as_rata_die)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- COMPARISON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Checks if two Days are the same.
pub fn is_equal(a: Day, to b: Day) -> Bool {
  to_rata_die(a) == to_rata_die(b)
}

/// Compares two Days against each other.
pub fn compare(a: Day, to b: Day) -> Order {
  int.compare(to_rata_die(a), with: to_rata_die(b))
}

/// Compares two Days against each other in reverse chronological order.
pub fn compare_reverse(a: Day, to b: Day) -> Order {
  int.compare(to_rata_die(a), with: to_rata_die(b))
  |> order.negate
}

/// Checks if a the first Day is earlier than the second.
pub fn is_earlier(a: Day, than b: Day) -> Bool {
  compare(a, to: b) == Lt
}

/// Checks if a the first Day is earlier than or the same as the second.
pub fn is_earlier_or_equal(a: Day, to b: Day) -> Bool {
  let comparison = compare(a, to: b)
  comparison == Lt || comparison == Eq
}

/// Checks if a the first Day is later than the second.
pub fn is_later(a: Day, than b: Day) -> Bool {
  compare(a, to: b) == Gt
}

/// Gets the difference in Days from the first and the second Day given.
pub fn difference(a: Day, from b: Day) -> Int {
  to_unix_days(b) - to_unix_days(a)
}

/// Subtracts a specified number of days from the Day.
pub fn add(sd: Day, days days: Int) -> Day {
  Day(unix_days: sd.unix_days + days)
}

/// Subtracts a specified number of days from the Day.
pub fn subtract(sd: Day, days days: Int) -> Day {
  Day(unix_days: sd.unix_days - days)
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- JSON ------------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// Useful for most JSON values, apart from if you need
/// to use a Day as a Dict key, in which case, use `to_json_dict_key()`.
pub fn to_json(day: Day) -> Json {
  json.int(to_unix_days(day))
}

/// A function that converts a Day to a String that's
/// usable as a JSON Dict key.
pub fn to_json_dict_key(day: Day) -> String {
  day
  |> to_unix_days
  |> int.to_string
}

/// A decoder for Days when used as normal values.
pub fn decoder() -> Decoder(Day) {
  // 2000-01-01
  let default = from_unix_days(730_120)

  decode.new_primitive_decoder("Date", fn(date) {
    case decode.run(date, decode.int) {
      Error(_) -> Error(default)
      Ok(rd) -> Ok(Day(unix_days: rd))
    }
  })
}

/// A decoder for Days when used as Dict keys.
pub fn decoder_dict_key() -> Decoder(Day) {
  // 2000-01-01
  let default = from_unix_days(730_120)

  decode.new_primitive_decoder("Date", fn(date) {
    case decode.run(date, decode.string) {
      Error(_) -> Error(default)
      Ok(str) ->
        case int.parse(str) {
          Error(_) -> Error(default)
          Ok(rd) -> Ok(Day(unix_days: rd))
        }
    }
  })
}
