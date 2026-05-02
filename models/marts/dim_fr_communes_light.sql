{{
    config(
        materialized='table'
    )
}}

WITH ref AS(
    SELECT
        *
    FROM {{ ref('stg_raw_data_fr_carburant__dim_communes_large') }}
)

, reduce_table AS(
    SELECT
      -- pour réduire le nombre de colonne
      code_insee,
      nom_standard AS ville,
      dep_nom AS departement,
      dep_code AS departement_code,
      code_postal,
      latitude_centre,
      longitude_centre,
      geo_point_centre,
    FROM ref
    -- WHERE population > 300 -- pour réduire le nombre de ligne 
  )

  SELECT * FROM reduce_table