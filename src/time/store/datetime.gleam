import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import tempo.{type DateTime}
import tempo/datetime
import tempo/duration
import tempo/naive_datetime
import time/store/offset.{type OffsetStore} as offset_store

/// A type representation of what DateTimes look like when they're stored.
/// 
/// This is an interface layer to the JSON database, enabling me to have simple
/// resilient types while choosing whatever types are convenient in the
/// larger logic of the application.
pub opaque type DateTimeStore {
  DateTimeStore(unix_milli: Int, offset: OffsetStore)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------]

fn from_datetime(datetime: DateTime) -> DateTimeStore {
  DateTimeStore(
    unix_milli: datetime.to_unix_milli(datetime),
    offset: datetime
      |> datetime.get_offset
      |> offset_store.from_offset,
  )
}

/// tempo has a really weird system with offsets. just roll with it...
fn to_datetime(store: DateTimeStore) -> Result(DateTime, Nil) {
  case offset_store.to_offset(store.offset) {
    Error(_) -> Error(Nil)
    Ok(offset) ->
      store.unix_milli
      |> datetime.from_unix_milli
      |> datetime.add(duration.minutes(store.offset))
      |> datetime.apply_offset
      |> naive_datetime.set_offset(offset)
      |> Ok
  }
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ----------------------- JSON ------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// The string function used for all DateTimes
/// in the Database apart from dict keys.
pub fn to_json(datetime: DateTime) -> Json {
  let store = from_datetime(datetime)
  json.object([
    #("unix_milli", store.unix_milli |> json.int),
    #("offset", store.offset |> json.int),
  ])
}

/// A version of DateTimes decoding for the application
/// as a Decoder primitive.
pub fn decoder() -> Decoder(DateTime) {
  let default = datetime.literal("2025-03-08T00:00:00.000Z")
  decode.new_primitive_decoder("DateTime", fn(datetime) {
    let datetimestore_decoder = {
      use unix_milli <- decode.field("unix_milli", decode.int)
      use offset <- decode.field("offset", decode.int)
      decode.success(DateTimeStore(unix_milli:, offset:))
    }
    case decode.run(datetime, datetimestore_decoder) {
      Error(_) -> Error(default)
      Ok(store) -> {
        case to_datetime(store) {
          Ok(datetime) -> Ok(datetime)
          Error(_) -> Error(default)
        }
      }
    }
  })
}
