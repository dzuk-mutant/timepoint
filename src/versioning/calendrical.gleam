import day.{type Day}
import day_interval.{type DayInterval}
import gleam/bool
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import versioning/calendrical/cal_any_variant.{type CalAnyVariant, Current, Past}
import versioning/calendrical/cal_current_variant.{type CalCurrentVariant}
import versioning/calendrical/cal_past_variant.{type CalPastVariant}
import versioning/calendrical/cal_slice.{type CalSlice}

/// A wrapper for a data type that provides historical 
/// versioning, timed to calendar days.
/// 
/// This type is the ultimate source of truth about 
/// historical versioning for its enclosed data type.
/// 
/// When this is filtered, it becomes CalSlice.
/// 
/// When editing operations are performed, an CalInsertionResult
/// is returned containing a potentially-updated version.
pub opaque type Calendrical(v) {
  Calendrical(
    current: CalCurrentVariant(v),
    history: List(CalPastVariant(v)),
    // The following two are to help preserve the integrity of future edits.
    // Do not edit these in any functions that aren't constructors.
    equality_fn: fn(v, v) -> Bool,
    history_start: Day,
  )
}

/// Provides contextual detail on what the result of inserting a new current variant is.
/// 
/// This is because providing errors per se is not that helpful, but
/// what is is to inform the program of what it involves so the UI can 
/// tell the user if its the kind of edit that matters or be able to smoothly 
/// move past an invalid operation in chained functions.
pub type CalInsertionResult(v) {

  // Returns the initial Calendrical for function chaining with a type that indicates that something is iffy about the attempt.
  // -------------------------------------------------------
  // This is the same as the current one. No change is necessary.
  NoChange(Calendrical(v))
  // This should not be possible but guards against it.
  InvalidNewCurrentIsEarlierThanHistoricalStart(Calendrical(v))
  //
  // -------------------------------------------------------
  // Will make a new current and move the existing one to the past.
  NonDestructive(Calendrical(v))
  // Will overwrite the current because they share the same start.
  WillOverwriteCurrent(Calendrical(v))
  // Will overwrite at least some of the history.
  WillOverwriteCurrentAndHistory(Calendrical(v))
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// ------------------------ INIT -----------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------

/// Creates a new Calendrical with one CalVariant starting at the specified day.
/// 
/// You cannot create an empty Calendrical.
pub fn new(
  with value: v,
  starting_at start: Day,
  equality_fn equality_fn: fn(v, v) -> Bool,
) -> Calendrical(v) {
  Calendrical(
    current: cal_current_variant.new(value:, start:),
    history: [],
    equality_fn:,
    history_start: start,
  )
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// ------------------------ JSON -----------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------

pub fn to_json(
  calendrical: Calendrical(v),
  value_encoder value_encoder: fn(v) -> Json,
) -> Json {
  json.object([
    #(
      "current",
      cal_current_variant.to_json(calendrical.current, value_encoder:),
    ),
    #("history_start", day.to_json(calendrical.history_start)),
    #(
      "history",
      json.array(calendrical.history, of: fn(x) {
        cal_past_variant.to_json(x, value_encoder:)
      }),
    ),
  ])
}

