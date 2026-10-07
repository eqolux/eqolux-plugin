---
name: eqolux-savings-opportunities
description: Find savings in restaurant or hotel purchasing with Eqolux — the same product bought at very different prices, price increases, purchases above a negotiated fixed price. Use when the user asks where they could save money, why costs went up, which prices increased, or wants to prepare a supplier negotiation.
license: MIT
metadata:
  version: '0.1.0'
  author: Eqolux
---

# Savings opportunities in Eqolux data

Apply the `eqolux-purchasing-analysis` rules first: pick the organization with `list_organizations`, read `describe_data`, exclude credit notes from price statistics, compare food per kg and other products per unit, and link records through `app_url`.

Then look for the three kinds of savings below. `references/savings-queries.md` holds a tested query for each; adapt the period and thresholds to the user's request.

## 1. The same product at very different prices

For each product over the period: lowest and highest price paid, spend, and the saving if every purchase had been made at the lowest price, that is `spend - lowest price × volume`. Keep products with meaningful spend (by default at least 1,000 in the display currency) and a highest-to-lowest ratio of at least 1.3. Give the documents where the lowest and highest prices were paid, so the user can check them.

## 2. Price increases

Compare each product's average price, weighted by volume, between two periods: by default the last 6 months against the 6 months before, or the same months a year earlier when the user cares about seasonality. Rank by extra cost: `(recent price - earlier price) × recent volume`. Ignore products bought in only one of the two periods.

## 3. Purchases above a negotiated price

`products.fixed_price` holds a negotiated price, in the unit given by `fixed_price_unit` (`kg` or `unit`). Compare it with the price actually paid and rank by extra cost: `spend - fixed price × volume`.

## Presenting the findings

- Show the top 10 by estimated amount, with product, supplier, prices, volume and the estimate, each product and document linked through `app_url`.
- Call every figure an **estimate**, and say how it was computed and over which period.
- Point out what could distort it: a unit mix-up (kg against pieces), lines with a high `error_risk`, a product that changed packaging, seasonal products.
- End with the two or three actions most worth taking, for example the supplier to call first and what to ask for.
- On a very large organization, a query over 12 months can time out: narrow it to a category, a supplier or a shorter period.
