-- Otázka 3
-- U každé potraviny porovnávám cenu s předchozím dostupným rokem.
-- Do průměru započítávám jen skutečně navazující roky,
-- aby kategorie s mezerou v datech nebyly zkreslené.

WITH price_history AS (
    SELECT
        pf.item_code,
        pf.item_name,
        pf.year,
        pf.avg_value,
        LAG(pf.year) OVER (
            PARTITION BY pf.item_code
            ORDER BY pf.year
        ) AS previous_year,
        LAG(pf.avg_value) OVER (
            PARTITION BY pf.item_code
            ORDER BY pf.year
        ) AS previous_price
    FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
    WHERE pf.data_type = 'price'
),
valid_changes AS (
    SELECT
        ph.item_code,
        ph.item_name,
        ph.year,
        (ph.avg_value - ph.previous_price)
            / NULLIF(ph.previous_price, 0) * 100 AS change_pct
    FROM price_history AS ph
    WHERE ph.year = ph.previous_year + 1
)
SELECT
    vc.item_name,
    COUNT(*) AS year_pairs,
    ROUND(AVG(vc.change_pct)::numeric, 2) AS avg_yoy_change_pct
FROM valid_changes AS vc
GROUP BY
    vc.item_code,
    vc.item_name
ORDER BY
    avg_yoy_change_pct,
    vc.item_name;
