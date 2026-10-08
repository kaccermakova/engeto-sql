-- Otázka 2
-- Porovnávám kupní sílu průměrné české mzdy v prvním a posledním roce.
-- Z potravin vybírám pouze chléb a mléko.

WITH comparison_years AS (
    SELECT
        MIN(pf.year) AS first_year,
        MAX(pf.year) AS last_year
    FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
),
selected_prices AS (
    SELECT
        pf.year,
        pf.item_name,
        pf.avg_value AS price,
        pf.quantity,
        pf.quantity_unit
    FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
    CROSS JOIN comparison_years AS cy
    WHERE pf.data_type = 'price'
        AND pf.year IN (cy.first_year, cy.last_year)
        AND (
            pf.item_name ILIKE 'chléb%'
            OR pf.item_name ILIKE 'mléko%'
        )
)
SELECT
    sp.year,
    sp.item_name,
    sp.quantity,
    sp.quantity_unit,
    w.avg_value AS wage,
    sp.price,
    ROUND((w.avg_value / sp.price * sp.quantity)::numeric, 1) AS affordable_amount
FROM selected_prices AS sp
JOIN data_academy_content.t_katerina_cermakova_project_sql_primary_final AS w
    ON w.year = sp.year
    AND w.data_type = 'wage'
    AND w.item_code = 'CZ'
ORDER BY
    sp.item_name,
    sp.year;
