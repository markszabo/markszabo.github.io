---
layout: post
title: "Calculating and declaring capital gains tax in Japan"
tags: japan money tax
---

Last year I sold some ETFs in my Interactive Brokers account, which doesn't withhold taxes in Japan, so I had to report it in my tax return (確定申告) and pay tax on it. In this post I'll share how I went about this.

*This is not tax advice, and it might be incorrect/incomplete or simply doesn't apply to your situation. Do your own research and do not follow this blindly.*

<!--break-->

## Step 1: do I need to pay tax?

First things first: capital gains from stocks, ETFs, funds, etc., are only taxable when one sells something for more than they bought it for. Just because the value of your holdings went up, it is not a taxable until you sell it (in general). Also if you sell something at a loss, you don't have to pay tax on it, but you can use it to offset gains and reduce your tax.

Japan is actually pretty good about helping people not have to worry about capital gains tax. Japanese brokerages will withhold the tax (unless you ask them not to), and one doesn't need to include these in their tax return, even if they file a tax return for other reasons (e.g. [medical deductions]({% post_url 2024-02-03-medical-tax-deduction %})). The reason this doesn't help me is that I opened an account with Interactive Brokers LLC (when they still allowed that in Japan, nowadays they only let people open accounts with Interactive Brokers Japan that will withhold taxes for you).

Moreover when a foreigner living in Japan is not yet a permanent tax resident, some capital gains are not taxed in Japan, so if this applies to you, look into this more. I'm a permanent tax resident already, so this didn't apply to me.

As a Hungarian citizen with tax residency in Japan, I am not required to file taxes in Hungary, and as long as I declare all my income in Japan and pay taxes here, I'm good. But other countries might require you to file taxes there too.

## Step 2: calculating the tax

*TLDR: Japan counts in yen.*

Let's start with an example:

* on January 11th, 2022: I bought 60 shares of SIVR ETFs for $21.73 a piece for an overall of $1,303.80
* on May 2nd, 2024: I sold all of them for $25.15 a piece for an overall of $1,508.70

So I made $204.90, right? Interactive Brokers will actually show this number and then convert it to yen on the exchange rate of the day of sale, getting to 31,482.90 yen. However the NTA calculates differently as they only think in yen. So in their thinking:

* on January 11th, 2022: I bought the shares for 151,684 yen ($1,303.80 in yen on that day)
* on May 2nd, 2024: I sold the shares for 234,060 yen ($1,508.70 in yen on that day)

