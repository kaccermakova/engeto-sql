-- Druhá finální tabulka obsahuje evropská makroekonomická data.
-- Časové období se automaticky přizpůsobí rokům uloženým v primární tabulce.
-- Chybějící hodnoty HDP nebo GINI ponechávám jako NULL.

DROP TABLE IF EXISTS data_academy_content.t_katerina_cermakova_project_sql_secondary_final;

CREATE TABLE data_academy_content.t_katerina_cermakova_project_sql_secondary_final AS
SELECT
    c.country,
    e.year,
    ROUND(e.gdp::numeric, 0) AS gdp,
    e.gini,
    e.population
FROM data_academy_content.economies AS e
JOIN data_academy_content.countries AS c
    ON c.country = e.country
WHERE c.continent = 'Europe'
    AND e.year BETWEEN
        (
            SELECT MIN(pf.year)
            FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
        )
        AND
        (
            SELECT MAX(pf.year)
            FROM data_academy_content.t_katerina_cermakova_project_sql_primary_final AS pf
        );
