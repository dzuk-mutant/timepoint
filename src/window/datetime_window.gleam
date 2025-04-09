import gleam/json.{type Json}
import gleam/order.{Eq, Gt, Lt}
import tempo.{type Date, type DateTime}
import tempo/date
import tempo/datetime
import tempo/duration
import time/store/datetime as datetime_store
import time/window/date_window.{type DateWindow}

/// A DateTimeWindow coming from an internal process,
/// where other logic and tests guarantees its correctness.
/// 
/// Represents a range of time for comparison. Designed
/// to be in sets of non-overlapping information, hence
/// the use of 'final' instead of 'end' for the last DateTime
/// in the range.
/// 
/// The start DateTime is inclusive (Eq/Gt) and the
/// final DateTime is inclusive (Eq/Lt).
/// 
/// If you need a DateTimeWindow from a fallible source,
/// use RawDateTimeWindow.
pub type DateTimeWindow {
  DateTimeWindow(start: DateTime, final: DateTime)
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

/// Creates a new DateTimeWindow using an end time that's exclusive -
/// The function will generate a final time 1ms before.
pub fn new(
  start start: DateTime,
  end_excluding end_excluding: DateTime,
) -> DateTimeWindow {
  DateTimeWindow(start:, final: decrement(end_excluding))
}

/// Creates a new DateTimeWindow with a custom final time.
pub fn new_with_final(
  start start: DateTime,
  final final: DateTime,
) -> DateTimeWindow {
  DateTimeWindow(start:, final:)
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

/// Converts a DateTimeWindow into a JSON String.
/// 
/// You cannot directly decode a JSON String to a
/// DateTimeWindow, it has to be decoded into a
/// RawDateTimeWindow and then attempted to be normalised.
pub fn to_json(window: DateTimeWindow) -> Json {
  json.object([
    #("start", datetime_store.to_json(window.start)),
    #("final", datetime_store.to_json(window.final)),
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
  window: DateTimeWindow,
  behind end_excluding: DateTime,
) -> Result(DateTimeWindow, TruncateError) {
  let new_final = decrement(end_excluding)

  case datetime.is_later(new_final, than: window.final) {
    True -> Error(FinalIsLaterThanOriginal)
    False ->
      case datetime.is_earlier(new_final, than: window.start) {
        True -> Error(FinalIsEarlierThanStart)
        False -> Ok(DateTimeWindow(..window, final: new_final))
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

/// Checks if a Date somewhat lands inside a DateTimeWindow.
/// 
/// ```
/// correct:
/// 
/// |-------|    |-----|   |----|
///    d         d              d
///  
/// 
/// ```
pub fn is_around_date(window: DateTimeWindow, date: Date) -> Bool {
  case date.compare(date, datetime.get_date(window.start)) {
    Lt -> False
    Eq -> True
    Gt ->
      case date.compare(date, datetime.get_date(window.final)) {
        Gt -> False
        Eq | Lt -> True
      }
  }
}

/// Checks if a DateTime lands inside a DateTimeWindow.
/// 
/// ```
/// correct:
/// 
/// |-------|    |-----|   |----|
///    t         t              t
///  
/// 
/// ```
pub fn is_around_datetime(window: DateTimeWindow, datetime: DateTime) -> Bool {
  case datetime.compare(datetime, window.start) {
    Lt -> False
    Eq -> True
    Gt ->
      case datetime.compare(datetime, window.final) {
        Gt -> False
        Eq | Lt -> True
      }
  }
}

/// Checks if a DateTimeWindow is fully inside another DateTimeWindow.
/// 
/// ```
/// 
/// correct:
/// 
///     a-----a      a----a       a----a
///    b-------b     b-----b    b------b
/// 
/// ```
pub fn is_inside(comparing: DateTimeWindow, of compared: DateTimeWindow) {
  case datetime.compare(comparing.start, compared.start) {
    Lt -> False
    Eq | Gt ->
      case datetime.compare(comparing.final, compared.final) {
        Gt -> False
        Eq | Lt -> True
      }
  }
}

/// Checks if a DateTimeWindow is at least partly overlapping another DateTimeWindow.
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
pub fn is_overlapped(comparing: DateTimeWindow, by compared: DateTimeWindow) {
  case datetime.compare(comparing.final, compared.start) {
    Lt -> False
    Eq -> True
    Gt ->
      case datetime.compare(comparing.start, compared.final) {
        Gt -> False
        Eq | Lt -> True
      }
  }
}

/// Checks if a DateTimeWindow is at least partly
/// overlapping a DateWindow.
/// 
/// ```
/// correct:
/// 
///     d-----d      d----d       d----d
///    t-------t     t-----t    t------t
/// 
/// 
///   d-----d          d------d       d------d
///     t------t     t-----t     t----t
/// 
/// 
///    d-----d
///          t-----t
/// 
/// ```
/// 
pub fn is_overlapped_by_date_window(
  window: DateTimeWindow,
  by dwindow: DateWindow,
) -> Bool {
  case date.compare(datetime.get_date(window.final), dwindow.start) {
    Lt -> False
    Eq -> True
    Gt ->
      case date.compare(datetime.get_date(window.start), dwindow.final) {
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
fn decrement(datetime: DateTime) -> DateTime {
  datetime.subtract(datetime, duration: duration.milliseconds(1))
}
