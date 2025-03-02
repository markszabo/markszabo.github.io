---
layout: post
title: "Calculating and declaring capital gains tax in Japan"
tags: japan money tax
---

Last year I sold some ETFs in my Interactive Brokers account, which doesn't withhold taxes in Japan, so I had to report it in my tax return (確定申告) and pay tax on it. In this post I'll share how I went about this.

*This is not tax advise, and it might be incorrect/incomplete or simply doesn't apply to your situation. Do your own research before following this blindly.*

<!--break-->

## Step 1: do I need to pay tax?

First things first: capital gains from stocks, ETFs, funds, etc., are only taxable when one sells something for more than they bought it for. Just because the value of your holdings went up, it is not a taxable until you sell it (in general). Also if you sell something at a loss, you don't have to pay tax on it, but you can use it to offset gains and reduce your tax there.

Japan is actually pretty good about helping people not have to worry about capital gains tax. Japanese brokerages will withhold the tax (unless you ask them not to), and one doesn't need to include these in their tax return, even if they file a tax return for other reasons (e.g. [medical deductions]({% post_url 2024-02-03-medical-tax-deduction %})). The reason this doesn't help me is that I opened an account with Interactive Brokers LLC (when they still allowed that in Japan, nowadays they only let people open accounts with Interactive Brokers Japan that will withhold taxes for you).

Moreover when a foreigner living in Japan is not yet a permanent tax resident, some capital gains are not taxed in Japan, so if this applies to you, look into this more. I'm a permanent tax resident already, so this didn't apply to me.

As a Hungarian citizen with tax residency in Japan, I am not required to file taxes in Hungary, and as long as I declare all my income in Japan and pay taxes here, I'm good.  But other countries might require you to file taxes there too.

## Step 2: calculating the tax

*Japan only counts in yen.*

To give an example:
* on 2022. January 11th: I bought 60 shares of SIVR ETFs for $21.73 a piece for an overall of $1,303.80
* on 2024. May 2nd: I sold all of them for $25.15 a piece for an overall of $1,508.70

So I made $204.90, right? Interactive Brokers will actually show this number and then convert it to yen on the exchange rate of the day of sale, getting to 31,482.90 yen. However the NTA calculates differently as they only think in yen. So in their thinking:

* on 2022. January 11th: I bought the shares for 151,684 yen ($1,303.80 in yen on that day)
* on 2024. May 2nd: I sold the shares for 234,060 yen ($1,508.70 in yen on that day)

So according to NTA my gain was 82,376 yen, quite a bit more than the other calculation (due to the yen's depreciation in this time). It doesn't matter if I did the currency conversions on that day or not, this is how the NTA calculates the tax, so this is how I have to do it too.

There is one additional detail: transaction fees can be deducted from the gains. So the cost basis gets a bit higher, and the final sale price a bit lower.

### Multiple purchases

If one has bought the same stocks multiple times in the past, then NTA uses the weighted average method to calculate the acquisition price: e.g. if you bought 100 stocks for 10,000 yen a piece, then 200 stocks for 12,000 yen a piece. Overall you spent `100*10,000+200*12,000=3,400,000` for 300 stocks, so the average price is `3,400,000/300=11,333.33` yen. If one would to sell e.g. 10 stocks, then there cost basis would be 113,333.33 yen. ([Source and more official examples](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1466.htm))

### Exchange rates

For the historic exchange rates I found that many online sources recommend [MUFG's spreadsheets](https://www.murc-kawasesouba.jp/fx/past_3month.php) that go back a long time, so I was using this. This includes 3 values for each day:

* TTS: the amount of yen I have to pay to get 1 dollar (highest of the 3)
* TTB: the amount of yen I get for 1 dollar (lowest of the 3)
* TTM: mid-price of the above two

I use TTS when buying stocks, since I take my yen, convert it to dollar at TTS, then buy the stock. When selling the stock, it's TTB: I sell the stock then convert the dollars to yen at TTB. This calculates works in our favor (reduces the gains in yen slightly to account for the fee of the conversion). ([Source1](https://www.nta.go.jp/law/tsutatsu/kihon/hojin/13_2/13_2_01.htm), [Source2](https://www.nta.go.jp/law/tsutatsu/kobetsu/shotoku/sochiho/020624/sanrin/1273/37_10-11/01.htm)).

### Steps to calculate the gains

Summarizing the above for the simple case of buying once and then selling it all:

1. Record the purchase price
2. Add any transaction fees, that's your cost basis in dollar
3. Look up the TTS on that day and use it to convert it to yen, that's your cost basis in yen
4. Record the sold price
5. Subtract any transaction fees
6. Look up the TTB for the day of sale. Convert it to yen.
7. Subtract the cost basis in yen from it, and you got your gains.

### Calculate the tax

So once we know how much money we made (the capital gains) we can calculate the amount of tax due. Here Japan offers two methods of taxation that we can choose from:

* Separate Self-assessment Taxation (分離申告課税): capital gains are taxed at a flat 15% rate, regardless of other income
* Aggregate Taxation (総合課税): capital gains are added to other income and taxed together at the normal, progressive income tax rate

The progressive income tax rate changes from 10% to 20% at 3,300,000 yen of income, so if one's income (including the capital gains) is under this (after deductions), then the aggregate taxation is better, otherwise (so likely for the majority of the cases) the separate taxation is better.

One more thing: after the Great East Japan Earthquake of 2011 an additional tax was introduced to help fund recovery efforts. This is called the "Special Income Tax for Reconstruction" (復興特別所得税) and it adds an additional 2.1% on top of all income tax. So the 15% becomes 15*1.021=15.315%. This additional tax was introduced in 2013 and is currently set to continue until 2037.

Moreover there is an additional 5% residence tax that one will have to pay to their local municipality, but that is billed in June the year after the income was realized and then either paid in lump sum or deducted from the salary for the next 12 months.

TLDR: the tax to pay at filing time is 15.315% of the gains. Then from June the residence tax goes up with an additional 5% of the gains.

## Step 3: tax filing

