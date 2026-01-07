# SRAG Data Engineering (dbt)
> **Transformação e Modelagem de Dados Epidemiológicos no Lakehouse**

Este módulo é responsável pela **Engenharia de Dados** do projeto. Utiliza **dbt Core** para transformar os dados brutos do OpenDataSUS em tabelas confiáveis para o consumo do Agente de IA.

---

## Arquitetura Medallion

O pipeline implementa o padrão Bronze-Silver-Gold para garantir governança e performance:

| Camada | Tabela | Função e Tratamentos |
| :--- | :--- | :--- |
| **🥉 Bronze** | `srag_raw` | Ingestão bruta dos arquivos CSV. Espelho fiel da fonte. |
| **🥈 Silver** | `srag_silver` | **Limpeza:** Tratamento de nulos, tipagem de datas e remoção de colunas técnicas.<br>**Segurança:** Remoção de PII (Dados Pessoais Sensíveis) para conformidade LGPD. |
| **🥇 Gold** | `srag_gold` | **Agregação:** Cálculo de métricas analíticas (Taxa de Mortalidade, Ocupação de UTI, Vacinação) prontas para o Agente SQL. |
---

## Data Quality & Testes

A qualidade é garantida via testes nativos do dbt definidos no `schema.yml`:

* **Integridade:** Testes de `not_null` e `unique` nas chaves primárias.
* **Consistência:** Testes de `accepted_values` para colunas categóricas (ex: Sexo, UF).

---

## Comandos Principais

```bash
# Executar todo o pipeline (Bronze -> Silver -> Gold)
dbt run

# Rodar a bateria de testes de qualidade
dbt test

# Gerar documentação do catálogo de dados
dbt docs generate
```
