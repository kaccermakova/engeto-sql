-- Finální tabulka spojuje dva typy ročních údajů:
-- mzdy podle odvětví a ceny potravin za celou ČR.
-- Do výsledku se dostanou jen roky, které jsou dostupné v obou zdrojích.

DROP TABLE IF EXISTS data_academy_content.t_katerina_cermakova_project_sql_primary_final;

CREATE TABLE data_academy_content.t_katerina_cermakova_project_sql_primary_final AS
WITH annual_payroll AS (
    SELECT
        cp.payroll_year AS year,
        COALESCE(cp.industry_branch_code, 'CZ') AS item_code,
        COALESCE(cpib.name, 'Celkem ČR') AS item_name,
        ROUND(AVG(cp.value)::numeric, 2) AS avg_value
    FROM data_academy_content.czechia_payroll AS cp
    LEFT JOIN data_academy_content.czechia_payroll_industry_branch AS cpib
        ON cpib.code = cp.industry_branch_code
    WHERE cp.value_type_code = 5958 -- průměrná hrubá mzda na zaměstnance
        AND cp.unit_code = 200 -- Kč
        AND cp.calculation_code = 200 -- přepočtená na plné úvazky
    GROUP BY
        cp.payroll_year,
        cp.industry_branch_code,
        cpib.name
),
annual_food_prices AS (
    SELECT
        EXTRACT(YEAR FROM cpr.date_from)::int AS year,
        cpr.category_code::text AS item_code,
        cpc.name AS item_name,
        ROUND(AVG(cpr.value)::numeric, 2) AS avg_value,
        cpc.price_value AS quantity,
        cpc.price_unit AS quantity_unit
    FROM data_academy_content.czechia_price AS cpr
    JOIN data_academy_content.czechia_price_category AS cpc
        ON cpc.code = cpr.category_code
    WHERE cpr.region_code IS NULL
    GROUP BY
        EXTRACT(YEAR FROM cpr.date_from),
        cpr.category_code,
        cpc.name,
        cpc.price_value,
        cpc.price_unit
),
shared_years AS (
    SELECT year FROM annual_payroll
    INTERSECT
    SELECT year FROM annual_food_prices
),
combined_data AS (
    SELECT
        'wage' AS data_type,
        ap.year,
        ap.item_code,
        ap.item_name,
        ap.avg_value,
        NULL::double precision AS quantity,
        NULL::varchar AS quantity_unit
    FROM annual_payroll AS ap

    UNION ALL

    SELECT
        'price' AS data_type,
        afp.year,
        afp.item_code,
        afp.item_name,
        afp.avg_value,
        afp.quantity,
        afp.quantity_unit
    FROM annual_food_prices AS afp
)
SELECT
    cd.data_type,
    cd.year,
    cd.item_code,
    cd.item_name,
    cd.avg_value,
    cd.quantity,
    cd.quantity_unit
FROM combined_data AS cd
JOIN shared_years AS sy
    ON sy.year = cd.year;
