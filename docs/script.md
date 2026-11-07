# HazeGuard video script (final, synced from the Google Doc Script tab, 8 Nov 2026)

[Slide deck](https://docs.google.com/presentation/d/1v-30mXISYxAPExUz_2gnlpvnAWadpmripMDXbMrpFz4/edit?slide=id.p1#slide=id.p1)

Final draft, Sun 1 Nov 2026, with frozen numbers (data to 31 Oct). Total about 1,105 spoken words, about 8:30 at 130 words a minute; 1,158 words and about 8:55 with the optional skit. That is over the 8:00 limit, so trim in the edit (no speed-up allowed). It builds on Jovan's S1, S5 and skit drafts in the M4 tab. Slide cues in [brackets] are not spoken. M4 finalises it here by Wed 4 Nov; M3 checks every number against the table at the bottom.

How to use it: read your own segment aloud with a timer, keep to its word budget, and end with your hand-over line. Change wording freely, but never a number: every number must match the frozen files in the Drive folder frozen_2026-11-01.

[Slide 1: Youtube Thumbnail]

## Optional Skit (Ahmad & Nott, 30 Seconds)
*[Outside a hall, 8am]*

Ahmad: Nott? What are you doing back at hall so early? Don’t you have a marathon today?

Nott: I did and it's already over! They cut every race to a 10 Km fun race due to the haze! How disappointing.

Ahmad: And your ticket?

Nott: Full price. No refund.

Ahmad: Someone should fix that.

## S1: Hook and recommendation (Jovan, 1 Minute)
*[Slide 2: the problem]*

Haze needs no introduction. This year the PSI in Singapore peaked at 230 and it doesn't just hurt our lungs; it ruins the events we've paid for.

Two recent examples are Decathlon's Kiprun Half Marathon which was cut to a ten-kilometre non-competitive run in view of the haze and the Garmin Run on 25th of October which was converted to a 10km fun run. In both situations, runners had paid for full price tickets but had their experiences cut short with no refund!

*[Slide 3: our answer]*

In view of this, we designed HazeGuard! An add-on insurance that refunds your ticket should Central’s PSI be above 100 at 8am on the event day.

Our recommendation has two different price points based on the kind of year it is. In a normal year, the add-on costs are under a dollar. Meanwhile, in an El Nino year, it would be priced at about $33.

Now, Kevin will show you how the data got us there.

## S2: When and how haze hits (Kevin, 1 Minute, 45 Seconds)
*[Slide 4]*

To better understand when the Haze worsens, we extracted the hourly PSI reading NEA has published since April 2014. This amounted to over one hundred and ten thousand hours with no data point missing.

*[Slide 5: 00_data_quality.csv]*

We then plotted a graph with each blue dot representing a day when some part of Singapore registered a PSI reading above 100. Looking at the data, two years stood out. 2015 where 46 such days occurred and this year with 39 such occurrences. Meanwhile in other years, there were 9 or fewer such days in September and October.

*[Slide 6]*

Taking a closer look, we found that 90% of these unhealthy Haze days since 2014 occurred during the months of September and October with no other months coming close to that number. Hence, an event in March is almost never at risk while an event in October can be, and that's the window HazeGuard has to price.

*[Slide 7]*

But haze doesn't arrive one day at a time. We defined a hazy morning the way HazeGuard pays out: Central’s PSI above 100 at 8am. After a hazy morning, the next one is hazy 65% of the time. Meanwhile, after a clear morning, the likelihood stands at only 3%. This correlation shows that Haze occurs in continuous stretches, so races on back-to-back weekends share a higher risk.

This raises the real question: what makes one season so much worse than another?

## S3: Is El Niño the driver, and how much worse? (Nott, 2 Minutes)
*[Slide 8]*

Our prime suspect is El Niño, the Pacific pattern that dries out the region's forests and peatlands. We extracted NOAA’s El Nino index they published in early September, before the haze season started. Based on the graph, with each dot representing one season, we found that the refund would have triggered on 31% of mornings during an El Nino season while the trigger rate in every other season was under 1%.

But could that be just luck? Well, looking at it day by day, a gap this large would almost never happen by pure chance. However, since bad days tend to cluster, a fairer test would be to compare the seasons as a whole. Even then, a gap this large turns up only about once in a hundred. Hence, we can conclude that the difference in refund trigger rate is real.

But how sure are we about the average risk? If we were to count days, our interval is 6 to 10 percent. But if we were to count seasons, it would instead be 0 to 18 percent. With there only being 13 seasons, a single average hides more than it shows. Hence, we chose to price each type of year differently.

*[Slide 9]*

Next, to find out how much worse, we regressed Central’s 8am PSI on the El Nino index, controlling for the month. Every one-point rise in the index adds about 17.82 to the PSI. For a typical October in a neutral year, that's about 59. Meanwhile, using the current year’s index of 1.8, it amounts to 91. That's close to the trigger line before any bad luck. The model also explains about 39.6% of the variation, indicating that although El Nino is a main driver, it is not the only one.

So now that we know when haze hits and what drives it, Ahmad will turn that into a price.

## S4: Pricing the refund (Ahmad, 1 Minute 45 Seconds)
*[Slide 10]*

To price HazeGuard, we simulated 10,000 seasons of 8 weekly events in September and October, with the haze runs we just saw built in. Taking a $105 ticket, the fair price (FP) refers to the expected payout while the safe price (SP) is set to cover 95% of simulated seasons to ensure the organiser survives a bad year too.

After running the simulations, we found that in a normal year, the FP is 87 cents while in an El Nino year, it's $33.25. This happened because, on average, about 2.5 of the 8 events trigger a refund in an El Nino season.

Ignoring El Nino and haze runs, a safe price would be $26.25 based on the naive model and twice the price in the mixture model, amounting to $52.50. Hence, should we price every year the same, half of the risk becomes hidden.

*[Slide 11: Accounting for the runs]*

However, runs matter too. With the runs built in, the chance that a three-day festival is hazy on all three days is 3.2%, against just 0.05% if days were independent. And the El Nino price is an estimate, not a certainty: leave out any one El Nino season and its trigger rate moves anywhere from 23 to 46%.

*[Flash 06_hazeshield.csv on screen]*

Hence, since Swiss Re's HazeShield, an existing haze insurance product, only pays after 20 bad days in a season, their protection would only ever have paid during 2015 and 2026. HazeGuard fills that gap by covering the single ruined Sunday.

Jovan will now close with what organisers should do.

## S5: What organisers should do; limits; close (Jovan, 1 Minute)
*[Slide 12: recommendations]*

So what should organisers do? Three things.

Firstly, they should offer HazeGuard as an add-on at checkout and price it in early September when NOAA publishes the El Nino index. Under a dollar in a normal year and about $33 in an El Nino year.

Secondly, in an El Nino year, they can move flagship outdoor events out of September and October, or to an indoor venue.

Lastly, offer HazeGuard alongside HazeShield. HazeShield to cover the catastrophic season and HazeGuard to cover the single bad Sunday.

*[Slide 13: limits]*

The limits of our research are that there are only 13 Seasons and 3 El Nino years for us to analyse. Hence leaving out one season changes the results drastically, and we use one region at one hour. To counter this, we should re-run this every September.

In conclusion, looking for the best way to protect your event day from the haze? Opt for HazeGuard. Thank you.

## Where each number comes from (M3 checks these)
  - PSI peaked at 230: m1_numbers.csv: peak_2026 (18 Oct)
  - Central's PSI 113 at 8am on 25 Oct: data/psi_hourly.csv, 2026-10-25 08:00, central
  - Under a dollar / about thirty-three dollars: 05_prices.csv: fair_price normal 0.87, elnino 33.25
  - Over 110,000 hours, none missing: 00_data_quality.csv: total_hours 110,327; missing_hours 0
  - 46 and 39 days; no other year above nine: m1_numbers.csv: bad_days_2015, bad_days_2026; psi_season.csv bad_days
  - Ninety percent in Sep or Oct: m1_numbers.csv: sep_oct_share 90.4
  - 65 percent and 3 percent: m1_numbers.csv: p_hh 0.645, p_hc 0.031
  - 31 percent against under one percent: 03_inference.csv: p_elnino 0.311, p_normal 0.008
  - About once in a hundred tries: 03_inference.csv: p_value_season 0.0105 (days: p_value_elnino 5e-40)
  - 6 to 10 percent; 0 to 18 percent: 03_inference.csv: ci_day 0.061–0.100; ci_season 0–0.181
  - 17.82 per point; 59 and 91; 39.6 percent: 04_regression.csv: oni_jja 17.82; pred_oct_oni_0 59.0, pred_oct_oni_1.8 91.1; r_squared 0.396
  - Ten thousand seasons, eight weekly events: R/05_simulate.R: N = 10000, events on days 7, 14, …, 56
  - 87 cents; $33.25; about 2.5 of the 8 events: 05_prices.csv: fair_price 0.87, 33.25; elnino mean_hits 2.53
  - $26.25 and $52.50: 05_prices.csv: safe95_price naive 26.25, mixture 52.50
  - 3.2 percent against 0.05 percent: 05_threeday.csv: markov 0.032, iid 0.00048
  - 23 to 46 percent: 06_sensitivity.csv: elnino_drop_2026 0.230, elnino_drop_2023 0.459
  - 20 bad days; only 2015 and 2026: 06_hazeshield.csv: payout_pct (2015 100%, 2026 80%)
  - Thirteen seasons, three El Niño years: psi_season.csv: 13 rows, el_nino TRUE for 2015, 2023, 2026

## Sources for the spoken facts
  - PSI readings: NEA via data.gov.sg (historical 24-hr PSI and the real-time API), frozen to 31 Oct 2026.
  - El Niño index: NOAA Climate Prediction Center, Oceanic Niño Index.
  - Decathlon Kiprun Half Marathon shortened to 10 km: Mothership, September 2026 (link in the M1 tab references).
  - Garmin Run, 25 Oct, every race cut to a 10 km fun run: from Jovan's research. M4 to add the source link here before 4 Nov.
  - HazeShield pays from 20 bad days: Swiss Re HazeShield brochure (link in the M1 tab references).
