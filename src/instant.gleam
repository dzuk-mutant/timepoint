import tempo.{type Instant}
import tempo/instant as gtempo_instant
import day.{type Day}
import moment.{type Moment}

// just some glue between gtempo and timepoint for now

pub fn now() -> Instant {
  gtempo_instant.now()
}

pub fn as_moment(instant: Instant) -> Moment {
  instant
  |> gtempo_instant.as_local_datetime
  |> moment.from_gtempo_datetime
}

pub fn as_day(instant: Instant) -> Day {
  instant
  |> gtempo_instant.as_local_date
  |> day.from_gtempo_date
}
