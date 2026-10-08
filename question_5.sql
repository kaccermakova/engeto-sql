-- Výzkumná otázka 5: Má vývoj HDP vztah ke změnám mezd a cen potravin
-- ve stejném roce nebo v roce následujícím?
-- První dotaz porovnává meziroční růst HDP, mezd a cen a doplňuje také hodnoty pro následující rok.
-- Druhý dotaz nad stejnými ukazateli počítá Pearsonovy korelační koeficienty.
-- Vzhledem k malému počtu dostupných let je potřeba korelace interpretovat pouze orientačně.

WITH gdp_series AS (
    SELECT
        sf.year,
        sf.gdp,
        LAG(sf.gdp) OVER (ORDER BY sf.year) AS previous_gdp
    FROM data_academy_content.t_katerina_cermakova_project_sql_secondary_final AS sf
    WHERE sf.country = 'Czech Republic'
),
gdp_changes AS (
    SELECT
        gs.year,
        (gs.gdp - gs.previous_gdp)
            / NULLIF(gs.previous_gdp, 0) * 100 AS gdp_growth_pct
    FROM gdp_series AS gs
),
price_series AS (
    SELECT
        pf.item_code,
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
price_changes AS (
    SELECT
        ps.year,
        AVG(
            (ps.avg_value - ps.previous_price)
            / NULLIF(ps.previous_price, 0) * 100
        ) AS price_growth_pct
    FROM price_series AS ps
    WHERE ps.year = ps.previous_year + 1
    GROUP BY ps.year
),
wage_series AS (
    SELECT
        pf.year,
        pf.avg_value,
        LAG(pf.avg_value) OVER (ORDER BY pf.year) AS previous_wage
    FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
    WHERE pf.data_type = 'wage'
        AND pf.item_code = 'CZ'
),
wage_changes AS (
    SELECT
        ws.year,
        (ws.avg_value - ws.previous_wage)
            / NULLIF(ws.previous_wage, 0) * 100 AS wage_growth_pct
    FROM wage_series AS ws
),
yearly_comparison AS (
    SELECT
        gc.year,
        gc.gdp_growth_pct,
        wc.wage_growth_pct,
        pc.price_growth_pct
    FROM gdp_changes AS gc
    JOIN wage_changes AS wc
        ON wc.year = gc.year
    JOIN price_changes AS pc
        ON pc.year = gc.year
)
SELECT
    yc.year,
    ROUND(yc.gdp_growth_pct, 2) AS gdp_growth_pct,
    ROUND(yc.wage_growth_pct, 2) AS wage_growth_pct,
    ROUND(yc.price_growth_pct, 2) AS price_growth_pct,
    ROUND(
        LEAD(yc.wage_growth_pct) OVER (ORDER BY yc.year),
        2
    ) AS wage_growth_next_pct,
    ROUND(
        LEAD(yc.price_growth_pct) OVER (ORDER BY yc.year),
        2
    ) AS price_growth_next_pct
FROM yearly_comparison AS yc
ORDER BY yc.year;


WITH gdp_series AS (
    SELECT
        sf.year,
        sf.gdp,
        LAG(sf.gdp) OVER (ORDER BY sf.year) AS previous_gdp
    FROM data_academy_content.t_katerina_cermakova_project_sql_secondary_final AS sf
    WHERE sf.country = 'Czech Republic'
),
gdp_changes AS (
    SELECT
        gs.year,
        (gs.gdp - gs.previous_gdp)
            / NULLIF(gs.previous_gdp, 0) * 100 AS gdp_growth_pct
    FROM gdp_series AS gs
),
price_series AS (
    SELECT
        pf.item_code,
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
price_changes AS (
    SELECT
        ps.year,
        AVG(
            (ps.avg_value - ps.previous_price)
            / NULLIF(ps.previous_price, 0) * 100
        ) AS price_growth_pct
    FROM price_series AS ps
    WHERE ps.year = ps.previous_year + 1
    GROUP BY ps.year
),
wage_series AS (
    SELECT
        pf.year,
        pf.avg_value,
        LAG(pf.avg_value) OVER (ORDER BY pf.year) AS previous_wage
    FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
    WHERE pf.data_type = 'wage'
        AND pf.item_code = 'CZ'
),
wage_changes AS (
    SELECT
        ws.year,
        (ws.avg_value - ws.previous_wage)
            / NULLIF(ws.previous_wage, 0) * 100 AS wage_growth_pct
    FROM wage_series AS ws
),
yearly_comparison AS (
    SELECT
        gc.year,
        gc.gdp_growth_pct,
        wc.wage_growth_pct,
        pc.price_growth_pct,
        LEAD(wc.wage_growth_pct) OVER (ORDER BY gc.year) AS wage_growth_next_pct,
        LEAD(pc.price_growth_pct) OVER (ORDER BY gc.year) AS price_growth_next_pct
    FROM gdp_changes AS gc
    JOIN wage_changes AS wc
        ON wc.year = gc.year
    JOIN price_changes AS pc
        ON pc.year = gc.year
)
SELECT
    ROUND(CORR(yc.gdp_growth_pct, yc.wage_growth_pct)::numeric, 2)
        AS corr_gdp_wage_same_year,
    ROUND(CORR(yc.gdp_growth_pct, yc.wage_growth_next_pct)::numeric, 2)
        AS corr_gdp_wage_next_year,
    ROUND(CORR(yc.gdp_growth_pct, yc.price_growth_pct)::numeric, 2)
        AS corr_gdp_price_same_year,
    ROUND(CORR(yc.gdp_growth_pct, yc.price_growth_next_pct)::numeric, 2)
        AS corr_gdp_price_next_year
FROM yearly_comparison AS yc;
