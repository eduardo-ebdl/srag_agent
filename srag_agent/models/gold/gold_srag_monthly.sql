{{ config(
    materialized='table',
    file_format='delta',
    liquid_clustered_by=['mes_referencia']
) }}

with
    daily_source as (
        select *
        from {{ ref('gold_srag_daily') }}
    )

    , monthly_aggs as (
        select
            -- Truncando para o primeiro dia do mês
            cast(date_trunc('month', data_referencia) as date) as mes_referencia -- Somando os pré-calculados da diária
            , sum(total_casos) as total_casos
            , sum(total_obitos) as total_obitos
            , sum(total_uti) as total_uti
            , sum(total_vacinados_covid) as total_vacinados_covid   
        from daily_source
        group by 1
    )

    , window_calcs as (
        select
            *
            -- Calculando o mês anterior para variação MoM
            , lag(total_casos) over (order by mes_referencia) as casos_mes_anterior
        from monthly_aggs
    )

    , final as (
        select
            mes_referencia
            , total_casos
            , total_obitos
            , total_uti
            , total_vacinados_covid
            -- Recalculando taxas para o nível mensal
            , round(total_obitos * 100.0 / nullif(total_casos, 0), 2) as taxa_mortalidade_perc
            , round(total_uti * 100.0 / nullif(total_casos, 0), 2) as taxa_ocupacao_uti_perc
            , round(total_vacinados_covid * 100.0 / nullif(total_casos, 0), 2) as taxa_vacinacao_pacientes_perc        
            -- Taxa de aumento mensal (MoM)
            , round(
                ((total_casos - casos_mes_anterior) * 100.0) / nullif(casos_mes_anterior, 0)
            , 2) as taxa_aumento_mensal_perc
        from window_calcs
    )

select *
from final
where mes_referencia >= '2024-01-01'
order by mes_referencia desc