import gleam/json.{type Json}
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import tempo.{type Date, type DateTime}
import tempo/date
import tempo/datetime
import time/store/date as date_store
import time/window/collision.{
  type PointCollision, PointAfterFinal, PointAtFinal, PointAtStart,
  PointBeforeStart, PointInside,
}

/// A DateWindow coming from an internal process,
/// where other logic and tests guarantees its correctness.
/// 
/// If you need a DateWindow from a fallible source,
/// use RawDateWindow.
pub type DateWindow {
  DateWindow(start: Date, final: Date)
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

/// Creates a new DateWindow.
pub fn new(start start: Date, final final: Date) -> DateWindow {
  DateWindow(start:, final:)
}

/// Creates a new DateWindow where the start and end
/// window are the same - ie. its a DateWindow
/// that's 1 day long.
pub fn new_single(date: Date) -> DateWindow {
  DateWindow(start: date, final: date)
}

/// Creates a new DateWindow with an end_excluding date.
pub fn new_with_end_excluding(
  start start: Date,
  end_excluding end_excluding: Date,
) -> DateWindow {
  let final = decrement(end_excluding)
  DateWindow(start:, final:)
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

/// Converts a DateWindow into JSON.
/// 
/// You cannot directly decode a JSON String to a
/// DateWindow, it has to be decoded into a
/// RawDateWindow and then attempted to be normalised.
pub fn to_json(window: DateWindow) -> Json {
  json.object([
    #("start", date_store.to_json(window.start)),
    #("final", date_store.to_json(window.final)),
  ])
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

/// Attempts to move the end Date to a position 1 day
/// before the given date.
/// 
/// Also used to check if a truncation is applicable
/// when it comes to overlap checks.
/// 
/// Will return Error(FinalIsEarlierThanStart) if the new_final Date
/// is before the first Date.
/// 
/// Will return Error(FinalIsLongerThanOriginal) if the new_final Date
/// is later than the original final Date.
pub fn truncate(
  window: DateWindow,
  behind end_excluding: Date,
) -> Result(DateWindow, TruncateError) {
  let new_final = decrement(end_excluding)

  case date.is_later(new_final, than: window.final) {
    True -> Error(FinalIsLaterThanOriginal)
    False ->
      case date.is_earlier(new_final, than: window.start) {
        True -> Error(FinalIsEarlierThanStart)
        False -> Ok(DateWindow(..window, final: new_final))
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

/// Creates a list of dates comprising all of the dates
/// inside the DateWindow.
pub fn to_date_list(window: DateWindow) -> List(Date) {
  let goal_length =
    date.difference(window.final, from: window.start)
    |> fn(x) { x + 1 }

  date_acc(acc: [], goal_length:, start: window.start)
}

fn date_acc(
  acc acc: List(Date),
  goal_length goal_length: Int,
  start start: Date,
) {
  case list.length(acc) {
    x if x == goal_length -> list.reverse(acc)
    _ ->
      acc
      |> list.first()
      |> result.map(fn(x) { date.add(x, days: 1) })
      |> result.unwrap(or: start)
      |> fn(x) { date_acc([x, ..acc], goal_length, start) }
  }
}

/// Returns a PointCollision type specifically describing
/// where a Date is in relation to a DateWindow.
pub fn to_point_collision_with_date(
  window: DateWindow,
  date: Date,
) -> PointCollision {
  case date.compare(date, window.start) {
    Lt -> PointBeforeStart
    Eq -> PointAtStart
    Gt ->
      case date.compare(date, window.final) {
        Lt -> PointInside
        Eq -> PointAtFinal
        Gt -> PointAfterFinal
      }
  }
}

/// Returns a PointCollision type specifically describing
/// where a DateTime is in relation to a DateWindow.
pub fn to_point_collision_with_datetime(
  window: DateWindow,
  datetime: DateTime,
) -> PointCollision {
  let date = datetime.get_date(datetime)

  case date.compare(date, window.start) {
    Lt -> PointBeforeStart
    Eq -> PointAtStart
    Gt ->
      case date.compare(date, window.final) {
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

/// Checks if a Date lands inside a DateWindow.
/// 
/// ```
/// correct:
/// 
/// |-------|    |-----|   |----|
///    d         d              d
///  
/// 
/// ```
/// Checks if a Date lands inside a DateWindow.
pub fn is_around_date(window: DateWindow, date: Date) -> Bool {
  case to_point_collision_with_date(window, date) {
    PointAtStart | PointInside | PointAtFinal -> True
    _ -> False
  }
}

/// Checks if a DateTime lands inside a DateWindow.
/// 
/// ```
/// correct:
/// 
/// |-------|    |-----|   |----|
///    t         t              t
///  
/// 
/// ```
pub fn is_around_datetime(window: DateWindow, datetime: DateTime) -> Bool {
  case to_point_collision_with_datetime(window, datetime) {
    PointAtStart | PointInside | PointAtFinal -> True
    _ -> False
  }
}

/// Checks if a DateWindow is fully inside another DateWindow.
/// 
/// ```
/// 
/// correct:
/// 
///     a-----a      a----a       a----a
///    b-------b     b-----b    b------b
/// 
/// ```
pub fn is_inside(comparing: DateWindow, of compared: DateWindow) {
  case date.compare(comparing.start, compared.start) {
    Lt -> False
    Eq | Gt ->
      case date.compare(comparing.final, compared.final) {
        Gt -> False
        Eq | Lt -> True
      }
  }
}

/// Checks if a DateWindow is at least partly inside another DateWindow.
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
pub fn is_overlapped(comparing: DateWindow, by compared: DateWindow) {
  case date.compare(comparing.final, compared.start) {
    Lt -> False
    Eq -> True
    Gt ->
      case date.compare(comparing.start, compared.final) {
        Gt -> False
        Eq | Lt -> True
      }
  }
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
/// A small function that takes away room for error.
fn decrement(date: Date) -> Date {
  date.subtract(date, days: 1)
}
