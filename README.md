# Automotive Enterprise Unified Semantic Models (`sa-demo-agentic`)

- **Google Cloud Project:** `sa-demo-agentic`
- **GCP & Looker Principal:** `admin@asudesh.altostrat.com`
- **GitHub Repository:** `https://github.com/asudesh-git/semantic_models.git`
- **Looker BigQuery Connection Name:** `bigquery_sa_demo_agentic`

---

## 1. Looker Git Configuration Quickstart

Use the following settings when connecting your Looker project to this Git repository:

| Setting | Value |
| :--- | :--- |
| **Repository URL (HTTPS)** | `https://github.com/asudesh-git/semantic_models.git` |
| **Repository URL (SSH)** | `git@github.com:asudesh-git/semantic_models.git` |
| **Git Production Branch** | `main` |
| **Looker Project Name** | `sa-demo-agentic-semantic-models` |
| **BigQuery Connection** | `bigquery_sa_demo_agentic` (`sa-demo-agentic`, principal `admin@asudesh.altostrat.com`) |

Because `manifest.lkml`, `automotive_enterprise.model.lkml`, and `views/automotive_semantic_views.view.lkml` are placed directly at the repository root (as well as mirrored under `lookml/`), Looker's native Git integration automatically resolves `include: "/views/*.view.lkml"` with zero configuration changes.

---

## 2. Repository Contents

### A. LookML Semantic Layer (`/`, `views/`, and `lookml/`)
- **`manifest.lkml`**: Project manifest defining `project_name: "sa-demo-agentic-semantic-models"`.
- **`automotive_enterprise.model.lkml`**:
  - `warranty_supplier_chargeback_explore` (Aftersales Warranty, Core Returns & NHTSA Recall Compliance)
  - `commercial_revenue_loyalty_explore` (Omnichannel Retail Sales, Dealership Profitability & Household Loyalty)
  - `supply_chain_bom_quality_explore` (Multi-Tier Supplier BOM Lineage & Plant Quality Inspections)
  - `v_semantic_aftersales_warranty_metrics_explore` (Governed KPI View Explore)
  - `v_semantic_sales_profitability_metrics_explore` (Governed KPI View Explore)
  - `v_semantic_manufacturing_quality_metrics_explore` (Governed KPI View Explore)
- **`views/automotive_semantic_views.view.lkml`**:
  - 10 Base & Joined Views (`warranty_claims_view`, `service_orders_view`, `service_parts_usage_view`, `vehicle_ownership_view`, `recall_campaigns_view`, `vehicle_sales_transactions_view`, `dealership_profitability_view`, `customer_identity_crosswalk_view`, `quality_inspections_view`, `supplier_part_lineage_view`)
  - 3 Governed Semantic Metric Views (`v_semantic_aftersales_warranty_metrics_view`, `v_semantic_sales_profitability_metrics_view`, `v_semantic_manufacturing_quality_metrics_view`)
- **`lookml/automotive_unified_semantic_model.lkml`**:
  - Unified `semantic_model: automotive_enterprise_ontology` spanning `auto_aftersales_data`, `auto_sales_data`, and `auto_manufacturing_data`.

### B. dbt MetricFlow Semantic Models & Metrics (`dbt_metricflow/`)
- **`dbt_project.yml`** & **`models/fct_*.sql`**: 6 dbt physical fact models (`fct_warranty_claims`, `fct_service_orders`, `fct_service_parts_usage`, `fct_vehicle_sales_transactions`, `fct_dealership_profitability`, `fct_quality_inspections`).
- **`aftersales_warranty_semantic_models.yml`**:
  - Semantic Models: `sm_auto_warranty_adjudication`, `sm_auto_service_bay_operations`, `sm_auto_service_parts_core_returns`
  - Governed Metrics: `metric_realized_warranty_cost_usd`, `metric_recoverable_supplier_chargeback_usd`, `metric_unrecovered_supplier_leakage_usd`, `metric_net_oem_warranty_burden_usd`, `metric_supplier_chargeback_recovery_rate`, `metric_oem_service_bay_absorption_usd`
- **`sales_and_manufacturing_semantic_models.yml`**:
  - Semantic Models: `sm_auto_retail_sales_transactions`, `sm_auto_dealership_profitability`, `sm_auto_manufacturing_lot_quality`
  - Governed Metrics: `metric_gross_retail_sales_revenue_usd`, `metric_realized_gross_margin_usd`, `metric_realized_gross_margin_pct`, `metric_dealership_net_profit_margin_pct`, `metric_manufacturing_lot_pass_rate_pct`, `metric_manufacturing_defects_per_lot`

### C. BigQuery Property Graphs & `MEASURE(...)` DDL (`bigquery_semantic_graphs/`)
- **`03_semantic_ontology_bq_measures_and_graphs.sql`**:
  - 6 BigQuery Semantic Property Graphs (`auto_enterprise_graph`, `warranty_supplier_chargeback_graph`, `automotive_enterprise_graph`, `commercial_revenue_loyalty_graph`, `supply_chain_bom_quality_graph`, `cross_cloud_lakehouse_graph`) with 50+ native `MEASURE(...)` definitions and 3 governed BigQuery Semantic Metric Views.
