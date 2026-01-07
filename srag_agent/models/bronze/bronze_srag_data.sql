{{ config(
    materialized='ephemeral',
    file_format='delta'
) }}

with
    source_sample as (
        select
            -- 1. Chaves e Tempo
            try_cast(dt_notific as date) as dt_notific -- Data do preenchimento da ficha
            , try_cast(dt_sin_pri as date) as dt_sin_pri -- Data de início de sintomas
            , cast(sem_not as string) as sem_not -- Semana epidemiológica
            -- 2. Geografia
            , cast(sg_uf_not as string) as sg_uf_not -- UF de notificação
            , cast(id_municip as string) as id_municip -- Nome do município
            -- 3. Demografia
            , cast(cs_sexo as string) as cs_sexo -- Sexo do paciente (M/F)
            , cast(cs_raca as int) as cs_raca -- Cor/Raça
            , cast(nu_idade_n as int) as nu_idade_n -- Valor da idade
            , cast(tp_idade as int) as tp_idade -- Tipo da idade
            -- 4. Métricas de Gravidade
            , cast(hospital as int) as hospital -- Foi internado?
            , cast(uti as int) as uti -- Foi para UTI?
            , try_cast(dt_entuti as date) as dt_entuti -- Data entrada UTI
            , try_cast(dt_saiduti as date) as dt_saiduti -- Data saída UTI
            , cast(suport_ven as int) as suport_ven -- Suporte ventilatório
            -- 5. Métricas de Desfecho
            , cast(evolucao as int) as evolucao -- 1=Cura, 2=Óbito, 3=Óbito outras causas
            , try_cast(dt_evoluca as date) as dt_evoluca -- Data do óbito/cura
            -- 6. Métricas de Vacinação
            , cast(vacina as int) as vacina -- Vacina de Gripe/Influenza
            , cast(vacina_cov as int) as vacina_cov -- Vacina de COVID-19 (S/N)
            , try_cast(dose_2_cov as date) as dose_2_cov -- Data da 2ª dose
            , try_cast(dose_ref as date) as dose_ref -- Data da dose de reforço
            -- 7. Diagnóstico e Comorbidades
            , cast(classi_fin as int) as classi_fin -- Classificação final
            , cast(fator_risc as int) as fator_risc -- Tem fator de risco? (S/N)
            , cast(cardiopati as int) as cardiopati -- Doença Cardíaca
            , cast(diabetes as int) as diabetes -- Diabetes
            , cast(obesidade as int) as obesidade -- Obesidade
            , cast(pneumopati as int) as pneumopati -- Doença Pulmonar
            , cast(imunodepre as int) as imunodepre -- Imunodepressão
        from {{ source('srag_prod', 'srag_raw') }}
    )

select *
from source_sample

