import day.{type Day}
import day_interval.{type DayInterval}
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/order.{Eq, Gt, Lt}
import gleam/time/duration
import moment.{type Moment}

/// A MomentInterval coming from an internal process,
/// where other logic and tests guarantees its correctness.
/// 
/// Represents a range of time for comparison.
/// 
/// The start Moment is inclusive (Eq/Gt) and the
/// end Moment is exclusive (Lt).
pub opaque type MomentInterval {
  MomentInterval(start: Moment, end_excluding: Moment)
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

pub fn new(
  start start: Moment,
  end_excluding end_excluding: Moment,
) -> MomentInterval {
  MomentInterval(start:, end_excluding:)
}

// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// ---------------- CONVERSIONS ------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

pub fn to_end_excluding(interval: MomentInterval) -> Moment {
  interval.end_excluding
}

pub fn to_start(interval: MomentInterval) -> Moment {
  interval.start
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

/// Converts a MomentInterval into a JSON String.
/// 
/// You cannot directly decode a JSON String to a
/// MomentInterval, it has to be decoded into a
/// RawMomentWindow and then normalised.
pub fn to_json(interval: MomentInterval) -> Json {
  json.object([
    #("start", moment.to_json(interval.start)),
    #("end_excluding", moment.to_json(interval.end_excluding)),
  ])
}

/// Attempts to decode a Moment from JSON.
/// 
/// If it's malformed, or formed but the end is
/// before the start, it will throw an Error.
pub fn decoder() -> Decoder(MomentInterval) {
  let default =
    MomentInterval(
      start: moment.from_gtempo_literal("2025-03-10T00:00:00.000Z"),
      end_excluding: moment.from_gtempo_literal("2025-03-10T00:00:00.000Z"),
    )

  decode.new_primitive_decoder("RawMomentInterval", fn(interval) {
    let moment_decoder = moment.decoder()

    let interval_decoder = {
      use start <- decode.field("start", moment_decoder)
      use end_excluding <- decode.field("end_excluding", moment_decoder)

      decode.success(#(start, end_excluding))
    }

    case decode.run(interval, interval_decoder) {
      Error(_) -> Error(default)
      Ok(raw_interval) ->
        case moment.is_earlier(raw_interval.1, than: raw_interval.0) {
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
// ----------------- COLLISION -------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------
// -----------------------------------------------

pub type MomentCollision {
  MomentBeforeStart
  MomentAtStart
  MomentInside
  MomentAtEnd
  MomentAfterEnd
}

pub type DayCollision {
  DayBeforeStart
  DayAtStart
  DayInside
  DayOnOrAfterEnd
}

/// Returns a PointCollision type specifically describing
/// where a Moment is in relation to a MomentInterval.
pub fn to_collision_with_moment(
  interval: MomentInterval,
  moment: Moment,
) -> MomentCollision {
  case moment.compare(moment, interval.start) {
    Lt -> MomentBeforeStart
    Eq -> MomentAtStart
    Gt ->
      case moment.compare(moment, interval.end_excluding) {
        Lt -> MomentInside
        Eq -> MomentAtEnd
        Gt -> MomentAfterEnd
      }
  }
}

/// Returns a PointCollision type specifically describing
/// where a Day is in relation to a MomentInterval.
pub fn to_collision_with_day(interval: MomentInterval, day: Day) -> DayCollision {
  let start_day =
    interval.start
    |> day.from_moment

  let final_moment_day =
    interval.end_excluding
    |> moment.subtract(duration.nanoseconds(1))
    |> day.from_moment

  case day.compare(day, start_day) {
    Lt -> DayBeforeStart
    Eq -> DayAtStart
    Gt ->
      case day.compare(day, final_moment_day) {
        Lt | Eq -> DayInside
        Gt -> DayOnOrAfterEnd
      }
  }
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
  ResultIntervalIsZero
  ResultIntervalIsLarger
}

/// Attempts to move the end_excluding 
/// Moment to the same point as a given Momeent
/// 
/// Also used to check if a truncation is applicable
/// when it comes to overlap checks.
/// 
/// ```
/// will provide a result,
/// even if the result is the same:
/// 
///    s--------e      s-------e
///    s---T           s-------T
/// 
/// ResultIntervalIsZero:
/// 
///   s--------e       s-------e
///   T              T
/// 
/// ResultIntervalIsLarger:
///  e--------e
///  s-----------T 
/// 
/// ```
///
pub fn truncate(
  interval: MomentInterval,
  behind truncating_moment: Moment,
) -> Result(MomentInterval, TruncateError) {
  case to_collision_with_moment(interval, truncating_moment) {
    MomentBeforeStart | MomentAtStart -> Error(ResultIntervalIsZero)
    MomentAfterEnd -> Error(ResultIntervalIsLarger)
    _ -> Ok(MomentInterval(..interval, end_excluding: truncating_moment))
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

/// Checks if a Day somewhat lands inside a MomentInterval.
///
/// correct:
/// 
/// |-------|    |-----|   
///    d         d    
/// 
/// ```
/// 
pub fn is_around_day(interval: MomentInterval, day: Day) -> Bool {
  case to_collision_with_day(interval, day) {
    DayAtStart | DayInside -> True
    _ -> False
  }
}

/// Checks if a Day somewhat lands before a MomentInterval.
///
/// correct:
/// 
///     |-----|   
///   d    
/// 
/// ```
/// 
pub fn is_after_day(interval: MomentInterval, day: Day) -> Bool {
  case to_collision_with_day(interval, day) {
    DayBeforeStart -> True
    _ -> False
  }
}

/// Checks if a Moment lands inside a MomentInterval.
/// 
/// correct:
/// 
/// |-------|    |-----|   
///    m         m    
/// 
/// ```
/// 
pub fn is_around_moment(interval: MomentInterval, moment: Moment) -> Bool {
  case to_collision_with_moment(interval, moment) {
    MomentAtStart | MomentInside -> True
    _ -> False
  }
}

/// Checks if a Moment lands before a MomentInterval.
/// 
/// correct:
/// 
///       |-------|     
///    m         
/// 
/// ```
/// 
pub fn is_after_moment(interval: MomentInterval, moment: Moment) -> Bool {
  case to_collision_with_moment(interval, moment) {
    MomentBeforeStart -> True
    _ -> False
  }
}

/// Checks if a MomentInterval is fully inside another MomentInterval.
/// 
/// ```
/// 
/// correct:
/// 
///     a-----a      a----a       a----a
///    b-------b     b-----b    b------b
/// 
/// ```
pub fn is_inside(a: MomentInterval, of b: MomentInterval) {
  case to_collision_with_moment(b, a.start) {
    MomentAtStart | MomentInside -> True
    _ -> False
  }
  && case to_collision_with_moment(b, a.end_excluding) {
    MomentInside | MomentAtEnd -> True
    _ -> False
  }
}

/// Checks if a MomentInterval is at least partly overlapping another MomentInterval.
/// 
/// ```
/// correct:
/// 
///     a-----a      a----a       a----a
///    b-------b     b-----b    b------b
/// 
/// 
///   a-----a          a------a 
///     b------b     b-----b     
/// 
/// 
/// 
/// ```
/// 
pub fn is_overlapped(a: MomentInterval, by b: MomentInterval) {
  case to_collision_with_moment(b, a.start) {
    MomentBeforeStart | MomentAtStart | MomentInside -> True
    _ -> False
  }
  && case to_collision_with_moment(b, a.end_excluding) {
    MomentInside | MomentAtEnd | MomentAfterEnd -> True
    _ -> False
  }
}

/// Checks if a MomentInterval is at least partly
/// overlapping a DayInterval.
/// 
/// ```
/// correct:
/// 
///     d-----d      d----d       d----d
///    t-------t     t-----t    t------t
/// 
/// 
///   d-----d          d------d   d-----d
///     t------t     t-----t            t-------t
/// 
/// 
/// 
/// ```
/// 
pub fn is_overlapped_by_day_interval(
  t: MomentInterval,
  by d: DayInterval,
) -> Bool {
  case to_collision_with_day(t, day_interval.to_start(d)) {
    DayBeforeStart | DayAtStart | DayInside -> True
    _ -> False
  }
  && case to_collision_with_day(t, day_interval.to_final(d)) {
    DayAtStart | DayInside | DayOnOrAfterEnd -> True
    _ -> False
  }
}

/// Checks if two MomentIntervals are considered 'contiguous'.
/// 
/// ```
/// correct:
/// 
/// 1----1
///      2----2
/// 
/// ```
/// 
pub fn is_contiguous(
  prev: MomentInterval,
  ahead_of next: MomentInterval,
) -> Bool {
  prev.end_excluding == next.start
}
