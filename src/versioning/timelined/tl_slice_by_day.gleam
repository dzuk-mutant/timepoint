import gleam/list
import gleam/option.{type Option, None, Some}
import interval/day_interval.{type DayInterval}
import versioning/timelined/tl_any_variant.{type TLAnyVariant}
import versioning/timelined/tl_current_variant.{type TLCurrentVariant}
import versioning/timelined/tl_past_variant.{type TLPastVariant}
import versioning/timelined/tl_slice_variants.{
  type TLSliceVariants, TLSliceVariants,
}

/// A slice of a Timelined. When a Timelined is 
/// filtered, this type or TLSliceByMoment is returned.
/// 
/// There are two different types because the interval can be by Day
/// or Moment and they are fundamentally two different things.
pub opaque type TLSliceByDay(v) {
  TLSliceByDay(interval: DayInterval, variants: TLSliceVariants(v))
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// --------------------- CONSTRUCTORS --------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

pub fn new(
  interval interval: DayInterval,
  current current: Option(TLCurrentVariant(v)),
  history history: List(TLPastVariant(v)),
) -> TLSliceByDay(v) {
  TLSliceByDay(interval:, variants: TLSliceVariants(current:, history:))
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------- QUERY ----------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Checks if a TLSliceByDay is empty.
pub fn is_empty(slice: TLSliceByDay(v)) -> Bool {
  slice.variants.current == None && list.is_empty(slice.variants.history)
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// --------------------- CONVERSIONS --------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Converts a TLSliceByDay to a list of AnyVariants.
/// 
/// For when you just need to map over stuff.
/// 
/// You will lose the bounding data for the Slice.
pub fn to_any_list(slice: TLSliceByDay(v)) -> List(TLAnyVariant(v)) {
  slice.variants
  |> tl_slice_variants.to_any_list()
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ----------------------- CHOPPING ---------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Slices a TLSliceByDay with a DayInterval.
/// 
/// If the new MomentInterval isn't fully encapsulated by
/// the existing MomentInterval, the function will return
/// Error(Nil).
pub fn chop(
  slice: TLSliceByDay(v),
  by new_interval: DayInterval,
) -> TLSliceByDay(v) {
  let current = case slice.variants.current {
    None -> None
    Some(c) ->
      case tl_current_variant.is_effective_in_day_interval(c, new_interval) {
        False -> None
        True -> Some(c)
      }
  }

  let history =
    slice.variants.history
    |> list.filter(keeping: fn(x) {
      tl_past_variant.is_effective_in_day_interval(x, new_interval)
    })

  TLSliceByDay(
    interval: new_interval,
    variants: TLSliceVariants(current:, history:),
  )
}
