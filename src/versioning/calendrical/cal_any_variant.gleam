import versioning/calendrical/cal_current_variant.{type CalCurrentVariant}
import versioning/calendrical/cal_past_variant.{type CalPastVariant}

/// It's really useful and important that current and
/// past variants have their own types - it keeps data storage
/// and functions for each data type really clean.
/// 
/// But there are some situations - such as with filtering -
/// where you really might need to get either a Current
/// or a Past Vasriant, and this is where this wrapper
/// comes in.
/// 
pub type CalAnyVariant(v) {
  Current(CalCurrentVariant(v))
  Past(CalPastVariant(v))
}

/// Unwraps a CalAnyVariant, no matter which variant is
/// underneath.
pub fn unwrap(variant: CalAnyVariant(v)) -> v {
  case variant {
    Current(ccv) -> cal_current_variant.unwrap(ccv)
    Past(cpv) -> cal_past_variant.unwrap(cpv)
  }
}
