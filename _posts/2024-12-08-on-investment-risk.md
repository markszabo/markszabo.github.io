---
layout: post
title: On investment risk
tags: money
---

This is something that I have been trying to wrap my head around for a while: people say that the [global stock market returns around 5% yearly](https://www.youtube.com/watch?v=Yl3NxTS_DgY) (on top of inflation, based on the last 100 year), but it's still risky and the risk is the volatility: the stock returns change a lot year over year, but on the long run they average out. But if the returns average out, then as long as I don't check my portfolio daily and make bad decisions on short-term swings, I should be fine, right? If yes, then where is the risk? And in general how is volatility the same as risk?

<!--break-->

## Roulette

There is an inherent randomness in investment returns, so I will use gambling examples to account for this. Let's start with [roulette](https://en.wikipedia.org/wiki/Roulette#Roulette_wheel_number_sequence): it has numbers from 1 to 36 (half the numbers are red and the others are black), and a `0` and `00` which are both green. One can bet on black or red and if the ball stops on a number of that color, it pays out double the amount. E.g. betting 100 on black can have two outcomes: 

* the ball stops on black, then you get 200 (the original 100 plus an extra 100) (+100)
* the ball stops on red or green, then you get nothing (-100)

The chance of winning is 18/38 = 47.37% (there are 18 black and 38 spots overall), the chance of loosing is 52.63%. So the expected return is 2*47.37%=0.95 for every 1 money played. This means that playing this long enough, you are guarantee to loose: play it for 1000 times and you will win approximately 474 times and loose 526, and since one loss cancels out one win, you are left with 52 losses. This is to be expected: the casino has to make money, and this is their built-in advantage. Your only chance is to get lucky and win early, then stop playing before the rule of large numbers catches up and pushes you towards the average.

But long term investing is meant to have a positive expected return, and not just be gambling. So let's see an example with positive expected return and risk.

## Generous boss

Your boss makes everyone at the company an offer: you can join the new compensation scheme where at the end of each month he flips a coin, and if it's head, then you get 2.5x your normal salary, but if it's tail, then you get no salary that month. 

So you have 50% chance of 2.5x salary and 50% chance of nothing, compared to 100% getting exactly your salary. The expected return of the proposed scheme is higher: on average you will win every second month, so in 2 months you would get 2.5 salaries instead of 2 salaries. The expected return is 1.25 salary per month.

So looking at this purely from the expected returns, it would be foolish not to participate. However there is another side of this: the risk of being unlucky multiple times in a row. Let's say you have a good emergency fund saved up and/or a household with multiple incomes, so you will be fine even if you don't get your salary for 3 months straight. What is the chance that you get tail on the coin flip 4 times? (0.5)<sup>4</sup>=6.25%. This is a small chance, but if there are 20 people taking this offer, one of them will hit it (on average) in the first 4 months.

But let's say you have 6 month buffer, so you decide to take this offer. It is within your risk tolerance.

Meanwhile a colleague of yours just bought an expensive house, so most of their savings went against the down-payment and now they are on the hook for the mortgage. They decide to stay with the regular monthly salary, as this extra risk just doesn't fit into their situation right now (doesn't worth risking loosing your home over a 25% raise).

## Generous boss 2

Your boss offers another compensation scheme option: at the end of the month you will roll two dices. If both are 6, then you get 100x your normal salary. If it's anything else, then you get nothing.

The first dice can be anything 1 to 6, the second similarly, so there are 36 potential outcomes and only one wins. Thus the chance of winning is 1/36=2.78%. The payout is 100 salary, so the expected return is 100*2.78%=2.78 salary per month, almost 3 times the normal salary.

However it comes with a huge risk: on average one wins once every 36 times, so once every 3 years. The chances of not winning for 5 years is still (35/36)<sup>5*12</sup>=18.4%, so one in 5 people will get no salary for 5 years.

That's just something most people can't afford to take on (unless they are already wealthy or have other income cover their daily living costs). So while this is an even better option than the previous one, most people will have to decline.

## Diversification: the free lunch

There is a way to reduce the risk in the above scenarios: assuming the boss flips a coin / rolls the dice once with each employee, if you and your colleagues agree to pool the money you receive each month and split it equally among all of you, then the risk goes down: even if some of you get unlucky, it is unlikely that at least a few people wouldn't win, and then you go home with at least half a salary.

Increasing the number of participants reduces the risk further making the monthly payouts closer to the expected return. This is a similar reason why people say that ["diversification is the only free lunch" in investing](https://books.forbes.com/author-articles/diversification-is-the-only-free-lunch/). However while in our example the coin flips are independent (so the chance of all coin flips loosing gets very low as the number of flips go up), stock returns are somewhat correlated: while investing in both McDonald's and Burger King means that regardless of who's next burger sells more, at least one will pay out, there is still a chance that people will switch to healthier alternatives, and both burger chains will struggle. To compensate for this, one could invest in [literally all companies of the worlds]({% post_url 2023-11-16-new-nisa-plans %}) (all publicly traded, that is), but in an economic downturn people simply have less money to spend, so the sales (and thus the profits) of all companies can suffer at the same time. So while diversification reduces the company-specific, [idiosyncratic risk](https://www.investopedia.com/terms/i/idiosyncraticrisk.asp), there is always some [systematic risk](https://www.investopedia.com/terms/s/systematicrisk.asp) remaining.

And that's how I got to understand the relationship between expected returns and risk.
