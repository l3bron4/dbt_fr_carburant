{{
    config(
        materialized='view'
    )
}}

WITH fr_carbu_geo_point AS(
    SELECT 
      *,
      ST_GEOGPOINT(longitude, latitude) AS geo_point_station,
    FROM {{ ref('fact_fr_carburant') }} 
  )

  , commune_cible AS(
    SELECT 
      code_insee,
      ville AS ville_ref,
      departement AS dep_ref,
      departement_code AS dep_code_ref,
      code_postal AS cp_ref, 
      latitude_centre,
      longitude_centre,
      geo_point_centre,
    FROM {{ ref('dim_fr_communes_light') }}
    WHERE ville = 'Craponne'  -- ici choisir la ville de reference -- Si homonyme, rajouter le code postal
      AND code_postal = '69290' 
    LIMIT 1
    
  )

  , fr_carbu_distance_ref AS(
    SELECT
      *,
      ROUND(ST_DISTANCE(geo_point_station, geo_point_centre) /1000, 0) AS distance_station_km,
    FROM fr_carbu_geo_point carbu
    CROSS JOIN commune_cible
  )

  SELECT * FROM fr_carbu_distance_ref