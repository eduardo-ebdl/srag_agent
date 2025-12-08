{{ config(
    materialized='table',
    file_format='delta',
    liquid_clustered_by=['data_referencia']
) }}

with
    source as (
        select *
        from {{ ref('silver_srag_data') }}
    )

    , daily_aggs as (
        select
            -- Agrupamento por data de início de sintomas
            dt_sin_pri as data_referencia
            -- Totais absolutos
            , count(*) as total_casos
            , sum(obito_srag_flag) as total_obitos
            , sum(internado_uti_flag) as total_uti
            , sum(vacina_covid_flag) as total_vacinados_covid
        from source
        where dt_sin_pri is not null
        and dt_sin_pri >= '2023-12-01'
        group by 1
    )

    , window_calcs as (
        select
            *
            -- Calculando o dia anterior para o "growth rate"
            , lag(total_casos) over (order by data_referencia) as casos_dia_anterior
        from daily_aggs
    )

    , final as (
        select
            data_referencia
            , total_casos
            , total_obitos
            , total_uti
            , total_vacinados_covid
            
            -- Métricas percentuais (KPIs)
            , round(total_obitos * 100.0 / nullif(total_casos, 0), 2) as taxa_mortalidade_perc
            , round(total_uti * 100.0 / nullif(total_casos, 0), 2) as taxa_ocupacao_uti_perc
            , round(total_vacinados_covid * 100.0 / nullif(total_casos, 0), 2) as taxa_vacinacao_pacientes_perc
            
            -- Taxa de aumento diário
            , round(
                ((total_casos - casos_dia_anterior) * 100.0) / nullif(casos_dia_anterior, 0)
            , 2) as taxa_aumento_casos_perc
        
        from window_calcs
    )

select *
from final
where data_referencia >= '2024-01-01'
order by data_referencia desc