import tempo.{type Offset}
import time/store/offset as offset_store

/// An offset equality function as tempo doesn't have one yet.
pub fn is_equal(offset_1: Offset, to offset_2: Offset) -> Bool {
  let num_1 =
    offset_1
    |> offset_store.from_offset

  let num_2 =
    offset_2
    |> offset_store.from_offset

  num_1 == num_2
}