pub fn decoder(
  default_value default_value: v,
  value_decoder value_decoder: Decoder(v),
  equality_fn equality_fn: fn(v, v) -> Bool,
) -> Decoder(Calendrical(v)) {
  let default =
    new(
      starting_at: day.from_gtempo_literal("2000-01-01"),
      equality_fn:,
      with: default_value,
    )
  decode.new_primitive_decoder("Calendrical", fn(calendrical) {
    let date_decoder = day.decoder()
    let cal_past_decoder =
      cal_past_variant.decoder(default_value:, value_decoder:)
    let cal_current_decoder =
      cal_current_variant.decoder(default_value:, value_decoder:)

    let calendrical_decoder = {
      use history_start <- decode.field("history_start", date_decoder)
      use current <- decode.field("current", cal_current_decoder)
      use history <- decode.field("history", decode.list(of: cal_past_decoder))

      let tentative_calendrical =
        Calendrical(history_start:, current:, history:, equality_fn:)

      // The previous decoding step made sure that the types of each data
      // point is correct but not whether the whole structure is sound.
      //
      // This series of tests ensures the structural validity of the code.
      case current_is_contiguous_with_history(tentative_calendrical) {
        False ->
          decode.failure(
            default,
            "Current variant is not contiguous with historic variants.",
          )
        True ->
          case variants_are_contiguous(tentative_calendrical) {
            False ->
              decode.failure(
                default,
                "Historic variants are not contiguous with each other.",
              )
            True ->
              case first_variant_matches_history_start(tentative_calendrical) {
                False ->
                  decode.failure(
                    default,
                    "The start day does not match the start day of the first variant.",
                  )
                True -> decode.success(tentative_calendrical)
              }
          }
      }
    }

    case decode.run(calendrical, calendrical_decoder) {
      Error(_) -> Error(default)
      Ok(habit) -> Ok(habit)
    }
  })
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// ------------------------ INSERT ---------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------

/// A function that edits a Calendrical by inserting a new Current Variant.
/// 
/// It returns the resulting Calendrical inside an EditResult, providing advance warning and context as to what kind of edit it will be. 
pub fn insert_new_current(
  existing: Calendrical(v),
  with new_current_value: v,
  starting_at new_start_day: Day,
) -> CalInsertionResult(v) {
  let existing_current_value =
    existing.current
    |> cal_current_variant.unwrap()

  let existing_current_start_day =
    existing.current
    |> cal_current_variant.to_start_day()

  // Is this actually an edit?
  case existing.equality_fn(existing_current_value, new_current_value) {
    True -> NoChange(existing)
    False -> {
      let new_current =
        cal_current_variant.new(value: new_current_value, start: new_start_day)

      // Can this not overwrite the existing current?
      case day.compare(new_start_day, existing_current_start_day) {
        Gt ->
          // - New Current
          // - Cap off and append the Existing Current to history.
          Calendrical(..existing, current: new_current, history: [
            cal_past_variant.from_current_variant(
              existing.current,
              end_excluding: new_start_day,
            ),
            ..existing.history
          ])
          |> NonDestructive

        Eq ->
          // - Replace the Current.
          // - (Existing Current is "deleted")
          Calendrical(..existing, current: new_current)
          |> WillOverwriteCurrent
        Lt ->
          // Does this new current go earlier than the start day of the entire structure's history?
          case day.compare(new_start_day, existing.history_start) {
            Gt | Eq ->
              // - Replace the Current.
              // - (Existing Current as "deleted")
              // - Filter out and/or truncate the history based on what's in the new current's path.

              Calendrical(
                ..existing,
                current: new_current,
                history: cut_and_truncate_history(existing, new_current),
              )
              |> WillOverwriteCurrentAndHistory

            Lt -> InvalidNewCurrentIsEarlierThanHistoricalStart(existing)
          }
      }
    }
  }
}

/// Takes an CalInsertionResult and simply unwraps the new Changeable.
/// 
/// Mostly useful for testing and debugging.
pub fn unwrap_insertion_result(result: CalInsertionResult(v)) -> Calendrical(v) {
  case result {
    NoChange(v) -> v
    NonDestructive(v) -> v
    WillOverwriteCurrent(v) -> v
    WillOverwriteCurrentAndHistory(v) -> v
    InvalidNewCurrentIsEarlierThanHistoricalStart(v) -> v
  }
}

/// A version of insert_new_current without any wrapper types saying how the edit will go.
/// 
/// Mostly useful for testing and debugging.
pub fn unsafe_insert_new_current(
  calendrical: Calendrical(v),
  with new_current_value: v,
  starting_at new_start_day: Day,
) -> Calendrical(v) {
  insert_new_current(calendrical, new_current_value, starting_at: new_start_day)
  |> unwrap_insertion_result()
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// ------------------------ QUERY ---------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------

/// The CalSlice will be empty if
/// the day range is before the start
/// day of the Calendrical.
/// 
pub fn slice_by_day_interval(
  calendrical: Calendrical(v),
  interval: DayInterval,
) -> CalSlice(v) {
  let current = case
    cal_current_variant.is_effective_in_day_interval(
      calendrical.current,
      interval,
    )
  {
    True -> Some(calendrical.current)
    False -> None
  }

  let history =
    calendrical
    |> to_history_list()
    |> list.filter(keeping: fn(x) {
      cal_past_variant.is_effective_in_day_interval(x, interval)
    })

  cal_slice.new(interval:, current:, history:)
}

/// Will return a Result(Nil) if the given day is before the
/// start day of the Calendrical.
pub fn get_variant_by_day(
  calendrical: Calendrical(v),
  day: Day,
) -> Result(CalAnyVariant(v), Nil) {
  case day.is_earlier(day, than: calendrical.history_start) {
    True -> Error(Nil)
    False ->
      case cal_current_variant.is_effective_on_day(calendrical.current, day) {
        True -> Ok(Current(calendrical.current))
        False -> {
          calendrical
          |> to_history_list()
          |> list.find_map(fn(x) {
            case cal_past_variant.is_effective_on_day(x, day) {
              True -> Ok(Past(x))
              False -> Error(Nil)
            }
          })
        }
      }
  }
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// ------------------------ CONVERSION -----------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------

/// Gets the current variant.
pub fn to_current_variant(calendrical: Calendrical(v)) -> CalCurrentVariant(v) {
  calendrical.current
}

pub fn to_history_list(calendrical: Calendrical(v)) -> List(CalPastVariant(v)) {
  calendrical.history
}

// Converts the entire Calendrical to a list of CalAnyVariants.
pub fn to_list(calendrical: Calendrical(v)) -> List(CalAnyVariant(v)) {
  let history =
    calendrical.history
    |> list.map(cal_any_variant.Past)

  let current = calendrical.current |> cal_any_variant.Current

  [current, ..history]
}

// Retrieves the latest edit Day of a Calendrical.
pub fn to_latest_edit_day(calendrical: Calendrical(v)) -> Day {
  calendrical
  |> to_current_variant
  |> cal_current_variant.to_start_day
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// ------------------------ INTERNAL -------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------

// Internal changer that sees if a Calendrical has a history.
pub fn has_history(calendrical: Calendrical(v)) -> Bool {
  calendrical.history
  |> list.is_empty()
  |> bool.negate
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// ----------------- INTERNAL FOR JSON DECODE ----------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------

/// Checks if the current day is contiguous with the history.
/// 
/// (Current start is one day after the most recent variant's final day.)
/// 
/// Will return True if there's no history.
fn current_is_contiguous_with_history(calendrical: Calendrical(v)) -> Bool {
  calendrical
  |> to_history_list
  |> list.first
  |> result.map(fn(v) {
    let last_history_final = cal_past_variant.to_final_day(v)
    let current_start = cal_current_variant.to_start_day(calendrical.current)

    day.difference(last_history_final, from: current_start) == 1
  })
  |> result.unwrap(True)
}

/// Checks if every consecutive variant is contiguous
/// with each other.
/// 
/// (as in, the final day of the next variant is one day
/// before the start day of the next variant.)
fn variants_are_contiguous(calendrical: Calendrical(v)) -> Bool {
  calendrical
  |> to_history_list
  |> list.window_by_2
  |> list.map(fn(pair) {
    // remember this runs in reverse chronological order.
    day_interval.is_contiguous(
      cal_past_variant.to_day_interval(pair.0),
      ahead_of: cal_past_variant.to_day_interval(pair.1),
    )
  })
  |> list.contains(False)
  |> bool.negate
}

/// Checks if the first variant in this structure has
/// the same start day as the marked history_start.
fn first_variant_matches_history_start(calendrical: Calendrical(v)) -> Bool {
  calendrical
  |> to_history_list
  |> list.last
  |> result.map(fn(v) {
    v
    |> cal_past_variant.to_start_day
    |> fn(x) { x == calendrical.history_start }
  })
  |> result.unwrap(
    calendrical.current
    |> cal_current_variant.to_start_day
    |> fn(x) { x == calendrical.history_start },
  )
}

// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -------- INTERNAL FOR OVERWRITING HISTORICAL ENTRIES ------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------
// -----------------------------------------------------------------

/// Helper type for cut_and_truncate_history().
type OverlapAccumulation(v) {
  OverlapAccumulation(
    deleted: List(CalPastVariant(v)),
    truncated: Option(CalPastVariant(v)),
    kept: List(CalPastVariant(v)),
  )
}

/// Internal function for insert_new_current() where it's known
/// that a new current insertion will overlap
/// a Calendrical's history.
/// 
/// This function returns a version of that history where variants
/// are removed and/or truncated to make space for the new variant.
fn cut_and_truncate_history(
  calendrical: Calendrical(v),
  proposed_current: CalCurrentVariant(v),
) -> List(CalPastVariant(v)) {
  // fold over the history

  let plan =
    list.fold(
      over: calendrical.history,
      from: OverlapAccumulation(truncated: None, kept: [], deleted: []),
      with: fn(b, a) { identify_overlaps(proposed_current, a, b) },
    )

  let kept = plan.kept |> list.reverse()

  case plan.truncated {
    None -> kept
    Some(truncated) -> [truncated, ..kept]
  }
}

/// The function that identifies and accumulates overlaps.
fn identify_overlaps(
  current: CalCurrentVariant(v),
  past: CalPastVariant(v),
  acc: OverlapAccumulation(v),
) -> OverlapAccumulation(v) {
  case
    cal_past_variant.truncate(
      past,
      behind: cal_current_variant.to_start_day(current),
    )
  {
    Error(day_interval.FinalIsLaterThanOriginal) ->
      OverlapAccumulation(..acc, kept: [past, ..acc.kept])
    Ok(truncated) -> OverlapAccumulation(..acc, truncated: Some(truncated))
    Error(day_interval.FinalIsEarlierThanStart) ->
      OverlapAccumulation(..acc, deleted: [past, ..acc.deleted])
  }
}
