---
layout: post
title: Tax on life insurance payouts in Japan
tags: japan money insurance
---

A while back I took a look at [life insurance in Japan]({% post_url 2023-11-23-a-look-at-life-insurance-in-japan %}) and now I'm getting close to actually buying one. As I was thinking about the coverage to get, I looked into how these payouts are taxed (since I care about the net payouts).

<!--break-->

## Type of tax depending on the payer and receiver

The type of tax depends on who paid for the insurance, and who receives the money. From the [NTA's site](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1750.htm):

| Insured person | Insurance premium payer | Beneficiary | Type of Tax     |
| -------------- | ----------------------- | ----------- | --------------- |
| A              | B                       | B           | Income tax      |
| A              | A                       | B           | Inheritance tax |
| A              | B                       | C           | Gift tax        |

In my case I want to make sure my family has money in case my untimely demise, so the insured is me and the beneficiary is my wife. If my wife pays for the insurance, then the payout is taxed as income. If I pay for the insurance then the payout is taxed as inheritance. The latter has generally a lower rate (though it depends on the size of the estate), so I should be paying for the insurance.

## Type of insurance

In [my earlier post]({% post_url 2023-11-23-a-look-at-life-insurance-in-japan %}) I ruled out whole life insurance (終身保険), and was thinking about term life insurance (定期保険) or income protection insurance (収入保障保険). Both have a fixed time period (e.g. 25 year from now) and if I die during that time, then they pay. If I'm still alive after 25 years, then they don't pay anything. This keeps the premiums low compared to whole life insurance.

The difference between term life insurance and income protection insurance is their payout method: term life insurance pays a lump sum (e.g. 10 million yen) at the time of death. Income protection insurance pays a fixed monthly amount (e.g. 150,000 yen) until the end of the coverage (so e.g. if it's a 25 year term and the person dies after 15 years, then it pays for the remaining 10 years). This monthly payment method is called 年金 in Japanese (same word as pension).

We have seen earlier that the term life insurance will get taxed as inheritance: e.g. if the payout is 10 million yen, it will get added to the estate (all the other things being inherited) and taxed together.

The income protection insurance is taxed a bit differently. The thinking goes like this: instead of the monthly payments, let's consider that the insurance pays a lump sum, then the receiver buys a product that pays the pension payments (e.g. 150,000 yen/month for the next 10 years). The end result of this is the same, but it can be taxed separately as inheritance and then as interest/gains on the monthly payments.

So at the time of death they calculate the surrender value equivalent of the pension (解約返戻金相当額), essentially how much the current value of the future monthly payments are (or how much the insurance company would pay if we would cancel the contract, or how much it would cost to buy a similar pension). This part gets taxed as inheritance.

Source is [this NTA site saying](https://www.nta.go.jp/taxes/shiraberu/taxanswer/sozoku/4123.htm):

> 年金受給権が相続税の課税対象となるときの価額の評価は、相続税法第24条または第25条の規定に基づき解約返戻金相当額などにより評価します。

The monthly payments get split into principal and interest portions (part is just giving back the original price, part is the interest). The principal is tax free and the interest/gains get taxed as misc income. [Exact calculation is here](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1620.htm) but one thing to keep in mind is that the taxable portion increases as time goes (since bigger portion of the payment is considered interest).

### Calculating the present value of monthly payments

[This NTA guide](https://www.nta.go.jp/publication/pamph/sozoku/pdf/teikikin.pdf) goes into more details on this and says:

> 定期金給付事由が発生している定期金に関する権利については、
> ①解約返戻金の金額、
> ②定期金に代えて一時金の給付を受けることができる場合には一時金の金額又は
> ③給付を受けるべき金額の1年当たりの平均額を基に一定の方法で計 (以下、「予定利率による金額」といいます。)のうちいずれか多い金額により評価することとされました。

> Rights related to annuities for which an annuity payment event has occurred will be valued at the greater of:
> (1) the amount of the surrender value;
> (2) the amount of a lump sum if a lump sum payment is available in lieu of an annuity; or
> (3) calculated using a certain method based on the average annual amount of the amount to be paid (hereinafter referred to as the "amount based on the assumed interest rate").

Option 3 calculates the present value of the annuity by decreasing the value of future payments by the interest rate (e.g. receiving 105,000 yen next year has a present value of 100,000 yen, if the interest rate is 5%).

I believe the interest rate used here is 基準年利率 (base annual interest rate) which [is 0.5-2% in 2025](https://www.nta.go.jp/law/tsutatsu/kobetsu/hyoka/250500/01.htm) (depending on the term: short term is less, long term is more).

This is important because if the insurance provider doesn't offer a surrender or lump sum option, then it falls back to this calculation.

At 2% interest and 10 year of 150,000 yen/month of payments the present value is calculated (using the formula [from the earlier guide](https://www.nta.go.jp/publication/pamph/sozoku/pdf/teikikin.pdf)):

<!-- 
```math
\frac{1 - \left(\frac{1}{(1 + r)^n}\right)}{r}
= \frac{1 - \left(\frac{1}{(1.02)^{10}}\right)}{0.02}
= 8.98
```
 -->

```
(1-(1/(1+r)^n)) / r = (1-(1/((1.02)^10)))/0.02 = 8.98
```

* `r`: interest
* `n`: number of years

150,000 yen a month is 150,000\*12=1.8 million yen per year, so 1.8\*8.98=16.16 million yen is the present value.

### Tax on the monthly payments

Continuing the above example: for the 18 million yen overall payout (150,000 yen per month for 10 years) we paid inheritance tax on 16.16 million yen. This is 89.77%. From the [NTA site](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1620.htm#:~:text=%E8%AA%B2%E7%A8%8E%E3%83%BB%E9%9D%9E%E8%AA%B2%E7%A8%8E%E9%83%A8%E5%88%86%E3%81%AE%E6%8C%AF%E3%82%8A%E5%88%86%E3%81%91%EF%BC%88%E6%96%B0%E7%9B%B8%E7%B6%9A%E7%A8%8E%E6%B3%95%E5%AF%BE%E8%B1%A1%E5%B9%B4%E9%87%91%EF%BC%89) this makes it fall into the "Inheritance tax assessment ratio of 89-92%" category which corresponds to a taxable portion of 8%.

So out of the 18 million yen overall payment, 8% of it, so 18*0.08=1.44 million yen will be subject to income tax as misc income.

This gets split between the years like this:

![Taxable portion per year (source: https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1620.htm)](/assets/2025-10-30-tax-on-life-insurance-payouts/taxable-per-year.gif#lb)

First year the taxable portion is 0, then 1 unit, then 2 units, etc. Over 10 years the overall number of units is 1+2+3+4+5+6+7+8+9=45, so each unit corresponds to 1,440,000/45=32,000 yen of taxable income. So over the years the taxable portion goes like this:

| Year | Money received | Taxable portion |
| ---- | -------------- | --------------- |
| 1    | ¥1,800,000     | ¥0              |
| 2    | ¥1,800,000     | ¥32,000         |
| 3    | ¥1,800,000     | ¥64,000         |
| 4    | ¥1,800,000     | ¥96,000         |
| 5    | ¥1,800,000     | ¥128,000        |
| 6    | ¥1,800,000     | ¥160,000        |
| 7    | ¥1,800,000     | ¥192,000        |
| 8    | ¥1,800,000     | ¥224,000        |
| 9    | ¥1,800,000     | ¥256,000        |
| 10   | ¥1,800,000     | ¥288,000        |

The taxable portion is taxed at the marginal tax rate. So even if someone makes between 9-18m yen per year (33% national tax + 10% local tax), in the last year they will still only pay 288,00 yen*0.43=123,840 yen tax and receive 1,676,160 yen (139,680 yen per month instead of the first year's 150,000 yen). Prior years will be taxed even less.

## Conclusion

If I pay for my own life insurance, then the payout will get taxed as inheritance with the rest of estate. For lump sum payment, that's the end of it. For monthly payments, there is a bit more calculations, but most of it will get taxed this way, the rest as misc income as it gets payed out (even at higher marginal tax rates the monthly payments get taxed less than 10%).

## Sources

* The NTA articles linked above:
  * [https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1750.htm](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1750.htm)
  * [https://www.nta.go.jp/taxes/shiraberu/taxanswer/sozoku/4123.htm](https://www.nta.go.jp/taxes/shiraberu/taxanswer/sozoku/4123.htm)
  * [https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1620.htm](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1620.htm)
* [Another article doing a similar example calculation](https://lify.jp/life/death/income/article-20059/)
