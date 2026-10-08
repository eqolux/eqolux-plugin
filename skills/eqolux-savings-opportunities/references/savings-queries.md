# Savings queries

Tested queries for `run_sql_query`. Adapt the period and the thresholds (minimum spend, price ratio) to the user's request.

Each query lists the arguments to pass with the SQL. The dates are examples for a question asked on 2026-10-07: replace them with the user's period. `period_start` is included and `period_end` excluded, so pass tomorrow's date to include today. The period limits `orders` and `documents` before the query runs, which is what keeps it fast; a `WHERE` on `date` alone does not.

## 1. The same product at very different prices

Food is compared per kg, other products per unit. The two last columns link the documents where the lowest and highest prices were paid: `MIN(ARRAY[price, document_id])` keeps the document of the lowest price without sorting each product's lines. Each table is read once, which keeps the query fast on large organizations: lines are aggregated per product on both bases (`VALUES` gives each line a per-kg and a per-unit price), `products` is joined once to keep the basis that fits the product, and `documents` is read only for the links of the 10 products kept.

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08` (last 12 months).

```sql
WITH by_product AS (
  SELECT o.product_id, v.price_basis,
    MIN(v.price) AS min_price,
    MAX(v.price) AS max_price,
    SUM(o.total_amount_ht) AS spend_ht,
    SUM(o.total_amount_ht) - MIN(v.price) * SUM(v.volume) AS estimated_saving,
    (MIN(ARRAY[v.price, o.document_id]))[2]::bigint AS min_price_document_id,
    (MAX(ARRAY[v.price, o.document_id]))[2]::bigint AS max_price_document_id
  FROM orders o
  CROSS JOIN LATERAL (VALUES
    ('kg', o.price_per_kg, o.total_weight_kg),
    ('unit', o.unit_price_ht, o.quantity)) AS v (price_basis, price, volume)
  WHERE NOT o.is_credit_note AND v.price > 0 AND v.volume > 0
  GROUP BY o.product_id, v.price_basis
  HAVING SUM(o.total_amount_ht) >= 1000 AND MAX(v.price) / NULLIF(MIN(v.price), 0) >= 1.3
), top_products AS (
  SELECT p.id, p.name, p.supplier_name, p.app_url, b.price_basis,
    ROUND(b.min_price, 2) AS min_price,
    ROUND(b.max_price, 2) AS max_price,
    ROUND(b.spend_ht, 2) AS spend_ht,
    ROUND(b.estimated_saving, 0) AS estimated_saving,
    b.min_price_document_id, b.max_price_document_id
  FROM by_product b
  JOIN products p ON p.id = b.product_id
    AND b.price_basis = CASE WHEN p.item_category_type = 'food' THEN 'kg' ELSE 'unit' END
  ORDER BY b.estimated_saving DESC
  LIMIT 10
)
SELECT t.id, t.name, t.supplier_name, t.app_url, t.price_basis,
  t.min_price, t.max_price, t.spend_ht, t.estimated_saving,
  MAX(d.app_url) FILTER (WHERE d.id = t.min_price_document_id) AS min_price_document,
  MAX(d.app_url) FILTER (WHERE d.id = t.max_price_document_id) AS max_price_document
FROM top_products t
LEFT JOIN documents d ON d.id IN (t.min_price_document_id, t.max_price_document_id)
GROUP BY t.id, t.name, t.supplier_name, t.app_url, t.price_basis,
  t.min_price, t.max_price, t.spend_ht, t.estimated_saving
ORDER BY t.estimated_saving DESC
```

## 2. Price increases

Last 6 months against the 6 months before, weighted by volume. The period covers both halves; the date literal in the query (three times) is where the recent half starts (6 months before `period_end`). For a year-on-year comparison, pass a period that covers both years and change the split. Prices are aggregated per product on both bases (per kg and per unit), then `products` is joined once to keep the basis that fits the product: each table is read once.

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08`.

```sql
WITH by_product AS (
  SELECT o.product_id, v.price_basis,
    SUM(o.total_amount_ht) FILTER (WHERE o.date < DATE '2026-04-08')
      / NULLIF(SUM(v.volume) FILTER (WHERE o.date < DATE '2026-04-08'), 0) AS price_before,
    SUM(o.total_amount_ht) FILTER (WHERE o.date >= DATE '2026-04-08')
      / NULLIF(SUM(v.volume) FILTER (WHERE o.date >= DATE '2026-04-08'), 0) AS price_recent,
    SUM(v.volume) FILTER (WHERE o.date >= DATE '2026-04-08') AS volume_recent
  FROM orders o
  CROSS JOIN LATERAL (VALUES ('kg', o.total_weight_kg), ('unit', o.quantity)) AS v (price_basis, volume)
  WHERE NOT o.is_credit_note AND v.volume > 0
  GROUP BY o.product_id, v.price_basis
), increases AS (
  SELECT product_id, price_basis, price_before, price_recent,
    (price_recent - price_before) * volume_recent AS extra_cost
  FROM by_product
  WHERE price_before > 0 AND price_recent > 0
)
SELECT p.id, p.name, p.supplier_name, p.app_url,
  ROUND(t.price_before, 2) AS price_before,
  ROUND(t.price_recent, 2) AS price_recent,
  ROUND(100 * (t.price_recent / t.price_before - 1), 1) AS change_pct,
  ROUND(t.extra_cost, 0) AS extra_cost
FROM increases t
JOIN products p ON p.id = t.product_id
  AND t.price_basis = CASE WHEN p.item_category_type = 'food' THEN 'kg' ELSE 'unit' END
ORDER BY t.extra_cost DESC
LIMIT 10
```

## 3. Purchases above a negotiated price

`fixed_price` is expressed per `fixed_price_unit` (`Kg` or `U`, compare case-insensitively); `0` means no negotiated price.

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08`.

```sql
SELECT p.id, p.name, p.supplier_name, p.app_url, p.fixed_price, p.fixed_price_unit,
  ROUND(SUM(o.total_amount_ht) / NULLIF(SUM(CASE WHEN lower(p.fixed_price_unit) = 'kg' THEN o.total_weight_kg ELSE o.quantity END), 0), 2) AS paid_price,
  ROUND(SUM(o.total_amount_ht) - p.fixed_price * SUM(CASE WHEN lower(p.fixed_price_unit) = 'kg' THEN o.total_weight_kg ELSE o.quantity END), 0) AS extra_cost
FROM orders o
JOIN products p ON p.id = o.product_id
WHERE p.fixed_price > 0
  AND NOT o.is_credit_note
GROUP BY p.id, p.name, p.supplier_name, p.app_url, p.fixed_price, p.fixed_price_unit
HAVING SUM(o.total_amount_ht) - p.fixed_price * SUM(CASE WHEN lower(p.fixed_price_unit) = 'kg' THEN o.total_weight_kg ELSE o.quantity END) > 0
ORDER BY extra_cost DESC
LIMIT 10
```
