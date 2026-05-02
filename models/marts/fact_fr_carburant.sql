{{
    config(
        materialized='table'
    )
}}

WITH raw_unnest_carbu AS(
  SELECT 
    * EXCEPT(tableau_carburants)
  FROM {{ ref('stg_raw_data_fr_carburant__fuel_api_prices_raw') }}
  CROSS JOIN UNNEST(tableau_carburants) AS carburant_dispo
)

, raw_e10_cte AS(
  SELECT
    id_station,
    latitude,
    longitude,
    latlong,
    ville,
    code_postal,
    adresse,
    departement,
    code_departement,
    region,
    e10_prix AS prix,
    e10_maj AS date_maj,
    DATE_DIFF(CURRENT_TIMESTAMP(), e10_maj, DAY) AS diff_date_maj,
    carburant_dispo AS carburant,
  FROM raw_unnest_carbu
  WHERE carburant_dispo = 'E10'
)

, raw_gazole_cte AS(
  SELECT
    id_station,
    latitude,
    longitude,
    latlong,
    ville,
    code_postal,
    adresse,
    departement,
    code_departement,
    region,
    gazole_prix AS prix,
    gazole_maj AS date_maj,
    DATE_DIFF(CURRENT_TIMESTAMP(), gazole_maj, DAY) AS diff_date_maj,
    carburant_dispo AS carburant,
  FROM raw_unnest_carbu
  WHERE carburant_dispo = 'Gazole'
)

, raw_sp95_cte AS(
  SELECT
    id_station,
    latitude,
    longitude,
    latlong,
    ville,
    code_postal,
    adresse,
    departement,
    code_departement,
    region,
    sp95_prix AS prix,
    sp95_maj AS date_maj,
    DATE_DIFF(CURRENT_TIMESTAMP(), sp95_maj, DAY) AS diff_date_maj,
    carburant_dispo AS carburant,
  FROM raw_unnest_carbu
  WHERE carburant_dispo = 'SP95'
)

, raw_sp98_cte AS(
  SELECT
    id_station,
    latitude,
    longitude,
    latlong,
    ville,
    code_postal,
    adresse,
    departement,
    code_departement,
    region,
    sp98_prix AS prix,
    sp98_maj AS date_maj,
    DATE_DIFF(CURRENT_TIMESTAMP(), sp98_maj, DAY) AS diff_date_maj,
    carburant_dispo AS carburant,
  FROM raw_unnest_carbu
  WHERE carburant_dispo = 'SP98'
)

, raw_union_all AS(
  SELECT * FROM raw_gazole_cte
  UNION ALL 
  SELECT * FROM raw_e10_cte
  UNION ALL 
  SELECT * FROM raw_sp95_cte
  UNION ALL 
  SELECT * FROM raw_sp98_cte  
)

SELECT 
  *,
  ROUND((AVG(prix) OVER(PARTITION BY carburant, departement)), 2) AS prix_moyen_global, 
FROM raw_union_all