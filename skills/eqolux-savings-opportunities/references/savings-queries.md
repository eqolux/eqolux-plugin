# Savings queries

Tested queries for `run_sql_query`. Adapt the period and the thresholds (minimum spend, price ratio) to the user's request.

Each query lists the arguments to pass with the SQL. The dates are examples for a question asked on 2026-10-07: replace them with the user's period. `period_start` is included and `period_end` excluded, so pass tomorrow's date to include today. The period limits `orders` and `documents` before the query runs, which is what keeps it fast; a `WHERE` on `date` alone does not.

## 1. The same product at very different prices

Food is compared per kg, other products per unit. The two last columns link the documents where the lowest and highest prices were paid.

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08` (last 12 months).

```sql
WITH lines AS (
  SELECT o.product_id, o.document_id, o.total_amount_ht, o.quantity, o.total_weight_kg,
    CASE WHEN p.item_category_type = 'food' THEN o.price_per_kg ELSE o.unit_price_ht END AS price,
    CASE WHEN p.item_category_type = 'food' THEN 'kg' ELSE 'unit' END AS price_basis,
    CASE WHEN p.item_category_type = 'food' THEN o.total_weight_kg ELSE o.quantity END AS volume
  FROM orders o
  JOIN products p ON p.id = o.product_id
  WHERE NOT o.is_credit_note
)
SELECT p.id, p.name, p.supplier_name, p.app_url, l.price_basis,
  ROUND(MIN(l.price), 2) AS min_price,
  ROUND(MAX(l.price), 2) AS max_price,
  ROUND(SUM(l.total_amount_ht), 2) AS spend_ht,
  ROUND(SUM(l.total_amount_ht) - MIN(l.price) * SUM(l.volume), 0) AS estimated_saving,
  (SELECT d.app_url FROM documents d WHERE d.id = (array_agg(l.document_id ORDER BY l.price ASC))[1]) AS min_price_document,
  (SELECT d.app_url FROM documents d WHERE d.id = (array_agg(l.document_id ORDER BY l.price DESC))[1]) AS max_price_document
FROM lines l
JOIN products p ON p.id = l.product_id
WHERE l.price > 0 AND l.volume > 0
GROUP BY p.id, p.name, p.supplier_name, p.app_url, l.price_basis
HAVING SUM(l.total_amount_ht) >= 1000 AND MAX(l.price) / NULLIF(MIN(l.price), 0) >= 1.3
ORDER BY estimated_saving DESC
LIMIT 10
```

## 2. Price increases

Last 6 months against the 6 months before, weighted by volume. The period covers both halves; the date literal in the query is where the recent half starts (6 months before `period_end`). For a year-on-year comparison, pass a period that covers both years and change the split.

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08`.

```sql
WITH lines AS (
  SELECT o.product_id,
    CASE WHEN o.date >= DATE '2026-04-08' THEN 'recent' ELSE 'before' END AS period,
    o.total_amount_ht,
    CASE WHEN p.item_category_type = 'food' THEN o.total_weight_kg ELSE o.quantity END AS volume
  FROM orders o
  JOIN products p ON p.id = o.product_id
  WHERE NOT o.is_credit_note
), by_period AS (
  SELECT product_id,
    SUM(total_amount_ht) FILTER (WHERE period = 'before') / NULLIF(SUM(volume) FILTER (WHERE period = 'before'), 0) AS price_before,
    SUM(total_amount_ht) FILTER (WHERE period = 'recent') / NULLIF(SUM(volume) FILTER (WHERE period = 'recent'), 0) AS price_recent,
    SUM(volume) FILTER (WHERE period = 'recent') AS volume_recent
  FROM lines
  WHERE volume > 0
  GROUP BY product_id
)
SELECT p.id, p.name, p.supplier_name, p.app_url,
  ROUND(b.price_before, 2) AS price_before,
  ROUND(b.price_recent, 2) AS price_recent,
  ROUND(100 * (b.price_recent / b.price_before - 1), 1) AS change_pct,
  ROUND((b.price_recent - b.price_before) * b.volume_recent, 0) AS extra_cost
FROM by_period b
JOIN products p ON p.id = b.product_id
WHERE b.price_before > 0 AND b.price_recent > 0
ORDER BY extra_cost DESC
LIMIT 10
```

## 3. Purchases above a negotiated price

`fixed_price` is expressed per `fixed_price_unit` (`kg` or `unit`).

Arguments: `period_start` `2025-10-08`, `period_end` `2026-10-08`.

```sql
SELECT p.id, p.name, p.supplier_name, p.app_url, p.fixed_price, p.fixed_price_unit,
  ROUND(SUM(o.total_amount_ht) / NULLIF(SUM(CASE WHEN p.fixed_price_unit = 'kg' THEN o.total_weight_kg ELSE o.quantity END), 0), 2) AS paid_price,
  ROUND(SUM(o.total_amount_ht) - p.fixed_price * SUM(CASE WHEN p.fixed_price_unit = 'kg' THEN o.total_weight_kg ELSE o.quantity END), 0) AS extra_cost
FROM orders o
JOIN products p ON p.id = o.product_id
WHERE p.fixed_price IS NOT NULL
  AND NOT o.is_credit_note
GROUP BY p.id, p.name, p.supplier_name, p.app_url, p.fixed_price, p.fixed_price_unit
HAVING SUM(o.total_amount_ht) - p.fixed_price * SUM(CASE WHEN p.fixed_price_unit = 'kg' THEN o.total_weight_kg ELSE o.quantity END) > 0
ORDER BY extra_cost DESC
LIMIT 10
```
