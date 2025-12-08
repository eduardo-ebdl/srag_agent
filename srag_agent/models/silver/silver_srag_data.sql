{{ config(
    materialized='table',
    file_format='delta',
    liquid_clustered_by=['dt_sin_pri', 'uf']
) }}

with
    source as (
        select *
        from {{ ref('bronze_srag_data') }}
    )

    , renamed_and_cleaned as (
        select
            -- 1. Identificação temporal
            dt_notific
            , dt_sin_pri
            , sem_not
            -- 2. Geografia
            , sg_uf_not as uf
            , id_municip as municipio
            -- 3. Demografia
            , cs_sexo as sexo
            , case
                when tp_idade = 3 then nu_idade_n             -- Anos
                when tp_idade = 2 then nu_idade_n / 12.0      -- Meses viram fração
                when tp_idade = 1 then nu_idade_n / 365.0     -- Dias viram fração
                else null
            end as idade_anos
            -- 4. Diagnóstico
            , case 
                when classi_fin = 1 then 'Influenza'
                when classi_fin = 2 then 'Outro Virus Respiratorio'
                when classi_fin = 3 then 'Outro Agente Etiologico'
                when classi_fin = 4 then 'Nao Especificado'
                when classi_fin = 5 then 'COVID-19'
                else 'Em Investigacao/Outros'
            end as diagnostico_final
            -- 5. Gravidade e flags
            , case when uti = 1 then 1 else 0 end as internado_uti_flag
            , case when uti = 1 then 'Sim' when uti = 2 then 'Não' else 'Ignorado' end as desc_uti
            , dt_entuti
            , dt_saiduti
            , case 
                when suport_ven = 1 then 'Invasivo' 
                when suport_ven = 2 then 'Nao Invasivo' 
                else 'Nao/Ignorado' 
            end as suporte_ventilatorio
            -- 6. Desfecho
            , case 
                when evolucao = 1 then 'Cura'
                when evolucao = 2 then 'Obito'
                when evolucao = 3 then 'Obito (Outras Causas)'
                else 'Em Andamento/Ignorado'
            end as evolucao_caso
            , case when evolucao = 2 then 1 else 0 end as obito_srag_flag
            -- 7. Vacinação
            , case when vacina_cov = 1 then 1 else 0 end as vacina_covid_flag
            , case when vacina = 1 then 1 else 0 end as vacina_gripe_flag          
            -- 8. Comorbidades flags (Para cálculos estatísticos)
            , coalesce(case when cardiopati = 1 then 1 else 0 end, 0) as cardiopatia_flag
            , coalesce(case when diabetes = 1 then 1 else 0 end, 0) as diabetes_flag
            , coalesce(case when obesidade = 1 then 1 else 0 end, 0) as obesidade_flag
            , coalesce(case when pneumopati = 1 then 1 else 0 end, 0) as pneumopatia_flag
            , coalesce(case when imunodepre = 1 then 1 else 0 end, 0) as imunodepressao_flag
            -- 9. Comorbidades texto (Para IA/RAG)
            , concat_ws(', ',
                case when cardiopati = 1 then 'Cardiopatia' end,
                case when diabetes = 1 then 'Diabetes' end,
                case when obesidade = 1 then 'Obesidade' end,
                case when pneumopati = 1 then 'Pneumopatia' end,
                case when imunodepre = 1 then 'Imunodepressao' end
            ) as lista_comorbidades
        from source
    )

select *
from renamed_and_cleaned