So according to NTA my gain was 82,376 yen, quite a bit more than the other calculation (due to the yen's depreciation in this time). It doesn't matter if I did the currency conversions on that day or not, this is how the NTA calculates the tax, so this is how I have to do it too.

There is one additional detail: transaction fees can be deducted from the gains. So the cost basis gets a bit higher, and the final sale price a bit lower. This concept applies to exchange rates too, but more on that later.

### Multiple purchases

If one has bought the same stocks multiple times in the past, then NTA uses the weighted average method to calculate the acquisition price: e.g. if you bought 100 stocks for 10,000 yen a piece, then 200 stocks for 12,000 yen a piece. Overall you spent `100*10,000+200*12,000=3,400,000` for 300 stocks, so the average price is `3,400,000/300=11,333.33` yen. If one would to sell e.g. 10 stocks, then their cost basis would be 113,333.33 yen. [Source and more official examples are here.](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1466.htm)

### Exchange rates

For the historic exchange rates I found that many online sources recommend [MUFG's spreadsheets](https://www.murc-kawasesouba.jp/fx/past_3month.php) that go back a long time, so I was using this. This includes 3 values for each day:

* TTS: the amount of yen I have to pay to get 1 dollar (highest of the 3)
* TTB: the amount of yen I get for 1 dollar (lowest of the 3)
* TTM: mid-price of the above two

I use TTS when buying stocks, since I take my yen, convert it to dollar at TTS, then buy the stock. When selling the stock, it's TTB: I sell the stock then convert the dollars to yen at TTB. This calculation works in our favor (reduces the gains in yen slightly to account for the fee of the conversion). ([Source1](https://www.nta.go.jp/law/tsutatsu/kihon/hojin/13_2/13_2_01.htm), [Source2](https://www.nta.go.jp/law/tsutatsu/kobetsu/shotoku/sochiho/020624/sanrin/1273/37_10-11/01.htm)).

### Steps to calculate the gains

Summarizing the above for the simple case of buying once and then selling it all at once, we have to do the following steps:

1. Record the purchase price in dollar
2. Add any transaction fees. This is your cost basis in dollar
3. Look up the TTS on that day and use it to convert it to yen. This is your cost basis in yen
4. Record the sold price in dollar
5. Subtract any transaction fees
6. Look up the TTB for the day of sale and use it to convert it to yen.
7. Subtract the cost basis in yen from this, and you got your gains.

### Calculate the tax

\[edit on 2025. Nov 23.\]: an earlier version of this post incorrectly said that capital gains have two taxation method one can choose from. In reality, tha choice is only available for dividend income: [source](https://www.nta.go.jp/english/taxes/individual/pdf/incometax_2024/17.pdf). Thanks to [starkimpossibility over at JapanFinance for catching this mistake](https://www.reddit.com/r/JapanFinance/comments/1p3ra3p/comment/nqa6mj1/).

In principal, capital gains are taxed at a flat 15% rate, regardless of other income.

One more thing: after the Great East Japan Earthquake of 2011, an additional tax was introduced to help fund recovery efforts. This is called the "Special Income Tax for Reconstruction" (復興特別所得税) and it adds an additional 2.1% on top of all income tax. So the 15% becomes 15*1.021=15.315%. This additional tax was introduced in 2013 and is currently set to continue until 2037 ([source](https://www.nta.go.jp/english/taxes/individual/pdf/incometax_2024/04.pdf)).

Moreover there is an additional 5% residence tax that one will have to pay to their local municipality, but that is billed in June the year after the income was realized and then either paid in lump sum or deducted from the salary during the next 12 months.

TLDR: the tax to pay at filing time is 15.315% of the gains. Then from June, the residence tax goes up with an additional 5% of the gains.

## Step 3: tax filing

Once we are done with the calculation, the actual filing is pretty straightforward.

### 1. Indicate that we have income from capital gains

![Select Income from selling stocks, receiving dividends 株式等の譲渡（売却）、配当、利子](/assets/2025-03-11-capital-gains-tax/01-income-type-selection.png#lb)

### 2. On the income page, select the capital gains, dividends box

![Once filled out, it will be shown here too](/assets/2025-03-11-capital-gains-tax/02-income-box-of-capital-gains.png#lb)

### 3. Decide whether you have a special account you want to report

As far as I know these are accounts that withhold taxes, so one would only need to report them if they want to use losses there to offset other gains.

![I chose no here](/assets/2025-03-11-capital-gains-tax/03-special-account-to-report-on.png#lb)

### 4. I have a non-special account to report

And I sold [listed stocks, 上場株式等](https://www.keisan.nta.go.jp/r6yokuaru/cat2/cat21/cat219/yogosetsumei/jojokabushiki.html) (as opposed to common stocks which mean unlisted).

![The on-site help is very useful for these options](/assets/2025-03-11-capital-gains-tax/04-non-special-account-with-listed-stocks-sold.png#lb)

### 5. Go to input

![Continue to input the details](/assets/2025-03-11-capital-gains-tax/05-go-for-input.png#lb)

### 6. Detailed reporting or summary only

On the next page we can select whether we want to input the details of each transaction, or just the summary. I will show both.

![I chose the detailed input here, the summary would be the other option](/assets/2025-03-11-capital-gains-tax/06-details-or-summary.png#lb)

### 7a Entering the details of a transaction

Example input and official explanation is available [here](https://www.keisan.nta.go.jp/r6yokuaru/ocat3/ocat33/cid1084.html).

The fields are:

* Day of the sale
* Name of the company - I used the ticker symbol
* Number of stocks sold
* Brokerage - I wrote `インタラクティブ・ブローカーズ証券株式会社`
* Sold price
* Cost basis (purchase price minus transaction fees at purchase)
* Transaction fees at selling
* Day of purchase - if purchased multiple times, enter the most recent date

![Enter the details of a transaction](/assets/2025-03-11-capital-gains-tax/07a-details.png#lb)

Then repeat this for all transactions, and the summary page will show the sum of all input.

![Summary of the individual transactions](/assets/2025-03-11-capital-gains-tax/07a-details-summary.png#lb)

On the next page we have 3 more fields that I left empty:

* Any additional income from selling the stocks
* Any other expenses associated with the transaction (name and amount)

![Summary of the individual transactions](/assets/2025-03-11-capital-gains-tax/07a-post-details.png#lb)

### 7b Entering the summary-only

Alternatively one can simply enter the final summary of all trades.

Fields here are the same as on the last page of the previous method, but we have to enter everything ourselves:

* Overall sold price
* Any additional income from selling the stocks (I left it empty)
* Overall cost basis (purchase price minus transaction fees at purchase)
* Overall transaction fees at selling
* Any other expenses associated with the transaction (name and amount) - I left this empty too

![Entering only the summary of the transactions](/assets/2025-03-11-capital-gains-tax/07b-summary-only.png#lb)

### 8 Confirm the capital gains income

Once we are done and return to the main incomes page, a confirmation message will show the overall income from capital gains. Check this with your own calculations to ensure you entered everything correctly.

![Confirmation of the capital gains amount](/assets/2025-03-11-capital-gains-tax/08-confirmation.png#lb)

And that's it.

*As I said on the top, this is not tax advice. Check the linked sources and do your own research.*
