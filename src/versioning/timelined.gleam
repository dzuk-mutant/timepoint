import day.{type Day}
import day_interval.{type DayInterval}
import gleam/bool
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/time/duration
import moment.{type Moment}
import moment_interval.{type MomentInterval}
import versioning/timelined/tl_any_variant.{type TLAnyVariant}
import versioning/timelined/tl_current_variant.{type TLCurrentVariant}
import versioning/timelined/tl_past_variant.{type TLPastVariant}
import versioning/timelined/tl_slice_by_day.{type TLSliceByDay}
import versioning/timelined/tl_slice_by_moment.{type TLSliceByMoment}

/// A wrapper for a data type that provides historical 
/// versioning, timed to absolute Moments.
/// 
/// Historical items are diffed from eachother in milliseconds.
/// 
/// This type is the ultimate source of truth about 
/// historical versioning for its enclosed data type.
/// 
/// When this is filtered, it becomes a TLSlice.
/// 
/// When editing operations are performed, a TLInsertionResult
/// is returned containing a potentially-updated version.
pub opaque type Timelined(v) {
  Timelined(
    current: TLCurrentVariant(v),
    history: List(TLPastVariant(v)),
    // The following two are to help preserve the integrity of future edits.
    // Do not edit these in any functions that aren't constructors.
    equality_fn: fn(v, v) -> Bool,
    history_start: Moment,
  )
}

