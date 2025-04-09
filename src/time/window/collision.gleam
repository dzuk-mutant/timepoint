/// A type representing the possible locations that
/// a single point in time can be in relation to
/// a DateWindow or DateTimeWindow.
pub type PointCollision {
  PointBeforeStart
  PointAtStart
  PointInside
  PointAtFinal
  PointAfterFinal
}
