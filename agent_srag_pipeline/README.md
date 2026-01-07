# ⚙️ SRAG Pipeline Orchestration
> **Gerenciamento de Jobs e Workflows com Databricks Asset Bundles (DABs)**

Este módulo é responsável pela **Infraestrutura como Código** do projeto. Ele define, agenda e gerencia a execução automática dos notebooks de ingestão de dados.

---

## Workflow Definido: `extract_srag`

O pipeline principal foi configurado para garantir a atualização mensal dos dados do OpenDataSUS.

* **📅 Agendamento:** Todo dia **16 do mês**, às **12:00** (Horário de Brasília).
* **📧 Notificação:** Envio de e-mail automático em caso de falha (`on_failure`).

### Cadeia de Execução (Tasks)

1.  **`extract_srag_task`**
    * *Função:* Extrai dados brutos da fonte governamental.
    * *Parâmetros:* `target_years: 2024,2025`
2.  **`load_srag_task`** *(Depende da anterior)*
    * *Função:* Carrega os dados persistidos para a tabela `srag_raw` (Bronze).

---

## Guia de Deploy (CLI)

Para implantar ou atualizar este pipeline no Databricks Workspace:

```bash
# 1. Autenticar no Databricks
databricks configure

# 2. Validar a sintaxe do arquivo .yml
databricks bundle validate

# 3. Fazer o Deploy (Dev ou Prod)
databricks bundle deploy

# 4. (Opcional) Forçar uma execução manual agora
databricks bundle run extract_srag
```
