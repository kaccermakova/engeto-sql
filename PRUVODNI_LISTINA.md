# Průvodní listina k SQL projektu

Zadání: [Projekt z SQL na portálu ENGETO](https://portal.engeto.com/study/1c9fafa1-bff0-4a58-8694-a00583705b7c/project/7165d34a-7a0d-48a1-a6c4-99fb7bd7fb49/assignment)

Projekt se zaměřuje na vývoj mezd, cen základních potravin a vybraných makroekonomických ukazatelů v období 2006 až 2018.

Výsledná analýza stojí na dvou finálních tabulkách. První sjednocuje údaje o mzdách a cenách potravin, druhá doplňuje evropská data o HDP, GINI koeficientu a populaci.

Zdrojová data se neupravují. Veškeré transformace probíhají až při vytváření finálních tabulek a v navazujících analytických dotazech.

## Datový základ v kostce

Primární tabulka `t_katerina_cermakova_project_sql_primary_final` obsahuje 602 řádků.

Její struktura spojuje mzdy a ceny do jedné tabulky. Typ údaje určuje sloupec `data_type`:

- `wage` označuje mzdu,
- `price` označuje cenu potraviny.

Zastoupení dat:

| Typ dat | Počet řádků | Poznámka |
|---|---:|---|
| Mzdy | 260 | 13 let × (19 odvětví + celostátní průměr) |
| Ceny potravin | 342 | roční hodnoty jednotlivých kategorií |
| Období | 2006–2018 | společné roky pro mzdy a ceny |

Pro mzdovou část byla zvolena průměrná hrubá mzda na zaměstnance (kód 5958) přepočtená na plné úvazky (kód 200). Roční hodnota vzniká jako průměr čtvrtletních hodnot.

Celostátní průměr je v datech označen kódem `CZ` a názvem „Celkem ČR“.

Pro ceny se používají pouze celorepublikové záznamy, tedy řádky s `region_code IS NULL`.

Sekundární tabulka `t_katerina_cermakova_project_sql_secondary_final` obsahuje 585 řádků. Zahrnuje evropské státy za stejné období a pracuje s údaji o HDP, GINI koeficientu a populaci.

Pokud některá hodnota ve zdroji chybí, ve finální tabulce zůstává jako `NULL`.

## Nejpodstatnější výsledky

Analýza přinesla několik hlavních závěrů:

1. Mzdy nerostou každý rok ve všech odvětvích. Celkem bylo nalezeno **25 meziročních poklesů v 16 z 19 odvětví**.
2. Kupní síla průměrné mzdy se mezi roky 2006 a 2018 zvýšila jak u chleba, tak u mléka.
3. Nejnižší průměrná meziroční změna ceny vychází u **cukru krystalového (−1,92 %)**.
4. Ceny potravin v žádném roce nerostly o více než 10 procentních bodů rychleji než mzdy.
5. Nejsilnější z vypočtených korelací je mezi změnou HDP a růstem mezd v následujícím roce, kde vychází hodnota **0,70**.

Podrobnosti k těmto bodům jsou rozděleny podle témat níže.

## Mzdy a kupní síla

### Vývoj mezd v odvětvích

Za celé období se objevilo **25 meziročních poklesů v 16 z 19 odvětví**.

Největší počet poklesů připadá na rok **2013**, kdy mzdy klesly v 11 odvětvích.

Největší jednotlivý pokles byl také zaznamenán v roce 2013 v Peněžnictví a pojišťovnictví a dosáhl **−8,83 %**.

Opakované poklesy se objevují například v Těžbě a dobývání nebo ve Výrobě a rozvodu elektřiny, plynu a tepla.

Při pohledu na průměrnou meziroční změnu však všechna odvětví vycházejí kladně, přibližně v rozmezí od 2,75 % do 4,95 %. Jednotlivé poklesy proto představují spíše krátkodobé výkyvy než dlouhodobý trend.

### Kupní síla pro chléb a mléko

Porovnání používá celostátní průměrnou mzdu:

- 2006: **19 536 Kč**
- 2018: **32 043 Kč**

Výsledek:

| Potravina | 2006 | 2018 | Rozdíl |
|---|---:|---:|---:|
| Chléb konzumní kmínový | 1 211,9 kg | 1 321,9 kg | +110,0 kg (+9,1 %) |
| Mléko polotučné pasterované | 1 352,9 l | 1 616,7 l | +263,8 l (+19,5 %) |

Cena chleba vzrostla z 16,12 Kč na 24,24 Kč.

Cena mléka vzrostla z 14,44 Kč na 19,82 Kč.

Průměrná mzda za stejné období vzrostla o 64,0 %, cena chleba o 50,4 % a cena mléka o 37,3 %. U obou sledovaných potravin se tedy kupní síla zvýšila.

## Vývoj cen potravin

### Kategorie s nejnižší změnou ceny

Nejnižší průměrná meziroční změna vychází u **cukru krystalového (−1,92 %)**. Výsledek tedy neznamená pomalé zdražování, ale průměrný meziroční pokles ceny.

Další zápornou hodnotu mají rajská jablka červená kulatá (−0,74 %).

Pokud se vezmou pouze kategorie s kladným růstem, nejnižší hodnoty mají:

- banány žluté: +0,81 %
- vepřová pečeně s kostí: +0,99 %
- přírodní minerální voda uhličitá: +1,03 %

Nejvyšší průměrné meziroční změny naopak vycházejí u paprik (+7,29 %), másla (+6,67 %) a vajec (+5,55 %).

Jakostní bílé víno má dostupná data pouze za čtyři roky. Jeho průměr +2,70 % proto vychází z menšího počtu meziročních změn než u většiny ostatních kategorií.

### Porovnání růstu cen a mezd

Hranice 10 procentních bodů nebyla v žádném roce překročena.

Nejvyšší kladný rozdíl vyšel v roce **2013**:

| Ukazatel | Hodnota |
|---|---:|
| Růst cen potravin | +6,01 % |
| Růst mzdy | −0,13 % |
| Rozdíl | **6,14 p. b.** |

Další nejvyšší rozdíly byly v roce 2012 (4,97 p. b.) a 2011 (2,36 p. b.).

Samotný růst cen potravin se během sledovaného období také nikdy nedostal nad 10 %. Maximum bylo 9,26 % v roce 2007.

Roční růst cen se počítá jako průměr meziročních změn jednotlivých kategorií. Každá kategorie má při tomto výpočtu stejnou váhu.

## HDP a návaznost na mzdy a ceny

Pro poslední část analýzy byly porovnány meziroční změny HDP s vývojem mezd a cen ve stejném roce i v roce následujícím.

Výsledné Pearsonovy korelace:

| Vztah | Stejný rok | Následující rok |
|---|---:|---:|
| HDP × mzdy | 0,49 | 0,70 |
| HDP × ceny potravin | 0,43 | 0,05 |

Nejvyšší hodnota je 0,70 u vztahu mezi změnou HDP a růstem mezd v následujícím roce.

U cen je vazba slabší, zejména při porovnání s následujícím rokem, kde korelace vychází 0,05.

Korelace sama o sobě neprokazuje příčinnou souvislost. Například v roce 2009 HDP kleslo o 4,66 %, zatímco mzdy vzrostly o 3,37 %.

Výsledky je navíc potřeba interpretovat opatrně kvůli malému počtu pozorování. Jednotlivé korelace vycházejí pouze z 11 až 12 ročních hodnot.

## Technické a datové limity

Při interpretaci výsledků je potřeba počítat s několika omezeními:

| Oblast | Omezení / rozhodnutí |
|---|---|
| Časové období | Mzdy mají širší rozsah než ceny, proto se používají pouze společné roky 2006–2018. |
| Potravinové kategorie | Primární tabulka obsahuje 27 kategorií. Jakostní bílé víno nemá data za celé období. |
| Počet cenových řádků | Kvůli neúplné časové řadě vína vzniká 342 cenových řádků místo 351. |
| Zdroj cen | Používá se 7 217 celorepublikových záznamů z původních 108 249 řádků tabulky `czechia_price`. |
| Jednotky | U chleba i mléka je množství rovné 1, ale množství zůstává ve výpočtu kvůli obecné použitelnosti vzorce. |
| Evropská data | Za sledované období chybí 37 hodnot HDP a 124 hodnot GINI. |
| Výpočet růstu cen | V otázkách 4 a 5 má každá kategorie stejnou váhu. |
