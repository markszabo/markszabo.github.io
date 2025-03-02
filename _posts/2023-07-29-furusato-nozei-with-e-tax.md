---
layout: post
title: Adding Furusato nozei to e-Tax
tags: japan money tax
---

How to indicate furusato nozei when filing taxes online. (To learn about furusato nozei, see [Furusato nozei - end to end guide]({% post_url 2023-07-29-furusato-nozei-end-to-end %}).)

<!--break-->

# 1. Get the xml file with the furusato nozei amount

Most furusato websites provide a digitally signed xml file ([寄附金控除に関する証明書](https://www.furusato-tax.jp/feature/a/2022_tax_return), Certificate of Donation Deduction), e.g. [ふるさとチョイス](https://www.furusato-tax.jp/feature/a/2022_tax_return). Request and download this.

# 2. Upload the xml file to e-Tax

When filing [Japanese income tax online](https://www.keisan.nta.go.jp/kyoutu/ky/sm/top#bsctrl) there is a step called 所得控除の入力, Entering Income Deductions. This usually comes pre-filled with some default deductions:

![](/assets/2023-07-29-furusato-nozei-with-e-tax/deductions-page.png)

To add furusato nozei, select 寄附金控除, Donation deduction, which opens this page:

![](/assets/2023-07-29-furusato-nozei-with-e-tax/donation-deduction.png)

Select and upload the xml file. After it parses the file, it should show the amount:

![](/assets/2023-07-29-furusato-nozei-with-e-tax/furusato-overview.png)

After clicking 入力 one can see all the individual donations:

![](/assets/2023-07-29-furusato-nozei-with-e-tax/furusato-details.png)

Accept it with 入力終了 and it should show up in the 所得控除の入力 summary table.

That's it. Complete the tax return, if you are eligible for tax refund, specify the way you want to receive it (e.g. bank transfer), and wait for it to arrive.
