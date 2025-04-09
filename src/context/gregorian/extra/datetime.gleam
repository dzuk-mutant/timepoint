import gleam/order.{type Order}
import tempo.{type DateTime}
import tempo/datetime

// ----------------------------------------------------
// ----------------------------------------------------
// --------------------- DATES ------------------------
// ----------------------------------------------------
// ----------------------------------------------------
pub fn order_reverse(a: DateTime, b: DateTime) -> Order {
  datetime.compare(a, b)
  |> order.negate
}
