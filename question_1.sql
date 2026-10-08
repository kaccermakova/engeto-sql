-- Výzkumná otázka 1: Rostou mzdy v průběhu let ve všech odvětvích, nebo se v některých letech objevuje pokles?
-- Pro každé odvětví se porovnává mzda s hodnotou z předchozího roku.
-- Výstup ukazuje počet meziročních poklesů, roky jejich výskytu, nejhorší změnu
-- a průměrnou meziroční změnu za celé sledované období.

WITH wage_history AS (
    SELECT
        pf.item_code,
        pf.item_name,
        pf.year,
        pf.avg_value,
        LAG(pf.avg_value) OVER (
            PARTITION BY pf.item_code
            ORDER BY pf.year
        ) AS previous_wage
    FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
    WHERE pf.data_type = 'wage'
        AND pf.item_code <> 'CZ'
),
wage_changes AS (
    SELECT
        wh.item_code,
        wh.item_name,
        wh.year,
        (wh.avg_value - wh.previous_wage)
            / NULLIF(wh.previous_wage, 0) * 100 AS change_pct
    FROM wage_history AS wh
)
SELECT
    wc.item_code,
    wc.item_name,
    COUNT(*) FILTER (WHERE wc.change_pct < 0) AS decline_count,
    STRING_AGG(wc.year::text, ', ' ORDER BY wc.year)
        FILTER (WHERE wc.change_pct < 0) AS decline_years,
    ROUND(MIN(wc.change_pct), 2) AS worst_change_pct,
    ROUND(AVG(wc.change_pct), 2) AS avg_yoy_change_pct
FROM wage_changes AS wc
GROUP BY
    wc.item_code,
    wc.item_name
ORDER BY
    decline_count DESC,
    wc.item_code;
