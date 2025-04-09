import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import tempo.{type Offset}
import tempo/duration
import tempo/offset

/// Represents a stored Offset in the JSON.
/// 
/// Offsets are stored as an Int representing minutes.
pub type OffsetStore =
  Int

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn from_offset(offset: Offset) -> OffsetStore {
  offset
  |> offset.to_duration
  |> duration.as_minutes
}

pub fn to_offset(store: OffsetStore) -> Result(Offset, Nil) {
  store
  |> duration.minutes
  |> offset.from_duration
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ---------------------- JSON -------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const default: OffsetStore = 0

pub fn to_json(offset: Offset) -> Json {
  offset
  |> from_offset
  |> json.int()
}

/// For now, this exists only internally, but I think
/// its good to keep as a conneting reference implementation
/// if types actively used in the app change.
fn decoder_internal() -> Decoder(OffsetStore) {
  decode.new_primitive_decoder("Offset", fn(store) {
    case decode.run(store, decode.int) {
      Error(_) -> Error(default)
      Ok(mins) -> Ok(mins)
    }
  })
}

/// A decoder that goes from an OffsetStore to an Offset.
/// 
/// A cleaner, quicker shorthand.
pub fn decoder() -> Decoder(Offset) {
  let offset_default = offset.literal("+00:00")
  let store_decoder = decoder_internal()
  decode.new_primitive_decoder("Offset", fn(offset) {
    case decode.run(offset, store_decoder) {
      Error(_) -> Error(offset_default)
      Ok(store) ->
        case to_offset(store) {
          Error(_) -> Error(offset_default)
          Ok(offset) -> Ok(offset)
        }
    }
  })
}
