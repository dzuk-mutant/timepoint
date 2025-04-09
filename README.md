# timepoint

I've been writing an application in Gleam that relies heavily on time and calendar types and functionality, but found myself wishing for functionality from different parts, notably the core concept that UNIX epoch and similarly-styled structures should define all backend timekeeping and storage, while Gregorian datetimes should be treated as just ways of contextualising and representing the former.

This is just a mess rn, don't pay it too much attention <3.

```
ideas


Precise point in time
---------------------
- Timestamp ('naive'/pure, no contextualising info)
- TimestampWithOffset (minimum required info for a full local datetime)

Relative point in time
--------------------
- SolarDay (UNIX Epoch/Rata Die, sth like that - a calendar day but not specific to any calendar)

Representations/Contextualisations
--------------------
Gregorian
- Gregorian Date ('naive')
- Gregorian DateTime ('naive')
- Gregorian Date (w/ offset)
- Gregorian DateTime (w/ offset)

ISO
- ISO Week Date

...etc.

Progression
--------------------
- Duration
- - Solar days, imperial hours, minutes, seconds, internet time beats if you want to be silly, etc.

Framing
--------------------
- TimestampWindow
- SolarDayWindow
- Collision



```



Right now, this module is a loose concept, bridging gleam_time, gtempo, as well as other functionality such as time windowing, window collision detection and ISO Week Dates, but in the future it might be its own thing?

