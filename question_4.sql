-- Výzkumná otázka 4: Existuje rok, ve kterém byl růst cen potravin
-- o více než 10 procentních bodů vyšší než růst průměrné mzdy?
-- Nejprve se vypočítají meziroční změny cen jednotlivých potravin.
-- Z těchto hodnot vznikne průměrný růst cen za každý rok, který se následně porovnává
-- s meziroční změnou celostátní průměrné mzdy.

WITH price_history AS (
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
annual_price_growth AS (
    SELECT
        ph.year,
        AVG(
            (ph.avg_value - ph.previous_price)
            / NULLIF(ph.previous_price, 0) * 100
        ) AS price_growth_pct
    FROM price_history AS ph
    WHERE ph.year = ph.previous_year + 1
    GROUP BY ph.year
),
wage_history AS (
    SELECT
        pf.year,
        pf.avg_value,
        LAG(pf.avg_value) OVER (ORDER BY pf.year) AS previous_wage
    FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
    WHERE pf.data_type = 'wage'
        AND pf.item_code = 'CZ'
),
annual_wage_growth AS (
    SELECT
        wh.year,
        (wh.avg_value - wh.previous_wage)
            / NULLIF(wh.previous_wage, 0) * 100 AS wage_growth_pct
    FROM wage_history AS wh
)
SELECT
    apg.year,
    ROUND(apg.price_growth_pct::numeric, 2) AS price_growth_pct,
    ROUND(awg.wage_growth_pct::numeric, 2) AS wage_growth_pct,
    ROUND((apg.price_growth_pct - awg.wage_growth_pct)::numeric, 2) AS diff_pp
FROM annual_price_growth AS apg
JOIN annual_wage_growth AS awg
    ON awg.year = apg.year
ORDER BY apg.year;
