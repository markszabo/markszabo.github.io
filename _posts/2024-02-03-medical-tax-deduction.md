---
layout: post
title: Medical expense tax deduction in Japan (医療費控除)
tags: money japan tax
---

In Japan if one pays more than 100,000 yen of medical expenses in a calendar year, they can deduct it from their pre-tax income (usually leading to an income tax refund).
In this post I'll attempt to summarize the rules of this.

*As with all my posts, this is not tax advice and do your own research before making any decision. Also if you find any inaccuracy or mistake, please leave a comment at the end, so that I can correct it.*

<!--break-->

## Who's expenses

Your and any relative's that lives with you if you paid for their medical expense.

> その年の1月1日から12月31日までの間に自己または自己と生計を一にする配偶者やその他の親族のために医療費を支払った場合において、その支払った医療費が一定額を超えるときは、その医療費の額を基に計算される金額（下記「医療費控除の対象となる金額」参照））の所得控除を受けることができます。これを医療費控除といいます。

> If you or your spouse, who shares a household with you, pay medical expenses for yourself or other relatives during the period from January 1 to December 31 of the year, and the paid medical expenses exceed a certain amount, you can receive an income deduction based on the amount of those medical expenses (see below for the amount eligible for the medical expense deduction). This is called a medical expense deduction.

[Source](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1120.htm), translated with ChatGPT.

