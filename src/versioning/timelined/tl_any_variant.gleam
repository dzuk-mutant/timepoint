import versioning/timelined/tl_current_variant.{type TLCurrentVariant}
import versioning/timelined/tl_past_variant.{type TLPastVariant}

/// It's really useful and important that current and
/// past variants have their own types - it keeps data storage
/// and functions for each data type really clean.
/// 
/// But there are some situations - such as with filtering and mapping -
/// where you really might need to get either a Current
/// or a Past Vasriant, and this is where this wrapper
/// comes in.
/// 
pub type TLAnyVariant(v) {
  Current(TLCurrentVariant(v))
  Past(TLPastVariant(v))
}

/// Unwraps a CalAnyVariant, no matter which variant is
/// underneath.
pub fn unwrap(variant: TLAnyVariant(v)) -> v {
  case variant {
    Current(ccv) -> tl_current_variant.unwrap(ccv)
    Past(cpv) -> tl_past_variant.unwrap(cpv)
  }
}
