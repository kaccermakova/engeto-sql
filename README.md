# SQL projekt: mzdy, ceny potravin a HDP

Projekt vznikl v rámci ENGETO Datové akademie a pracuje s českými daty o mzdách a cenách potravin doplněnými o makroekonomické údaje evropských států.

Sledované období je 2006 až 2018. Právě pro tyto roky jsou současně dostupná data potřebná pro porovnání mezd a cen.

## Jak je projekt postaven

Projekt má dvě na sebe navazující vrstvy.

Nejprve se připraví dvě finální tabulky:

| Soubor | Výsledek |
|---|---|
| `primary_final.sql` | společná tabulka s ročními údaji o mzdách a cenách potravin |
| `secondary_final.sql` | evropská data o HDP, GINI koeficientu a populaci |

Na těchto tabulkách potom běží pět analytických dotazů:

| Soubor | Zaměření |
|---|---|
| `question_1.sql` | meziroční poklesy mezd podle odvětví |
| `question_2.sql` | kupní síla průměrné mzdy pro chléb a mléko |
| `question_3.sql` | průměrné meziroční změny cen jednotlivých potravin |
| `question_4.sql` | porovnání růstu cen potravin a růstu mezd |
| `question_5.sql` | vztah mezi vývojem HDP, mezd a cen |

Podrobné výsledky a vysvětlení jednotlivých rozhodnutí jsou uvedeny v souboru [PRUVODNI_LISTINA.md](PRUVODNI_LISTINA.md).

## Doporučený postup spuštění

Skripty jsou určené pro PostgreSQL a používají schéma `data_academy_content`.

Postup je následující:

1. spustit `primary_final.sql`,
2. potom `secondary_final.sql`,
3. následně je možné spouštět `question_1.sql` až `question_5.sql` samostatně.

Soubor `question_5.sql` obsahuje dva SELECT dotazy. Jeden připravuje přehled hodnot po jednotlivých letech a druhý počítá korelační koeficienty.

Příkazy `DROP TABLE IF EXISTS` pracují pouze s finálními tabulkami vytvořenými pro tento projekt. Zdrojové tabulky v databázi se nijak nemění.

## Důležitá pravidla při přípravě dat

Pro mzdy je použita průměrná hrubá mzda na zaměstnance a přepočtený počet zaměstnanců.

Řádky bez konkrétního odvětví jsou ve finální tabulce označené kódem `CZ` a představují průměr za celou Českou republiku.

U cen se pracuje pouze s celorepublikovými záznamy (`region_code IS NULL`), aby se do jednoho ročního průměru současně nezapočítávaly krajské a celostátní hodnoty.

Do finálního období vstupují pouze roky společné pro mzdy i ceny.

## Dokumentace výsledků

Soubor [PRUVODNI_LISTINA.md](PRUVODNI_LISTINA.md) shrnuje:

- strukturu finálních tabulek,
- hlavní výsledky analýzy,
- metodiku výpočtů,
- omezení dat a způsob interpretace výsledků.

## Využití AI

Při práci na projektu byla AI využita pouze podpůrně, zejména pro kontrolu již vytvořeného SQL kódu a stylistickou úpravu textové dokumentace. Zpracování dat, výpočty a výsledky byly ověřovány nad zdrojovými daty.
