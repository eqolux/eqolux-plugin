# Eqolux SQL recipes

Tested queries for `run_sql_query`. Replace the period, names and ids with the user's. Every query covers the organization passed as `organization_id`.

Each recipe lists the arguments to pass with the SQL. The dates are examples for a question asked on 2026-10-07: replace them with the user's period. `period_start` is included and `period_end` excluded, so pass tomorrow's date to include today. The period limits `orders` and `documents` before the query runs, which is what keeps it fast; a `WHERE` on `date` alone does not.

On large organizations, mention each table once and aggregate first: group `orders` (or `documents`) by the id you need, then join `products` or `organizations` once on that id. Each mention of a table reads all of its rows again (the whole period for `orders` and `documents`), even when it is filtered on one id, so a second mention of the same table doubles the time.

## Spend by supplier

Spend totals come from `documents`, like the Eqolux app.

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08` (last 12 months).

```sql
SELECT s.id, s.name, s.app_url,
  COUNT(*) AS documents,
  ROUND(SUM(d.total_amount_ht), 2) AS spend_ht
FROM documents d
JOIN organizations s ON s.id = d.supplier_id
GROUP BY s.id, s.name, s.app_url
ORDER BY spend_ht DESC
LIMIT 20
```

## Spend by establishment and month

Pivot the result into one column per month when presenting it.

Arguments: `period_start` `2025-11-01`, `period_end` `2026-10-08` (the current month and the 11 before it).

```sql
SELECT c.name AS establishment,
  date_trunc('month', d.date)::date AS month,
  ROUND(SUM(d.total_amount_ht), 2) AS spend_ht
FROM documents d
JOIN organizations c ON c.id = d.client_id
GROUP BY 1, 2
ORDER BY 1, 2
```

## Spend by product category

Categories live on products, so this one sums product lines (`orders`).

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08`.

```sql
SELECT COALESCE(p.item_category_name, 'Uncategorized') AS category,
  ROUND(SUM(o.total_amount_ht), 2) AS spend_ht,
  ROUND(SUM(o.total_weight_kg), 0) AS weight_kg,
  COUNT(DISTINCT o.product_id) AS products
FROM orders o
JOIN products p ON p.id = o.product_id
GROUP BY 1
ORDER BY spend_ht DESC
LIMIT 50
```

## Find a product by name

`products` is not limited by the period: no period argument is needed.

```sql
SELECT p.id, p.name, p.supplier_name, p.item_category_name, p.app_url
FROM products p
WHERE unaccent(lower(p.name)) LIKE '%' || unaccent(lower('saumon')) || '%'
   OR unaccent(lower(coalesce(p.name_fr, ''))) LIKE '%' || unaccent(lower('saumon')) || '%'
   OR unaccent(lower(coalesce(p.name_en, ''))) LIKE '%' || unaccent(lower('salmon')) || '%'
LIMIT 20
```

## Price evolution of a product, by month

Weighted average price per kg (food). For other products, use `quantity` instead of `total_weight_kg` and `unit_price_ht` instead of `price_per_kg`.

Arguments: `period_start` `2024-10-08`, `period_end` `2026-10-08` (24 months; pass an earlier `period_start`, up to 120 months, for a longer history).

```sql
SELECT date_trunc('month', o.date)::date AS month,
  ROUND(SUM(o.total_amount_ht) / NULLIF(SUM(o.total_weight_kg), 0), 2) AS avg_price_per_kg,
  ROUND(MIN(o.price_per_kg), 2) AS min_price_per_kg,
  ROUND(MAX(o.price_per_kg), 2) AS max_price_per_kg,
  ROUND(SUM(o.total_weight_kg), 1) AS weight_kg
FROM orders o
WHERE o.product_id = 12345
  AND NOT o.is_credit_note
  AND o.price_per_kg > 0
GROUP BY 1
ORDER BY 1
```

## Origins

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08`.

```sql
SELECT COALESCE(o.origin_name, 'Unknown') AS origin,
  ROUND(SUM(o.total_weight_kg), 0) AS weight_kg,
  ROUND(SUM(o.total_amount_ht), 2) AS spend_ht,
  ROUND(100.0 * SUM(o.total_amount_ht) / NULLIF(SUM(SUM(o.total_amount_ht)) OVER (), 0), 1) AS spend_share_pct
FROM orders o
GROUP BY 1
ORDER BY spend_ht DESC
LIMIT 20
```

## Carbon footprint by category

`co2_kg` is an estimate in kg CO2e (Agribalyse factor × weight).

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08`.

```sql
SELECT COALESCE(p.item_category_name, 'Uncategorized') AS category,
  ROUND(SUM(o.co2_kg), 0) AS co2_kg,
  ROUND(SUM(o.total_weight_kg), 0) AS weight_kg,
  ROUND(SUM(o.co2_kg) / NULLIF(SUM(o.total_weight_kg), 0), 2) AS co2_kg_per_kg
FROM orders o
JOIN products p ON p.id = o.product_id
WHERE o.co2_kg IS NOT NULL
GROUP BY 1
ORDER BY co2_kg DESC
LIMIT 20
```
