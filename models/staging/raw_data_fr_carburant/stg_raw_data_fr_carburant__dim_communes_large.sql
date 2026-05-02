with 

source as (

    select * from {{ source('raw_data_fr_carburant', 'dim_communes_large') }}

),

renamed as (

    select
        id_ligne,
        code_insee,
        nom_standard,
        nom_sans_pronom,
        nom_a,
        nom_de,
        nom_sans_accent,
        nom_standard_majuscule,
        typecom,
        typecom_texte,
        reg_code,
        reg_nom,
        dep_code,
        dep_nom,
        canton_code,
        canton_nom,
        epci_code,
        epci_nom,
        academie_code,
        academie_nom,
        code_postal,
        codes_postaux,
        zone_emploi,
        code_insee_centre_zone_emploi,
        code_unite_urbaine,
        nom_unite_urbaine,
        taille_unite_urbaine,
        type_commune_unite_urbaine,
        statut_commune_unite_urbaine,
        population,
        superficie_hectare,
        superficie_km2,
        densite,
        altitude_moyenne,
        altitude_minimale,
        altitude_maximale,
        latitude_mairie,
        longitude_mairie,
        latitude_centre,
        longitude_centre,
        grille_densite,
        grille_densite_texte,
        niveau_equipements_services,
        niveau_equipements_services_texte,
        gentile,
        url_wikipedia,
        url_villedereve,
        geo_point_centre

    from source

)

select * from renamed