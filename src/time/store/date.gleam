import gleam/dynamic/decode.{type Decoder}
import gleam/int
import gleam/json.{type Json}
import tempo.{type Date}
import tempo/date

/// A type representation of what Dates look like when they're stored.
/// 
/// This is an interface layer to the JSON database, enabling me to have simple
/// resilient types while choosing whatever types are convenient in the
/// larger logic of the application.
pub opaque type DateStore {
  DateStore(rata_die: Int)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

fn from_date(date: Date) -> DateStore {
  DateStore(rata_die: date.to_rata_die(date))
}

fn to_date(store: DateStore) -> Date {
  store.rata_die
  |> date.from_rata_die()
}

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- JSON ------------------------
// ----------------------------------------------------
// ----------------------------------------------------

/// The string function used for all Dates
/// in the Database apart from dict keys.
pub fn to_json(date: Date) -> Json {
  let store = from_date(date)
  json.int(store.rata_die)
}

/// A very annoying exception to encoding - Dict keys
/// require strings, and doing them the normal way
/// doesn't work, soooo...
pub fn to_json_dict_key(date: Date) -> String {
  date
  |> date.to_rata_die
  |> int.to_string
}

/// A version of Date decoding for the application
/// as a Decoder primitive.
/// 
/// This is for when Dates are stored as values, which
/// are Ints.
pub fn decoder() -> Decoder(Date) {
  let default = date.literal("2000-01-01")
  decode.new_primitive_decoder("Date", fn(date) {
    case decode.run(date, decode.int) {
      Error(_) -> Error(default)
      Ok(rd) ->
        DateStore(rata_die: rd)
        |> to_date
        |> Ok
    }
  })
}

/// A version of Date decoding for the application
/// as a Decoder primitive.
/// 
/// This is for when Dates are stored as dict keys, which
/// have to be Strings.
pub fn decoder_dict_key() -> Decoder(Date) {
  let default = date.literal("2000-01-01")
  decode.new_primitive_decoder("Date", fn(date) {
    case decode.run(date, decode.string) {
      Error(_) -> Error(default)
      Ok(str) ->
        case int.parse(str) {
          Error(_) -> Error(default)
          Ok(rd) ->
            DateStore(rata_die: rd)
            |> to_date
            |> Ok
        }
    }
  })
}