/// Provides contextual detail on what the result of inserting a new current variant is.
/// 
/// This is because providing errors per se is not that helpful, but
/// what is is to inform the program of what it involves so the UI can 
/// tell the user if its the kind of edit that matters or be able to smoothly 
/// move past an invalid operation in chained functions.
pub type TLInsertionResult(v) {

  // Returns the initial Timelined for function chaining with a type that indicates that something is iffy about the attempt.
  // -------------------------------------------------------
  // This is the same as the current one. No change is necessary.
  NoChange(Timelined(v))
  // This should not be possible but guards against it.
  InvalidNewCurrentIsEarlierThanHistoricalStart(Timelined(v))
  //
  // -------------------------------------------------------
  // Will make a new current and move the existing one to the past.
  NonDestructive(Timelined(v))
  // Will overwrite the current because they share the same start.
  WillOverwriteCurrent(Timelined(v))
  // Will overwrite at least some of the history.
  WillOverwriteCurrentAndHistory(Timelined(v))
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

/// Creates a new Timelined with one CalVariant starting at the specified moment.
/// 
/// You cannot create an empty Timelined.
pub fn new(
  with value: v,
  starting_at start: Moment,
  equality_fn equality_fn: fn(v, v) -> Bool,
) -> Timelined(v) {
  Timelined(
    current: tl_current_variant.new(value:, start:),
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
  timelined: Timelined(v),
  value_encoder value_encoder: fn(v) -> Json,
) -> Json {
  json.object([
    #("current", tl_current_variant.to_json(timelined.current, value_encoder:)),
    #("history_start", moment.to_json(timelined.history_start)),
    #(
      "history",
      json.array(timelined.history, of: fn(x) {
        tl_past_variant.to_json(x, value_encoder:)
      }),
    ),
  ])
}

pub fn decoder(
  default_value default_value: v,
  value_decoder value_decoder: Decoder(v),
  equality_fn equality_fn: fn(v, v) -> Bool,
) -> Decoder(Timelined(v)) {
  let default =
    new(
      starting_at: moment.from_gtempo_literal("2000-01-01T00:00:00.000Z"),
      equality_fn:,
      with: default_value,
    )
  decode.new_primitive_decoder("Timelined", fn(timelined) {
    let moment_decoder = moment.decoder()
    let tl_past_decoder =
      tl_past_variant.decoder(default_value:, value_decoder:)
    let tl_current_decoder =
      tl_current_variant.decoder(default_value:, value_decoder:)

    let timelined_decoder = {
      use history_start <- decode.field("history_start", moment_decoder)
      use current <- decode.field("current", tl_current_decoder)
      use history <- decode.field("history", decode.list(of: tl_past_decoder))

      let tentative_calendrical =
        Timelined(history_start:, current:, history:, equality_fn:)

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

    case decode.run(timelined, timelined_decoder) {
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

/// A function that edits a Timelined by inserting a new Current Variant.
/// 
/// It returns the resulting Timelined inside an EditResult, providing advance warning and context as to what kind of edit it will be. 
pub fn insert_new_current(
  existing: Timelined(v),
  with new_current_value: v,
  starting_at new_start_moment: Moment,
) -> TLInsertionResult(v) {
  let existing_current_value =
    existing.current
    |> tl_current_variant.unwrap()

  let existing_current_start_moment =
    existing.current
    |> tl_current_variant.to_start_moment()

  // Is this actually an edit?
  case existing.equality_fn(existing_current_value, new_current_value) {
    True -> NoChange(existing)
    False -> {
      let new_current =
        tl_current_variant.new(
          value: new_current_value,
          start: new_start_moment,
        )

      // Can this not overwrite the existing current?
      case moment.compare(new_start_moment, existing_current_start_moment) {
        Gt ->
          // - New Current
          // - Cap off and append the Existing Current to history.
          Timelined(..existing, current: new_current, history: [
            tl_past_variant.from_current_variant(
              existing.current,
              end_excluding: new_start_moment,
            ),
            ..existing.history
          ])
          |> NonDestructive

        Eq ->
          // - Replace the Current.
          // - (Existing Current is "deleted")
          Timelined(..existing, current: new_current)
          |> WillOverwriteCurrent
        Lt ->
          // Does this new current go earlier than the start time of the entire structure's history?
          case moment.compare(new_start_moment, existing.history_start) {
            Gt | Eq ->
              // - Replace the Current.
              // - (Existing Current as "deleted")
              // - Filter out and/or truncate the history based on what's in the new current's path.

              Timelined(
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

/// Takes an TLInsertionResult and simply unwraps the new Changeable.
/// 
/// Mostly useful for testing and debugging.
pub fn unwrap_insertion_result(result: TLInsertionResult(v)) -> Timelined(v) {
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
  timelined: Timelined(v),
  with new_current_value: v,
  starting_at new_start_moment: Moment,
) -> Timelined(v) {
  insert_new_current(
    timelined,
    new_current_value,
    starting_at: new_start_moment,
  )
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

/// Returns a TLSliceByMoment, containing any variants that were in
/// effect within the given MomentInterval.
/// 
/// If the beginning of the MomentWindow is before the start
/// of the Timelined, it will return an empty structure.
pub fn slice_by_moment_interval(
  timelined: Timelined(v),
  interval: MomentInterval,
) -> TLSliceByMoment(v) {
  let current = case
    tl_current_variant.is_effective_in_moment_interval(
      timelined.current,
      interval,
    )
  {
    True -> Some(timelined.current)
    False -> None
  }

  let history =
    timelined
    |> to_history_list()
    |> list.filter(keeping: fn(x) {
      tl_past_variant.is_effective_in_moment_interval(x, interval)
    })

  tl_slice_by_moment.new(interval:, current:, history:)
}

/// Returns a TLSliceByDay, containing any variants that were in
/// effect within the given DayInterval.
/// 
/// /// If the beginning of the DayInterval is before the start
/// of the Timelined, it will return Result(Nil).
pub fn slice_by_day_interval(
  timelined: Timelined(v),
  interval: DayInterval,
) -> TLSliceByDay(v) {
  let current = case
    tl_current_variant.is_effective_in_day_interval(timelined.current, interval)
  {
    True -> Some(timelined.current)
    False -> None
  }

  let history =
    timelined
    |> to_history_list()
    |> list.filter(keeping: fn(x) {
      tl_past_variant.is_effective_in_day_interval(x, interval)
    })

  tl_slice_by_day.new(interval:, current:, history:)
}

/// Returns a TimelinedSlice, containing any variants that were in effect on the given Day.
pub fn filter_by_day(timelined: Timelined(v), query_day: Day) -> TLSliceByDay(v) {
  let current = case
    tl_current_variant.is_effective_on_day(timelined.current, query_day)
  {
    True -> Some(timelined.current)
    False -> None
  }

  let history =
    timelined
    |> to_history_list()
    |> list.filter(keeping: fn(x) {
      tl_past_variant.is_effective_on_day(x, query_day)
    })

  tl_slice_by_day.new(
    interval: day_interval.new(start: query_day, final: query_day),
    current:,
    history:,
  )
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
pub fn to_current_variant(timelined: Timelined(v)) -> TLCurrentVariant(v) {
  timelined.current
}

pub fn to_history_list(timelined: Timelined(v)) -> List(TLPastVariant(v)) {
  timelined.history
}

// Converts the entire Timelined to a list of CalAnyVariants.
pub fn to_list(timelined: Timelined(v)) -> List(TLAnyVariant(v)) {
  let history =
    timelined.history
    |> list.map(tl_any_variant.Past)

  let current = timelined.current |> tl_any_variant.Current

  [current, ..history]
}

// Retrieves the latest edit Moment of a Timelined.
pub fn to_latest_edit_moment(timelined: Timelined(v)) -> Moment {
  timelined
  |> to_current_variant
  |> tl_current_variant.to_start_moment
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

// Internal changer that sees if a Timelined has a history.
pub fn has_history(timelined: Timelined(v)) -> Bool {
  timelined.history
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

/// Checks if the current Moment is contiguous with the history.
/// 
/// (Current start is one day after the most recent variant's final Moment.)
/// 
/// Will return True if there's no history.
fn current_is_contiguous_with_history(timelined: Timelined(v)) -> Bool {
  timelined
  |> to_history_list
  |> list.first
  |> result.map(fn(v) {
    let last_history_final = tl_past_variant.to_end_excluding_moment(v)
    let current_start = tl_current_variant.to_start_moment(timelined.current)

    moment.difference(last_history_final, from: current_start)
    == duration.nanoseconds(0)
  })
  |> result.unwrap(True)
}

/// Checks if every consecutive variant is contiguous
/// with each other.
fn variants_are_contiguous(timelined: Timelined(v)) -> Bool {
  timelined
  |> to_history_list
  |> list.window_by_2
  |> list.map(fn(pair) {
    // remember this runs in reverse chronological order.
    moment_interval.is_contiguous(
      tl_past_variant.to_moment_interval(pair.1),
      before: tl_past_variant.to_moment_interval(pair.0),
    )
  })
  |> list.contains(False)
  |> bool.negate
}

/// Checks if the first variant in this structure has
/// the same start Moment as the marked history_start.
fn first_variant_matches_history_start(timelined: Timelined(v)) -> Bool {
  timelined
  |> to_history_list
  |> list.last
  |> result.map(fn(v) {
    v
    |> tl_past_variant.to_start_moment
    |> fn(x) { x == timelined.history_start }
  })
  |> result.unwrap(
    timelined.current
    |> tl_current_variant.to_start_moment
    |> fn(x) { x == timelined.history_start },
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
    deleted: List(TLPastVariant(v)),
    truncated: Option(TLPastVariant(v)),
    kept: List(TLPastVariant(v)),
  )
}

/// Internal function for insert_new_current() where it's known
/// that a new current insertion will overlap
/// a Timelined's history.
/// 
/// This function returns a version of that history where variants
/// are removed and/or truncated to make space for the new variant.
fn cut_and_truncate_history(
  timelined: Timelined(v),
  proposed_current: TLCurrentVariant(v),
) -> List(TLPastVariant(v)) {
  // fold over the history

  let plan =
    list.fold(
      over: timelined.history,
      from: OverlapAccumulation(truncated: None, kept: [], deleted: []),
      with: fn(b, a) { identify_overlaps(proposed_current, a, b) },
    )

  let kept = plan.kept |> list.reverse()

  case plan.truncated {
    None -> kept
    Some(truncated) -> {
      [truncated, ..kept]
    }
  }
}

/// The function that identifies and accumulates overlaps.
fn identify_overlaps(
  current: TLCurrentVariant(v),
  past: TLPastVariant(v),
  acc: OverlapAccumulation(v),
) -> OverlapAccumulation(v) {
  case
    tl_past_variant.truncate(
      past,
      behind: tl_current_variant.to_start_moment(current),
    )
  {
    Error(moment_interval.ResultIntervalIsLarger) ->
      OverlapAccumulation(..acc, kept: [past, ..acc.kept])
    Ok(truncated) -> OverlapAccumulation(..acc, truncated: Some(truncated))
    Error(moment_interval.ResultIntervalIsZero) ->
      OverlapAccumulation(..acc, deleted: [past, ..acc.deleted])
  }
}
