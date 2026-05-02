with 

source as (

    select * from {{ source('raw_data_fr_carburant', 'fuel_api_prices_raw') }}

)

, raw_cast_filter AS(
  SELECT 
    id AS id_station,
    --------------
    ROUND(CAST(latitude AS FLOAT64) / 100000, 3) AS latitude,
    ROUND(CAST(longitude AS FLOAT64) / 100000, 3) AS longitude,
    CAST(ROUND(CAST(latitude AS FLOAT64) / 100000, 3) + ROUND(CAST(longitude AS FLOAT64) / 100000, 3) AS STRING) AS check_doublons,
    cp AS code_postal,
    ville,
    CONCAT(adresse, ', ', cp, ', ', ville) AS adresse,
    departement,
    code_departement, 
    region,
    code_region,
    --------------
    CAST(NULLIF(gazole_prix, 'nan') AS FLOAT64) AS gazole_prix,
    CAST(NULLIF(gazole_maj, 'None') AS TIMESTAMP) AS gazole_maj,
    CAST(NULLIF(e10_prix, 'nan') AS FLOAT64) AS e10_prix,
    CAST(NULLIF(e10_maj, 'None') AS TIMESTAMP) AS e10_maj,
    CAST(NULLIF(sp95_prix, 'nan') AS FLOAT64) AS sp95_prix,
    CAST(NULLIF(sp95_maj, 'None') AS TIMESTAMP) AS sp95_maj,
    CAST(NULLIF(sp98_prix, 'nan') AS FLOAT64) AS sp98_prix,
    CAST(NULLIF(sp98_maj, 'None') AS TIMESTAMP) AS sp98_maj,
    --------------
    carburants_disponibles,
    JSON_EXTRACT_STRING_ARRAY(REPLACE(carburants_disponibles, "'", '"')) AS tableau_carburants,
  FROM source
)

##########

, raw_gap_close_station AS ( 
  -- !!! 3 requetes imbriqués pour : 
    -- 1// identifier les stations à même coordonnées GPS avec check_doublons de la précédente requete
    -- 2// mettre un gap sur la lattide 
    -- 3// créer la coordonnées latlong (latitude,longitude)
  SELECT
    *, 
    CONCAT(latitude, ',', longitude) AS latlong,
  FROM (
    SELECT 
      id_station,
      CASE
        WHEN close_station = 2 THEN latitude + 0.001 -- pour mettre un gap entre 2 stations trop proches avec des coordonnées GPS raw identiques
        WHEN close_station = 1 THEN latitude
        WHEN close_station = 3 THEN latitude + 0.002 -- au cas où 3 stations un nouveau gap
        END
        AS latitude,
      longitude,
      ville,
      adresse,
      code_postal,
      departement,
      code_departement,
      region,
      code_region,
      ----------------
      gazole_prix,
      gazole_maj,
      e10_prix,
      e10_maj,
      sp95_prix,
      sp95_maj,
      sp98_prix,
      sp98_maj,
      ----------------
      carburants_disponibles,
      tableau_carburants,
    FROM (
      SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY ville, check_doublons) AS close_station,
      FROM raw_cast_filter
    )  
  )
)

select * from raw_gap_close_station