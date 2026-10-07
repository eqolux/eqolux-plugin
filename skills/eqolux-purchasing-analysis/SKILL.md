---
name: eqolux-purchasing-analysis
description: Analyze restaurant and hotel purchasing data in Eqolux — spend by supplier, establishment, category or period, product prices and their evolution, origins and carbon footprint. Use whenever the user asks about their purchases, suppliers, invoices, delivery notes, products, prices, food cost or CO2 tracked in Eqolux.
license: MIT
metadata:
  version: '0.1.0'
  author: Eqolux
---

# Eqolux purchasing analysis

Eqolux reads supplier documents (invoices, delivery notes, credit notes) for restaurant and hotel groups and turns them into structured purchase data. The Eqolux connector provides three tools:

- `list_organizations`: the organizations (groups) the user belongs to, with their ids
- `describe_data`: the tables `run_sql_query` can read, every column, and how amounts are converted and signed
- `run_sql_query`: one read-only PostgreSQL `SELECT` on one organization's data, at most 500 rows

## Workflow

1. **Pick the organization.** Call `list_organizations`. If there is one, use it. If there are several, use the one the user named (or the one their establishment belongs to); otherwise ask. Each query covers exactly one organization.
2. **Read the schema once.** Call `describe_data` before the first query of the conversation.
3. **Query.** Aggregate in SQL rather than fetching rows to aggregate yourself: results stop at 500 rows. One well-built query beats several small ones. If a query times out, narrow the period or filter on a supplier, category or establishment.
4. **Answer** following the rules below.

## Rules that keep the numbers right

- **Spend totals come from `documents`.** Spend per supplier, establishment, month or period is `SUM(documents.total_amount_ht)`: it is what the Eqolux app shows. Use `orders` (one row per product line) for product-level detail: what was bought, quantities, prices, categories, origins. Its sum can be lower than document totals when some lines of a document could not be read; if you show both, explain the difference.
- **Credit notes are already negative** in totals (`total_amount_ht`, `quantity`, `total_weight_kg`, `co2_kg`), so a plain `SUM` nets them out. Never change their sign. For price statistics (min, max, average, change over time), exclude them: `WHERE NOT is_credit_note`.
- **Compare like with like.** For food (`products.item_category_type = 'food'`), compare `price_per_kg`; for other products, `unit_price_ht`. When asked "the price of X" for a food product, give the price per kg first. For an average price, divide spend by weight or quantity (`SUM(total_amount_ht) / SUM(total_weight_kg)`) rather than averaging line prices.
- **Currency.** Amounts are already converted to the display currency (EUR unless `display_currency` says otherwise). Never convert them yourself. State the currency in the answer.
- **Dates** are UTC calendar days. Filter with date literals or `CURRENT_DATE`, for example `WHERE o.date >= CURRENT_DATE - INTERVAL '12 months'`.
- **Default period.** When the user gives none, use the last 12 months and state the exact dates used.
- **Drafts.** `is_draft` marks data the customer has not validated yet. The app includes it; include it too, unless the user asks for validated data only.
- **Data quality.** `error_risk` is higher for lines read with low confidence. When a price looks implausible (an extreme price per kg, a unit mix-up), check `error_risk` and `unit` and say so instead of presenting it as a fact.

## Finding things by name

- **Products:** match `products.name`, `name_fr` and `name_en` with `unaccent(lower(...)) LIKE '%term%'`; try the singular, the plural and the other language. If nothing matches, the user may mean a supplier: search `organizations` where `type = 'Supplier'`.
- **Establishments:** `organizations` of type `Client`, `Client Sub` or `Group`. Groups often stand for regions or countries ("our Swiss hotels").
- **Categories:** `item_categories` is a tree (`parent_id`); a product's category is `products.item_category_id`.

## Presenting results

- Answer in the user's language, with numbers formatted for that language.
- Prefer tables. For month-by-month figures, use one column per month.
- **Links:** select the `app_url` column (on `products`, `documents`, and suppliers in `organizations`) and link names to it, so the user can open the record in Eqolux. Use only `app_url` values returned by a query; never build or guess a URL. Without one, write plain text.
- **State the scope** under the answer: the organization by name, the period, the currency, and any filter (establishment, category, supplier). Never suggest the analysis covers several organizations, and never name an establishment or supplier that did not come from the data.
- For long listings, show the top 20 to 50 rows and offer to narrow down. For a complete export, point the user to the Eqolux app.

## Query recipes

`references/sql-recipes.md` holds tested queries for the common questions: spend by supplier, by establishment and month, by category; finding a product; the price evolution of a product; origins; carbon footprint by category. Adapt them rather than starting from scratch.

For savings, price increases and negotiated prices, use the `eqolux-savings-opportunities` skill.
