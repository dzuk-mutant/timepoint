import gleam/list
import gleam/option.{type Option, None, Some}
import moment_interval.{type MomentInterval}
import versioning/timelined/tl_any_variant.{type TLAnyVariant}
import versioning/timelined/tl_current_variant.{type TLCurrentVariant}
import versioning/timelined/tl_past_variant.{type TLPastVariant}
import versioning/timelined/tl_slice_variants.{
  type TLSliceVariants, TLSliceVariants,
}

/// A slice of a Timelined. When a Timelined is 
/// filtered, this type or TLSliceByDay is returned.
/// 
/// There are two different types because the interval can be by Day
/// or DateTime and they are fundamentally two different things.
pub opaque type TLSliceByMoment(v) {
  TLSliceByMoment(interval: MomentInterval, variants: TLSliceVariants(v))
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// --------------------- CONSTRUCTORS --------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

pub fn new(
  interval interval: MomentInterval,
  current current: Option(TLCurrentVariant(v)),
  history history: List(TLPastVariant(v)),
) -> TLSliceByMoment(v) {
  TLSliceByMoment(interval:, variants: TLSliceVariants(current:, history:))
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------- QUERY ----------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Checks if a TLSliceByMoment is empty.
pub fn is_empty(slice: TLSliceByMoment(v)) -> Bool {
  slice.variants.current == None && list.is_empty(slice.variants.history)
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// --------------------- CONVERSIONS --------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Converts a TLSliceByMoment to a list of AnyVariants.
/// 
/// For when you just need to map over stuff.
/// 
/// You will lose the bounding data for the Slice.
pub fn to_any_list(slice: TLSliceByMoment(v)) -> List(TLAnyVariant(v)) {
  slice.variants
  |> tl_slice_variants.to_any_list()
}

// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ----------------------- SLICING ----------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------
// ------------------------------------------------------------

/// Filters a TLSliceByMoment with a new MomentInterval.
/// 
/// If the new MomentInterval isn't fully encapsulated by
/// the existing MomentInterval, the function will return
/// Error(Nil).
pub fn chop(
  slice: TLSliceByMoment(v),
  by new_interval: MomentInterval,
) -> TLSliceByMoment(v) {
  let current = case slice.variants.current {
    None -> None
    Some(c) ->
      case tl_current_variant.is_effective_in_moment_interval(c, new_interval) {
        False -> None
        True -> Some(c)
      }
  }

  let history =
    slice.variants.history
    |> list.filter(keeping: fn(x) {
      tl_past_variant.is_effective_in_moment_interval(x, new_interval)
    })

  TLSliceByMoment(
    interval: new_interval,
    variants: TLSliceVariants(current:, history:),
  )
}
