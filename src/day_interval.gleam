import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import day.{type Day}
import moment.{type Moment}

/// A type that represents a span of Days.
/// 
/// This span of days can be a single length -
/// as in, it represents a span of days that is 1
/// day long.
pub opaque type DayInterval {
  DayInterval(start: Day, final: Day)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- CONSTRUCTOR ------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// Creates a new DayInterval.
/// 
/// This is an unsafe constructor - if the final
/// is earlier than the start, it will be made that way.
/// 
/// I want to make this more safe in the future, but I
/// don't want to choke my code with inelegant Result
/// unwraps.
pub fn new(start start: Day, final final: Day) -> DayInterval {
  DayInterval(start:, final:)
}

/// Creates a new DayInterval where the start and end
/// interval are the same - ie. its a DayInterval
/// that's 1 day long.
pub fn new_single(day: Day) -> DayInterval {
  DayInterval(start: day, final: day)
}

/// Creates a new DayInterval with a final day that
/// is 1 day before the given "end excluding" day.
pub fn new_with_end_excluding(
  start start: Day,
  end_excluding end_excluding: Day,
) -> DayInterval {
  let final = decrement(end_excluding)
  DayInterval(start:, final:)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- JSON ----------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// Converts a DayInterval into JSON.
pub fn to_json(interval: DayInterval) -> Json {
  json.object([
    #("start", day.to_json(interval.start)),
    #("final", day.to_json(interval.final)),
  ])
}

/// Attempts to decode a DayInterval from JSON.
/// 
/// If it's malformed, or formed but the final is
/// before the start, it will throw an Error.
pub fn decoder() -> Decoder(DayInterval) {
  let default =
    DayInterval(start: day.from_unix_days(0), final: day.from_unix_days(0))

  decode.new_primitive_decoder("DayInterval", fn(interval) {
    let day_decoder = day.decoder()

    let interval_decoder = {
      use start <- decode.field("start", day_decoder)
      use final <- decode.field("final", day_decoder)

      decode.success(#(start, final))
    }

    case decode.run(interval, interval_decoder) {
      Error(_) -> Error(default)
      Ok(raw_interval) ->
        case day.is_earlier(raw_interval.1, than: raw_interval.0) {
          True -> Error(default)
          False -> Ok(new(raw_interval.0, raw_interval.1))
        }
    }
  })
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- EDIT ----------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// Type encapsulating the different types of errors
/// that can be detected by the truncate function.
pub type TruncateError {
  FinalIsLaterThanOriginal
  FinalIsEarlierThanStart
}

/// Attempts to move the end Day to a position 1 day
/// before the given day.
/// 
/// Also used to check if a truncation is applicable
/// when it comes to overlap checks.
/// 
/// Will return Error(FinalIsEarlierThanStart) if the new_final Day
/// is before the first Day.
/// 
/// Will return Error(FinalIsLongerThanOriginal) if the new_final Day
/// is later than the original final Day.
pub fn truncate(
  interval: DayInterval,
  behind end_excluding: Day,
) -> Result(DayInterval, TruncateError) {
  let new_final = decrement(end_excluding)

  case day.is_later(new_final, than: interval.final) {
    True -> Error(FinalIsLaterThanOriginal)
    False ->
      case day.is_earlier(new_final, than: interval.start) {
        True -> Error(FinalIsEarlierThanStart)
        False -> Ok(DayInterval(..interval, final: new_final))
      }
  }
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- CONVERSION -------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// Returns the start day of a DayInterval.
pub fn to_start(interval: DayInterval) -> Day {
  interval.start
}

/// Returns the final day of a DayInterval.
pub fn to_final(interval: DayInterval) -> Day {
  interval.final
}

/// Returns the length of a DayInterval.
pub fn length(interval: DayInterval) -> Int {
  day.difference(interval.start, from: interval.final) + 1
}

/// Returns a list of dates comprising all of the Days
/// inside the DayInterval.
pub fn to_list(interval: DayInterval) -> List(Day) {
  let goal_length =
    day.difference(interval.start, from: interval.final)
    |> fn(x) { x + 1 }

  date_acc(acc: [], goal_length:, start: interval.start)
}

fn date_acc(acc acc: List(Day), goal_length goal_length: Int, start start: Day) {
  case list.length(acc) {
    x if x == goal_length -> list.reverse(acc)
    _ ->
      acc
      |> list.first()
      |> result.map(fn(x) { day.add(x, days: 1) })
      |> result.unwrap(or: start)
      |> fn(x) { date_acc([x, ..acc], goal_length, start) }
  }
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ----------------- COLLISION -------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// A type that represents the types of collisions
/// that can be detected between a non-specific point
/// in time (a Day or a Moment) and a DayInterval.
pub type Collision {
  PointBeforeStart
  PointAtStart
  PointInside
  PointAtFinal
  PointAfterFinal
}

/// Returns a Collision type specifically describing
/// where a Day is in relation to a DayInterval.
pub fn to_collision_with_day(interval: DayInterval, day: Day) -> Collision {
  case day.compare(day, interval.start) {
    Lt -> PointBeforeStart
    Eq -> PointAtStart
    Gt ->
      case day.compare(day, interval.final) {
        Lt -> PointInside
        Eq -> PointAtFinal
        Gt -> PointAfterFinal
      }
  }
}

/// Returns a Collision type specifically describing
/// where a DateTime is in relation to a DayInterval.
pub fn to_collision_with_moment(
  interval: DayInterval,
  moment: Moment,
) -> Collision {
  let date =
    moment
    |> day.from_moment

  case day.compare(date, interval.start) {
    Lt -> PointBeforeStart
    Eq -> PointAtStart
    Gt ->
      case day.compare(date, interval.final) {
        Lt -> PointInside
        Eq -> PointAtFinal
        Gt -> PointAfterFinal
      }
  }
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- QUERY ---------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// Checks if a Day lands PointInside a DayInterval.
/// 
/// ```
/// correct:
/// 
/// |-------|    |-----|   |----|
///    d         d              d
///  
/// 
/// ```
/// Checks if a Day lands PointInside a DayInterval.
pub fn is_around_day(interval: DayInterval, d: Day) -> Bool {
  case to_collision_with_day(interval, d) {
    PointAtStart | PointInside | PointAtFinal -> True
    _ -> False
  }
}

/// Checks if a Moment lands PointInside a DayInterval.
/// 
/// ```
/// correct:
/// 
/// |-------|    |-----|   |----|
///    m         m              m
///  
/// 
/// ```
pub fn is_around_moment(interval: DayInterval, m: Moment) -> Bool {
  case to_collision_with_moment(interval, m) {
    PointAtStart | PointInside | PointAtFinal -> True
    _ -> False
  }
}

/// Checks if a Moment lands before a DayInterval.
/// 
/// ```
/// correct:
/// 
///      |-------| 
///    m        
///  
/// 
/// ```
pub fn is_after_moment(interval: DayInterval, m: Moment) -> Bool {
  case to_collision_with_moment(interval, m) {
    PointBeforeStart -> True
    _ -> False
  }
}

/// Checks if a DayInterval is fully PointInside another DayInterval.
/// 
/// ```
/// 
/// correct:
/// 
///     a-----a      a----a       a----a
///    b-------b     b-----b    b------b
/// 
/// ```
pub fn is_inside(a: DayInterval, of b: DayInterval) {
  case to_collision_with_day(b, a.start) {
    PointAtStart | PointInside -> True
    _ -> False
  }
  && case to_collision_with_day(b, a.final) {
    PointInside | PointAtFinal -> True
    _ -> False
  }
}

/// Checks if a DayInterval is at least partly PointInside another DayInterval.
/// 
/// ```
/// correct:
/// 
///     a-----a      a----a       a----a
///    b-------b     b-----b    b------b
/// 
/// 
///   a-----a          a------a       a------a
///     b------b     b-----b     b----b
/// 
/// 
///    a-----a
///          b-----b
/// 
/// ```
/// 
pub fn is_overlapped(a: DayInterval, by b: DayInterval) {
  case to_collision_with_day(b, a.start) {
    PointBeforeStart | PointAtStart | PointInside | PointAtFinal -> True
    _ -> False
  }
  && case to_collision_with_day(b, a.final) {
    PointAtStart | PointInside | PointAtFinal | PointAfterFinal -> True
    _ -> False
  }
}

/// Checks if two DayIntervals are considered 'contiguous'.
/// 
/// ```
/// correct:
/// 
/// a----a
///       b----b
/// 
/// (b's start is one day after a's end)
/// 
/// ```
/// 
pub fn is_contiguous(prev: DayInterval, ahead_of next: DayInterval) -> Bool {
  day.difference(next.final, from: prev.start) == 1
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ------------------- HELPER ---------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// A helper function that prints a formatted string for debugging.
pub fn to_string(interval: DayInterval) -> String {
  let start =
    interval
    |> to_start
    |> day.to_string

  let final =
    interval
    |> to_final
    |> day.to_string

  { start <> " ---> " <> final }
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -------------- INTERNAL HELPER ----------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

/// A small function that takes away room for error.
fn decrement(day: Day) -> Day {
  day.subtract(day, days: 1)
}
