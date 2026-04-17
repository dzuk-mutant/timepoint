import gleam/dynamic/decode.{type Decoder}
import gleam/int
import gleam/json.{type Json}
import gleam/order.{type Order}
import tempo
import tempo/duration as gtempo_duration
import tempo/offset as gtempo_offset
import duration.{type Duration}

/// Offsets are the measure by which time is shifted in timezones.
/// 
/// Offsets are stored as an Int representing minutes.
pub opaque type Offset {
  Offset(minutes: Int)
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- CONVERSION ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

pub fn to_duration(offset: Offset) -> Duration {
  offset.minutes
  |> duration.minutes
}

/// Returns the value of the offset in minutes as an Int.
pub fn to_minutes(offset: Offset) -> Int {
  offset.minutes
}

/// Creates an Offset from a number of minutes given as an Int.
/// 
/// This constructor assumes the minutes coming in are within correct
/// bounds, this does not check to see if it does.
/// 
/// But this app only gets offsets internally; if it's coming in
/// wrong, there's something seriously wrong with the user's computer.
/// 
/// ( mins < -720 || mins > 840 )
pub fn from_minutes(mins: Int) -> Offset {
  Offset(minutes: mins)
}

/// Creates a Timepoint Offset from a gtempo offset.
pub fn from_gtempo_offset(offset: tempo.Offset) -> Offset {
  Offset(
    minutes: offset
    |> gtempo_offset.to_duration
    |> gtempo_duration.as_minutes,
  )
}

/// Creates an Offset in the gtempo package from an Timepoint Offset.
/// 
/// Currently the same guards are in place to prevent out of bounds offsets
/// from being passed in Timepoint and gtempo but I'm keeping the result a
/// result in case things change.
pub fn to_gtempo_offset(offset: Offset) -> Result(tempo.Offset, Nil) {
  offset.minutes
  |> gtempo_duration.minutes
  |> gtempo_offset.from_duration
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -------------------- COMPARISON ---------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

/// Returns True if both Offsets are equal.
pub fn is_equal(offset_1: Offset, to offset_2: Offset) -> Bool {
  to_minutes(offset_1) == to_minutes(offset_2)
}

/// Compares the values of each offset against each other.
pub fn compare(offset_1: Offset, to offset_2: Offset) -> Order {
  int.compare(to_minutes(offset_1), with: to_minutes(offset_2))
}

// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// ---------------------- JSON -------------------------
// -----------------------------------------------------
// -----------------------------------------------------
// -----------------------------------------------------

const default: Offset = Offset(minutes: 0)

pub fn to_json(offset: Offset) -> Json {
  offset.minutes
  |> json.int()
}

/// Will fail if the given minutes are in an invalid range.
pub fn decoder() -> Decoder(Offset) {
  decode.new_primitive_decoder("Offset", fn(offset) {
    case decode.run(offset, decode.int) {
      Error(_) -> Error(default)
      Ok(mins) ->
        case is_valid(mins) {
          False -> Error(default)
          True -> Ok(from_minutes(mins))
        }
    }
  })
}

pub fn is_valid(minutes: Int) -> Bool {
  minutes >= -720 && minutes <= 840
}
