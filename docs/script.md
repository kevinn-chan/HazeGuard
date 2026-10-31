# HazeGuard video script (draft, 1 Nov 2026)

Every number comes from the frozen files in `frozen_2026-11-01/` (data to 31 Oct 2026). Target length 7:15 at about 130 words a minute; the limit is 8:00. Slide cues are in square brackets and are not spoken.

## S1: Hook and recommendation (Jovan, 1:00, 130 words)

[Slide 2: the problem]
On the 25th of October, runners at the Garmin Run Singapore woke up to haze. Every race was cut to a ten-kilometre fun run, and nobody got their money back. At 8am that morning, Central's PSI read 113, in the unhealthy range. A week earlier, it had peaked at 230.

Picture a runner who paid a hundred and five dollars for that ticket. Organisers can't stop the haze, but they can price it.

[Slide 3: our answer]
Our answer is HazeGuard: an add-on that refunds the ticket if Central's PSI is above 100 at 8am on event day.

Our recommendation, up front: price it by the kind of year. In a normal year, under a dollar a ticket. In an El Niño year, about thirty-three dollars.

Kevin will show you when haze hits.

## S2: When and how haze hits (Kevin, 1:30, 195 words)

[Chart 1]
We used every hourly PSI reading NEA has published since April 2014: over a hundred and ten thousand hours, with none missing. Each blue dot is a day when some part of Singapore went above 100. Two seasons stand apart: 2015, with 46 such days in September and October, and this year, with 39. No other year had more than nine.

[Chart 2]
When does it happen? Ninety percent of haze days since 2014 fell in September or October. That's the window HazeGuard has to price: an event in March is almost never at risk; an event in October can be.

[Chart 3]
And haze doesn't arrive one day at a time. We defined a hazy morning the way HazeGuard pays out: Central above 100 at 8am. After a hazy morning, the next one is hazy 65 percent of the time. After a clear morning, just 3 percent. Bad days come in runs, so races on back-to-back weekends share their risk.

That raises the real question: what makes one season so much worse than another? Nott?

## S3: Is El Niño the driver, and how much worse? (Nott, 2:00, 260 words)

[Chart 4]
Our suspect was El Niño, the Pacific pattern that dries out the region's forests and peatlands. NOAA publishes an El Niño index in early September, before the haze season starts. Each dot here is one season. In El Niño seasons, the refund would have triggered on 31 percent of mornings. In every other season, under one percent.

Could that be luck? We tested it. If El Niño made no difference, a gap this large would happen far less than once in a billion tries. So the difference is real.

But how sure are we about the average risk? Counting days, our interval is 6 to 10 percent. Counting seasons, which is fairer because bad days cluster, it's 0 to 18 percent. With only thirteen seasons, a single average hides more than it shows. That's why we price each kind of year separately.

[Regression slide]
Next: how much worse? We regressed Central's 8am PSI on the El Niño index, controlling for the month. Every one-point rise in the index adds about 18 to the PSI. For a typical October, that's about 59 in a neutral year, and about 91 this year, when the index was 1.8. That's close to the trigger line before any bad luck. The model explains about 40 percent of the variation, so El Niño is the main driver, but not the only one.

So we know when haze hits, and what drives it. Ahmad will turn that into a price.

## S4: Pricing the refund (Ahmad, 1:45, 225 words)

[Chart 5]
To price HazeGuard, we simulated ten thousand seasons of eight weekly events in September and October, with the haze runs we just saw built in. The fair price is the average payout on a hundred-and-five-dollar ticket.

In a normal year, that's 87 cents. In an El Niño year, it's 33 dollars 25, because at least one of the eight events pays out in 95 percent of El Niño seasons.

An organiser also has to survive a bad year, so we set a safe price that covers 95 percent of simulated seasons. Treat every year alike and the safe price is 26 dollars 25. Model El Niño separately and it's 52 dollars 50: double. Price every year the same and you're short half the money in a bad year.

[Three-day slide]
Runs matter too. The chance of three hazy event days in a row is 3.2 percent with the runs built in, against 0.05 percent if days were independent.

How robust is this? Leaving out one El Niño season moves its trigger rate anywhere from 23 to 46 percent, so the El Niño price is an estimate, not a certainty.

Finally, Swiss Re's HazeShield only pays after 20 bad days in a season. Only 2015 and 2026 would ever have paid. HazeGuard covers the single ruined Sunday.

Jovan will close with what organisers should do.

## S5: What organisers should do; limits; close (Jovan, 1:00, 130 words)

[Slide 11: recommendations]
So what should organisers do? Three things.

First, offer HazeGuard at checkout every season, priced in early September when NOAA publishes the El Niño index: under a dollar in a normal year, about thirty-three in an El Niño year.

Second, in El Niño years, move flagship outdoor events out of September and October, or book an indoor backup.

Third, use HazeShield for catastrophic seasons and HazeGuard for the single bad Sunday. They fit together.

[Slide 12: limits and sources]
Our limits: only thirteen seasons and three El Niño years, and one region at one hour. Re-run this every September.

On the 25th of October, a runner lost a race and a hundred and five dollars. With HazeGuard, they'd have had their money back. Thank you.
