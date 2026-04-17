import gleam/list
import gleam/option.{type Option, None, Some}
import versioning/timelined/tl_any_variant.{type TLAnyVariant, Current, Past}
import versioning/timelined/tl_current_variant.{type TLCurrentVariant}
import versioning/timelined/tl_past_variant.{type TLPastVariant}

/// An internal type representing the variants in either of the
/// slice types, to streamline internal functionality.
pub type TLSliceVariants(v) {
  TLSliceVariants(
    current: Option(TLCurrentVariant(v)),
    history: List(TLPastVariant(v)),
  )
}

/// Converts a TLSlice to a list of AnyVariants.
/// 
/// For when you just need to map over stuff.
/// 
/// You will lose the bounding data for the Slice.
pub fn to_any_list(slice_variants: TLSliceVariants(v)) -> List(TLAnyVariant(v)) {
  let mapped_history =
    slice_variants.history
    |> list.map(fn(x) { Past(x) })

  case slice_variants.current {
    Some(current) -> [Current(current), ..mapped_history]
    None -> mapped_history
  }
}
