connection: "bigquery_sa_demo_agentic"
label: "Automotive Enterprise Semantic Ontology (Aftersales, Sales & Manufacturing)"

include: "/views/*.view.lkml"

explore: warranty_supplier_chargeback_explore {
  label: "1. Aftersales Warranty, Core Returns & Recall Compliance"
  description: "Governed LookML Explore joining Warranty Claims, Service Orders, Replaced Part Core Returns, Technicians, Vehicles, and NHTSA Recalls."
  from: warranty_claims_view
  view_name: warranty_claims

  join: service_orders {
    from: service_orders_view
    type: left_outer
    relationship: many_to_one
    sql_on: ${warranty_claims.service_order_id} = ${service_orders.service_order_id} ;;
  }

  join: service_parts_usage {
    from: service_parts_usage_view
    type: left_outer
    relationship: one_to_many
    sql_on: ${service_orders.service_order_id} = ${service_parts_usage.service_order_id} ;;
  }

  join: vehicle_ownership {
    from: vehicle_ownership_view
    type: left_outer
    relationship: many_to_one
    sql_on: ${warranty_claims.vin} = ${vehicle_ownership.vin} ;;
  }

  join: recall_campaigns {
    from: recall_campaigns_view
    type: left_outer
    relationship: many_to_many
    sql_on: ${warranty_claims.model} = ${recall_campaigns.model}
      AND ${warranty_claims.part_name} = ${recall_campaigns.part_name} ;;
  }
}

explore: commercial_revenue_loyalty_explore {
  label: "2. Omnichannel Retail Sales, Dealership Profitability & Household Loyalty"
  description: "Governed LookML Explore joining Vehicle Sales Transactions, Dealership Profitability, Vehicle Models, Cross-Cloud Customer Identity Crosswalk, and Customer Reviews."
  from: vehicle_sales_transactions_view
  view_name: sales_transactions

  join: dealership_profitability {
    from: dealership_profitability_view
    type: left_outer
    relationship: many_to_one
    sql_on: ${sales_transactions.dealership} = ${dealership_profitability.dealership}
      AND ${sales_transactions.model} = ${dealership_profitability.model} ;;
  }

  join: customer_identity_crosswalk {
    from: customer_identity_crosswalk_view
    type: left_outer
    relationship: one_to_one
    sql_on: ${sales_transactions.transaction_id} = ${customer_identity_crosswalk.transaction_id} ;;
  }
}

explore: supply_chain_bom_quality_explore {
  label: "3. Multi-Tier Supplier BOM Lineage & Plant Quality Inspections"
  description: "Governed LookML Explore joining Quality Inspections, Parts Inventory, Multi-Tier Supplier BOM Lineage, and Manufacturing Plants."
  from: quality_inspections_view
  view_name: quality_inspections

  join: supplier_part_lineage {
    from: supplier_part_lineage_view
    type: left_outer
    relationship: many_to_many
    sql_on: ${quality_inspections.part_name} = ${supplier_part_lineage.parent_part_name} ;;
  }
}


explore: v_semantic_aftersales_warranty_metrics_explore {
  label: "4. Governed KPI View: Aftersales Warranty & 70% Supplier Chargeback"
  description: "Pre-aggregated governed BigQuery semantic metric view (v_semantic_aftersales_warranty_metrics) for Realized Warranty Cost, 70% Recoverable Supplier Chargeback, Unrecovered Core Leakage, and Net OEM Burden."
  from: v_semantic_aftersales_warranty_metrics_view
  view_name: v_semantic_aftersales_warranty_metrics
}

explore: v_semantic_sales_profitability_metrics_explore {
  label: "5. Governed KPI View: Commercial Sales & Dealership Profitability"
  description: "Pre-aggregated governed BigQuery semantic metric view (v_semantic_sales_profitability_metrics) for Gross Retail Revenue, Realized Margin %, MSRP Realization %, and Verified Household Count."
  from: v_semantic_sales_profitability_metrics_view
  view_name: v_semantic_sales_profitability_metrics
}

explore: v_semantic_manufacturing_quality_metrics_explore {
  label: "6. Governed KPI View: Manufacturing Lot Quality & BOM Contagion Risk"
  description: "Pre-aggregated governed BigQuery semantic metric view (v_semantic_manufacturing_quality_metrics) for Lot Pass Rate %, Defect Counts, On-Hand Inventory, and BOM Contagion Risk."
  from: v_semantic_manufacturing_quality_metrics_view
  view_name: v_semantic_manufacturing_quality_metrics
}
