---
layout: post
title: "Pension in Japan"
tags: japan money
---

I'm still pretty far from retirement, but recently I've been looking into how the pension works in Japan, so I'll share my learnings in this post.

<!--break-->

There are multiple sources of pension payments one can receive in Japan, I'll cover the ones that I found relevant for my situation as a full time company employee.

## Public pensions

As a company employee I'm paying (and thus eligible to receive) two types of public pension.

### National Pension, 国民年金

This is mandatory for everybody between the age of 20 and 59 living in Japan. For people who need to pay this for themselves, it costs 16,980 yen/month (regardless of the income), but for full time employees this is included in the Employee's Pension (see below). ([source](https://www.nenkin.go.jp/international/japanese-system/nationalpension/nationalpension.html))

Since everyone pays the same amount, everyone will get the same amount. In 2024 this was ￥816,000 per year, assuming you paid for the full 40 years (20-59 years of age). I moved to Japan when I was 26, so for me this gets prorated and I expected to receive around `34/40*816,000=693,600 yen` (simplified calculation, the real number depends on the actual months I paid into the system so it will be 685,100 yen as I moved to Japan 5 months after my 26th birthday). ([source](<https://www.nenkin.go.jp/international/japanese-system/nationalpension/nationalpension.html#:~:text=Category%20%E2%85%A2%20insured%20person.-,Benefit%20Amount%20(Fiscal%20year%202024),-%EF%BF%A5816%2C000*%20(annual%20benefit>) and my NenkinNet estimate)

So this is 68,000 yen per month for the average person (and only 57,092 yen for me).

### Employees' Pension Insurance, 厚生年金

As a company employee I'm actually paying into this second pension, and expect to receive pension from it. Here the contributions are proportional to my salary, and the payout will also depend on the amount contributed.

The contribution is calculated as 18.3% of one's base salary plus fixed allowances (but not bonuses), and the company pays half of it, while the other half gets deducted from one's salary. So effectively 9.15% gets deducted from each paycheck (except the yearly bonus).

The payout can be calculated with this formula: `5.481*(yearly incomes in all years while contributing)/1000`. So e.g. someone with an average yearly income of 15 million yen and 34 years of contributions this would be 2,795,310 yen per year (or 232,942.5 yen per month).

### Inflation adjustment

While these numbers are pretty low, at least they get adjusted by inflation (sort of): I won't actually get 685,100 yen per year from the national pension, I will get a higher number, but I will be able to buy close to the same amount of stuff as 685,100 yen would get me today.

[This reddit post](https://www.reddit.com/r/JapanFinance/comments/1i8q39k/pension_benefits_amount_for_2025/) nicely summarizes the yearly adjustment for 2024:

> As always, and as mandated by law, pension benefits for people under age 68 move in line with average wages (minus the macroeconomic slide), whereas pension benefits for people over age 68 move in line with inflation (minus the macroeconomic slide). This year, average wages were up 2.3% and inflation was 2.7%. The macroeconomic slide was calculated as -0.4%. The same as last year, the macroeconomic slide includes a -0.1% adjustment for the change in the number of pension benefit recipients, and a -0.3% adjustment for the increase in the average life expectancy.
> For example, national pension benefits (Kokumin Nenkin) will increase from ¥68,000 to ¥69,308.

Though that -0.4% is sad: it should have gone up by 2.3% but instead it only went up by 1.9%. If this would stay the same for the next 34 years (until I hit 65), then that will reduce the purchasing power of the pension to `(1-0.004)^34=87%`. So instead of today's  685,100 yen worth of stuff, I will only be able to get 597,821 yen of stuff. Actually not that bad, if it means that the system stays functional.

### Funding

So where is the money coming from for this pension? Currently there are two sources:

|  | Current contributions | Government subsidies (from taxes) |
| --- | --- | --- |
| National Pension | 50% | 50% |
| Employees' Pension Insurance | 75% | 25% |

Sources:

* [Chapter 1 Overview of the Pension System in Japan, page 4](https://www.mhlw.go.jp/english/org/policy/dl/p36-37p2.pdf)
* [Overview of the Annual Actuarial Report on the Public Pension Plans in Japan FY2022, page 24](https://www.mhlw.go.jp/english/org/policy/dl/p36-37a2022_fy_summary.pdf) for the Employees' Pension Insurance

The aging population threatens the sustainability of this system, which they are trying to address in two ways:

* the macroeconomic slide shown above that slightly reduces the value of the payouts year-over-year to avoid a drastic drop or insolvency
* the [Government Pension Investment Fund](https://www.gpif.go.jp/en/) (GPIF), which is the largest pool of retirement savings in the world ([source](https://en.wikipedia.org/wiki/Government_Pension_Investment_Fund)) with a whopping 258.7 trillion yen (258.7兆円) under management, which is about 2 million yen per every person in Japan. And this is currently not being used for pension payments yet, and with a rate of return of 4.4%/year (FY2001-FY2024Q3) it will just continue to grow.

## Private pension

Another way the government is trying to address this is by encouraging people to save for their own retirement. The defined-contribution (DC) pension scheme [introduced in the early 2000s provides](https://www.ipss.go.jp/s-info/e/jasos2002/c_2.html#:~:text=5.-,Defined%2DContribution%20pension%20schemes,-The%20newly%20introduced) tax benefits to lock up money in an investment account where it can't be withdrawn until retirement.

My current and previous companies both participate in this. At my current role the company puts 28,000 yen every month into this account (for my role), and I can choose to contribute up to 27,000 yen per month (normally up to the company contribution, but there is an overall cap of 55,000 yen). Both of these are free of income tax at contribution time, so it is highly beneficial to contribute the maximum amount (as otherwise that 27,000 yen could loose up to half of its value to tax, depending on the tax bracket).

Money in a DC account can be invested according to the owner's liking, however the brokerage is decided by the employer, so the available funds are often limited. I wanted to have something that's similar to a [globally diversified stock fund with low fees]({% post_url 2023-11-16-new-nisa-plans %}). The closest thing my company's brokerage offers is the [5. 野村外国株式インデＦ野村ＤＣ](https://www.nomura-am.co.jp/fund/funddetail.php?fundcd=400041) which tracks the [MSCI Kokusai Index](https://www.msci.com/documents/10199/75637607-5053-4a11-bc59-30a604cab1fa) (developed countries excluding Japan) with a yearly fee of 0.09889% (pretty close to eMaxis Slim All Country and Vanguard Total World). This does exclude emerging markets and Japan, but this was the closest I could get without using multiple funds and having to rebalance occasionally.

Assuming I contribute this amount from age 26 to 65 and we assume a real return of 4.5% ([source](https://youtu.be/Yl3NxTS_DgY?si=X0Kjq72WVY_qVpN0&t=408)), I will have 68,336,728 yen in today's money. Let's round this up to 70 million yen.

Calculation: let's use the [Future Value of an Annuity](https://www.investopedia.com/terms/f/future-value-annuity.asp) formula:

```python
monthly_contribution = 55000
annual_return = 0.045  # 4.5% real return
years = 65 - 26  # from age 26 to 65
months = years * 12

# Future Value of a series formula (monthly compounding)
# FV = P * [((1 + r)^n - 1) / r]
monthly_return = (1 + annual_return) ** (1/12) - 1
future_value = monthly_contribution * (((1 + monthly_return) ** months - 1) / monthly_return)
```

This assumes that the monthly contributions increase with inflation (so e.g. in 10 years time I won't be contributing 55,000 yen but more). This is not true on the short-term (as the contribution limit is not tied to inflation), so the government has to explicitly increase it, but one can hope that on the long run they will increase it frequently enough to address this.

So at 65 I have 70 million yen from this (in today's money). Using a [3% safe withdrawal rate](https://www.youtube.com/watch?v=1FwgCRIS0Wg), this gives me an additional 2.1 million yen per year, so 175,000 yen per month.

## Summary

Together all of this brings me to the following numbers per month (in today's money):

* 57,092 yen from national pension (国民年金)
* 232,942 yen from the pension insurance (厚生年金)
* 175,000 yen from the private pension (DC)

Overall: 465,000 yen. Not bad, but also won't provide for a retirement of traveling around the world and spending carelessly.

## Looking ahead

I know I have it pretty well compared to most people, but looking at it at face value, it's quite a drop in lifestyle. Of course I have other savings, and with a house likely paid off, it will be livable, but still.

But I'm actually not looking to retire. Ever since I read the [100-Year Life](https://www.100yearlife.com/) book, I think retirement is neither viable nor desirable. The book's main argument is that if medical science continues to advance as it has in recent history, then half of the people born in the '90s will live past 100 years. In this world, a retirement at 65 is simply unrealistic: we start our life with 20 years of study. Then stopping after 45 years of work and expecting to fund a 35 year retirement means one has to save a lot. Also 35 years of not doing anything just feels boring (but then again, I'm in my early 30s, so what do I know). But at this point I don't think I will ever stop working, but instead I might reduce the amount of hours, or switch to something new (e.g. advisory role, or teaching/coaching). But then again, I'll see it when I get old.

## Source

Most of the sources are linked above. General sources used multiple times:

* <https://www.ipss.go.jp/s-info/e/jasos2002/Jasos2002.html>
* <https://www.nenkin.go.jp/international/japanese-system/nationalpension/nationalpension.html>
* <https://en.an-japan.com/services/topics/ls2/approximate-pension-amount/>