You can deduct your spouse's expense even if they are not your dependent, assuming you paid for it ([source](https://www.nta.go.jp/law/shitsugi/shotoku/05/25.htm)). Even the medical expenses of your sister's child can be deducted, if you live together and you paid for it ([source](https://www.nta.go.jp/law/shitsugi/shotoku/05/82.htm)).

## The amount

The amount one can deduct is calculated by:

```
(incurred medical expenses) - (any compensation, insurance payout, etc.) - 100,000 yen
```

with a maximum of 2 million yen.

> 医療費控除の金額は、次の式で計算した金額（最高で200万円）です。
> 
>（実際に支払った医療費の合計額-（1）の金額）-（2）の金額
>
>（1）保険金などで補てんされる金額
>
>（例） 生命保険契約などで支給される入院費給付金や健康保険などで支給される高額療養費・家族療養費・出産育児一時金など
>
>（注）保険金などで補てんされる金額は、その給付の目的となった医療費の金額を限度として差し引きますので、引ききれない金額が生じた場合であっても他の医療費からは差し引きません。
>
>（2）10万円
>
>（注）その年の総所得金額等が200万円未満の人は、総所得金額等の5パーセントの金額

> The amount of the medical expense deduction is calculated using the following formula (up to a maximum of 2 million yen):
> 
> (Total amount of actual medical expenses paid - Amount (1)) - Amount (2)
>
> (1) Amount compensated by insurance, etc.
>
> (Example) Such as hospitalization benefits paid under life insurance contracts, or high-cost medical care, family medical care, and lump-sum childbirth and childcare benefits paid by health insurance.
>
> (Note) The amount compensated by insurance, etc., is deducted up to the amount of medical expenses that were the purpose of the benefit. Therefore, even if there is an amount that cannot be fully deducted, it will not be deducted from other medical expenses.
> 
> (2) 100,000 yen
> 
> (Note) For people whose total annual income, etc., is less than 2 million yen, the amount is 5 percent of the total annual income, etc.

[Source](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1120.htm)

This also means that medical deduction can only be used if the medical expenses are over 100,000 yen.

## Which expenses are included

In principle (quotes are translations of [this page](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1122.htm)):

1. Medical treatment by a doctor or dentist (it has to solve a problem. Check-ups and preventative care is excluded. Vaccines are also excluded, unless [in special cases](https://www.nta.go.jp/law/shitsugi/shotoku/05/38.htm))
    > Compensation for medical treatment or therapy by a physician or dentist (however, expenses for medical examinations and honoraria to physicians, etc. are generally not included).
2. Medicine necessary for treatment
    > Consideration for the purchase of medicines necessary for medical treatment or recuperation (the purchase of medicines such as cold remedies for a cold is considered a medical expense, but the purchase of medicines used for disease prevention or health promotion, such as vitamins, is not considered a medical expense).
3. Necessary hospital stays
    > 3 Compensation for the provision of personal services to be admitted to a hospital, clinic, long-term care health facility for the elderly, long-term care medical care hospital, designated long-term care medical facility for the elderly, designated long-term care welfare facility for the elderly, designated community-based long-term care welfare facility for the elderly, or midwifery home
4. Traditional Chinese medicine and other alternative medical treatments, if they are to treat a medical issue 
    > 4 Compensation for treatment by anma, massage, shiatsu, acupuncture, moxibustion, and judo therapy therapists (however, this does not include treatment that is not directly related to treatment such as relieving fatigue or improving physical condition).
5. Travel expenses to the hospital (with some exceptions) - generally only public transport costs (train, bus) are included, or taxi if public transport is not available. Expenses related to going by private car (parking, fuel) is not included
    > (1) Expenses for hospital visits to receive medical treatment by doctors, etc., transportation to and from doctors, etc., expenses for room and board during hospitalization, and expenses for the purchase or rental of medical equipment such as corsets, which are usually necessary.
    >
    > (Note 1) Taxi expenses are not included in the deductible expenses unless public transportation such as trains and buses are not available.
    >
    > (Note 2) Gasoline and parking fees for hospital visits by private car are not included in the deductible expenses.

There is a significant overlap between what health insurance covers in Japan (generally: treatment for a medical issue) and what can be included here, however there are additional expenses that are included in the tax deduction but not covered by insurance (e.g. pregancy-related costs, travel to hospital).

NTA has [a long FAQ](https://www.nta.go.jp/law/shitsugi/shotoku/01.htm#b-11) on their site and I'll list some of them that I found interesting:

* [Medical check-ups are excluded](https://www.nta.go.jp/law/shitsugi/shotoku/05/09.htm) unless they find a serious disease and directly lead to a treatment
* [Massage is included](https://www.nta.go.jp/law/shitsugi/shotoku/05/06.htm), but only if it's for treatment of a medical condition
* Medically not necessary cosmetic surgeries and dental procedures are not included, e.g. [birthmark removal](https://www.nta.go.jp/law/shitsugi/shotoku/05/35.htm) and [cosmetic teeth straightening](https://www.nta.go.jp/law/shitsugi/shotoku/05/08.htm)
* However dental treatment even when [using gold or porcelain is included](https://www.nta.go.jp/law/shitsugi/shotoku/05/07.htm), even though these are not covered by insurance (insurance only covers the basic materials), as long as the price is inline with general procedures
* Another thing that's not covered by insurance, but included in this is [the cost of regular check-ups of pregnant women](https://www.nta.go.jp/law/shitsugi/shotoku/05/10.htm)
    * [Infertility treatment and the cost of artificial insemination is also included](https://www.nta.go.jp/law/shitsugi/shotoku/05/37.htm)
    * [Cost of abortion is also included](https://www.nta.go.jp/law/shitsugi/shotoku/05/36.htm)
    * Checking for Down-syndrome by looking at the baby's DNA found in the mom's blood ([NIPT](https://medlineplus.gov/genetics/understanding/testing/nipt/)) is [not included, as it is considered a check-up that doesn't lead to treatment](https://www.nta.go.jp/law/shitsugi/shotoku/05/80.htm)
    * Attending a [course on breathing techniques to reduce the pain of labor is also excluded](https://www.nta.go.jp/law/shitsugi/shotoku/05/11.htm)
* Daily purchases following a doctor's advice are mostly excluded:
    * [Food purchased to follow a diet is excluded](https://www.nta.go.jp/law/shitsugi/shotoku/05/13.htm)
    * The same way [just because the doctor recommends to go to an onsen, it's still excluded](https://www.nta.go.jp/law/shitsugi/shotoku/05/52.htm)
    * Similarly [the cost of an air purifier is also excluded, regardless if the doctor recommended it](https://www.nta.go.jp/law/shitsugi/shotoku/05/23.htm)
* [Gifts for doctors and nurses are also excluded](https://www.nta.go.jp/law/shitsugi/shotoku/05/40.htm)
* [Cost of travel to the hospital by public transport is included, but not if you go by your own car](https://www.nta.go.jp/law/shitsugi/shotoku/05/50.htm).
    * [Cost of taxi can be included, if taxi was necessary](https://www.nta.go.jp/law/shitsugi/shotoku/05/21.htm).
    * [However cost to travel to one's hometown before childbirth (common practice to give birth close to one's parents so that they can help with the newborn) is excluded](https://www.nta.go.jp/law/shitsugi/shotoku/05/19.htm)
* [If you pay in installments, only the amount paid in the year should be counted (the rest should be counted in the year it was paid, even if the medical procedure was done in an earlier year)](https://www.nta.go.jp/law/shitsugi/shotoku/05/24.htm)
* One needs to deduct any insurance payment or other compensations from the medical costs when calculating the amount
    * [Even if the husband paid for the childbirth expenses of his wife, and the wife's insurance paid her back, the husband has to deduct this from the amount in his calculations](https://www.nta.go.jp/law/shitsugi/shotoku/05/26.htm)
    * However [maternity allowance (money from the mother's employer) does not need to be counted](https://www.nta.go.jp/law/shitsugi/shotoku/05/27.htm) as it's not insurance money

## How to file for the deduction

One needs to file final tax return (確定申告) to claim medical expense deductions ([source](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1120.htm#:~:text=%E5%8C%BB%E7%99%82%E8%B2%BB%E6%8E%A7%E9%99%A4%E3%81%AB%E9%96%A2%E3%81%99%E3%82%8B%E4%BA%8B%E9%A0%85%E3%81%9D%E3%81%AE%E4%BB%96%E3%81%AE%E5%BF%85%E8%A6%81%E4%BA%8B%E9%A0%85%E3%82%92%E8%A8%98%E8%BC%89%E7%AD%89%E3%81%97%E3%81%9F%E7%A2%BA%E5%AE%9A%E7%94%B3%E5%91%8A%E6%9B%B8%E3%82%92%E6%8F%90%E5%87%BA%E3%81%97%E3%81%A6%E3%81%8F%E3%81%A0%E3%81%95%E3%81%84%E3%80%82)).

### Documents to submit

From [here](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shotoku/1120.htm#:~:text=%E6%89%80%E8%BD%84%E7%A8%8E%E5%8B%99%E7%BD%B2-,%E6%8F%90%E5%87%BA%E6%9B%B8%E9%A1%9E%E7%AD%89,-%E5%8C%BB%E7%99%82%E8%B2%BB%E3%81%AE), translated with ChatGPT:

> Create a "[Medical Expense Deduction Detailed Statement (PDF/1,024KB)](https://www.nta.go.jp/taxes/shiraberu/shinkoku/yoshiki/02/pdf/ref1.pdf)" or "[Self-Medication Tax System Detailed Statement (PDF/611KB)](https://www.nta.go.jp/taxes/shiraberu/shinkoku/yoshiki/016.pdf)" from the medical expense receipt (Note 1), and attach it to your tax return.
>
> If you have received a medical expense notification (Note 2) from your health insurance provider, attaching this notification can simplify the details required for the medical expense deduction.
> 
> Please note that to verify the details of the medical expense deduction, you may be asked to present or submit medical expense receipts (excluding those with a medical expense notification attached) until five years after the tax return deadline.

For proof on expenses that were included in the insurance, one can use the medical expense notification from your insurance provider, and then don't need to keep the receipts for these expenses.

One can also link their MyNa Portal with e-Tax and import the medical expenses covered by insurance ([source](https://www.nta.go.jp/taxes/shiraberu/shinkoku/tokushu/keisubetsu/iryou-koujo.htm)):

> マイナポータル連携を利用すると、医療費控除に使用できる医療費通知情報をマイナポータル経由で取得し、所得税の確定申告書を作成する際に、該当項目に自動入力することができます。

If you are using this system and want to include a relative's expenses, they [need to configure you as a proxy](https://faq.myna.go.jp/faq/show/7116?category_id=24&site_domain=default) (same info on [NTA's page](https://www.keisan.nta.go.jp/r4yokuaru/ocat1/cid569.html)).

NTA also provides a spreadsheet called Medical Expenses Summary Form (医療費集計フォーム) that one can use to collect their expenses and [import it directly into e-Tax](https://www.keisan.nta.go.jp/r3yokuaru/ocat2/ocat22/cid102.html#cmsF53D1). ([source](https://www.nta.go.jp/taxes/shiraberu/shinkoku/tokushu/keisubetsu/iryou-koujo.htm#:~:text=%E5%8C%BB%E7%99%82%E8%B2%BB%E3%81%AE%E9%A0%98%E5%8F%8E%E6%9B%B8%E3%81%8C%E5%A4%9A%E3%81%84%E5%A0%B4%E5%90%88%E3%81%AF%E3%80%81%0A%E5%8C%BB%E7%99%82%E8%B2%BB%E9%9B%86%E8%A8%88%E3%83%95%E3%82%A9%E3%83%BC%E3%83%A0%E3%81%A7%E5%85%A5%E5%8A%9B%E3%81%99%E3%82%8B%E3%81%A8%E4%BE%BF%E5%88%A9%E3%81%A7%E3%81%99%E3%80%82), [spreadsheet download](https://www.nta.go.jp/taxes/shiraberu/shinkoku/tokushu/keisubetsu/iryou-shuukei.htm))

Details on how to file when using e-Tax or filing on paper can be found [on this page](https://www.keisan.nta.go.jp/r3yokuaru/ocat2/ocat22/cid102.html).
