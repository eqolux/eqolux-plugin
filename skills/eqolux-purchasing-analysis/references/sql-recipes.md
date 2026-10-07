# Eqolux SQL recipes

Tested queries for `run_sql_query`. Replace the period, names and ids with the user's. Every query covers the organization passed as `organization_id`.

## Spend by supplier

Spend totals come from `documents`, like the Eqolux app.

```sql
SELECT s.id, s.name, s.app_url,
  COUNT(*) AS documents,
  ROUND(SUM(d.total_amount_ht), 2) AS spend_ht
FROM documents d
JOIN organizations s ON s.id = d.supplier_id
WHERE d.date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY s.id, s.name, s.app_url
ORDER BY spend_ht DESC
LIMIT 20
```

## Spend by establishment and month

Pivot the result into one column per month when presenting it.

```sql
SELECT c.name AS establishment,
  date_trunc('month', d.date)::date AS month,
  ROUND(SUM(d.total_amount_ht), 2) AS spend_ht
FROM documents d
JOIN organizations c ON c.id = d.client_id
WHERE d.date >= date_trunc('month', CURRENT_DATE) - INTERVAL '11 months'
GROUP BY 1, 2
ORDER BY 1, 2
```

## Spend by product category

Categories live on products, so this one sums product lines (`orders`).

```sql
SELECT COALESCE(p.item_category_name, 'Uncategorized') AS category,
  ROUND(SUM(o.total_amount_ht), 2) AS spend_ht,
  ROUND(SUM(o.total_weight_kg), 0) AS weight_kg,
  COUNT(DISTINCT o.product_id) AS products
FROM orders o
JOIN products p ON p.id = o.product_id
WHERE o.date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY 1
ORDER BY spend_ht DESC
LIMIT 50
```

## Find a product by name

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

```sql
SELECT COALESCE(o.origin_name, 'Unknown') AS origin,
  ROUND(SUM(o.total_weight_kg), 0) AS weight_kg,
  ROUND(SUM(o.total_amount_ht), 2) AS spend_ht,
  ROUND(100.0 * SUM(o.total_amount_ht) / NULLIF(SUM(SUM(o.total_amount_ht)) OVER (), 0), 1) AS spend_share_pct
FROM orders o
WHERE o.date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY 1
ORDER BY spend_ht DESC
LIMIT 20
```

## Carbon footprint by category

`co2_kg` is an estimate in kg CO2e (Agribalyse factor × weight).

```sql
SELECT COALESCE(p.item_category_name, 'Uncategorized') AS category,
  ROUND(SUM(o.co2_kg), 0) AS co2_kg,
  ROUND(SUM(o.total_weight_kg), 0) AS weight_kg,
  ROUND(SUM(o.co2_kg) / NULLIF(SUM(o.total_weight_kg), 0), 2) AS co2_kg_per_kg
FROM orders o
JOIN products p ON p.id = o.product_id
WHERE o.date >= CURRENT_DATE - INTERVAL '12 months'
  AND o.co2_kg IS NOT NULL
GROUP BY 1
ORDER BY co2_kg DESC
LIMIT 20
```
