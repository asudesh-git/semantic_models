view: warranty_claims_view {
  sql_table_name: `sa-demo-agentic.auto_aftersales_data.warranty_claims` ;;
  label: "Warranty Claims"

  dimension: claim_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.claim_id ;;
    description: "Unique warranty claim identifier"
  }

  dimension: service_order_id {
    type: string
    sql: ${TABLE}.service_order_id ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.vin ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: dealership {
    type: string
    sql: ${TABLE}.dealership ;;
  }

  dimension: part_name {
    type: string
    sql: ${TABLE}.part_name ;;
  }

  dimension: part_source_plant_name {
    type: string
    sql: ${TABLE}.part_source_plant_name ;;
    description: "Tier-1 supplier facility that manufactured the failed component"
  }

  dimension: claim_status {
    type: string
    sql: ${TABLE}.claim_status ;;
  }

  dimension: defect_category {
    type: string
    sql: ${TABLE}.defect_category ;;
  }

  dimension: supplier_fault {
    type: yesno
    sql: ${TABLE}.supplier_fault ;;
  }

  measure: realized_warranty_cost_usd {
    label: "Realized Warranty Cost (USD)"
    type: sum
    sql: ${TABLE}.claim_amount ;;
    filters: [claim_status: "Approved"]
    value_format_name: usd
    description: "Approved warranty claim spend: SUM(claim_amount) WHERE claim_status = 'Approved'"
  }

  measure: gross_supplier_fault_claim_usd {
    label: "Gross Supplier-Fault Approved Claim Spend (USD)"
    type: sum
    sql: ${TABLE}.claim_amount ;;
    filters: [claim_status: "Approved", supplier_fault: "yes"]
    value_format_name: usd
    description: "Approved warranty claim spend where supplier_fault = TRUE"
  }

  measure: total_warranty_claims_count {
    label: "Total Warranty Claims Count"
    type: count
    description: "Total count of warranty claims filed"
  }

  measure: avg_claim_resolution_days {
    label: "Avg Claim Resolution Days"
    type: average
    sql: ${TABLE}.resolution_days ;;
    value_format_name: decimal_1
  }
}

view: service_orders_view {
  sql_table_name: `sa-demo-agentic.auto_aftersales_data.service_orders` ;;
  label: "Service Orders"

  dimension: service_order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.service_order_id ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.vin ;;
  }

  dimension: technician_id {
    type: string
    sql: ${TABLE}.technician_id ;;
  }

  dimension: dealership {
    type: string
    sql: ${TABLE}.dealership ;;
  }

  dimension: is_warranty_covered {
    type: yesno
    sql: ${TABLE}.is_warranty_covered ;;
  }

  measure: oem_warranty_service_absorption_usd {
    label: "OEM Warranty Service Absorption (USD)"
    type: sum
    sql: ${TABLE}.total_cost - ${TABLE}.customer_paid_amount ;;
    filters: [is_warranty_covered: "yes"]
    value_format_name: usd
    description: "Total dealership repair cost absorbed by the OEM on warranty-covered service orders"
  }

  measure: customer_out_of_pocket_spend_usd {
    label: "Customer Out-of-Pocket Spend (USD)"
    type: sum
    sql: ${TABLE}.customer_paid_amount ;;
    value_format_name: usd
  }

  measure: avg_days_in_shop {
    label: "Avg Days in Shop"
    type: average
    sql: ${TABLE}.days_in_shop ;;
    value_format_name: decimal_1
  }
}

view: service_parts_usage_view {
  sql_table_name: `sa-demo-agentic.auto_aftersales_data.service_parts_usage` ;;
  label: "Service Parts Usage & Core Returns"

  dimension: usage_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.usage_id ;;
  }

  dimension: service_order_id {
    type: string
    sql: ${TABLE}.service_order_id ;;
  }

  dimension: part_name {
    type: string
    sql: ${TABLE}.part_name ;;
  }

  dimension: defective_part_returned {
    type: yesno
    sql: ${TABLE}.defective_part_returned ;;
  }

  measure: total_replaced_parts_cost_usd {
    label: "Total Replaced Parts Cost (USD)"
    type: sum
    sql: ${TABLE}.extended_cost ;;
    value_format_name: usd
  }

  measure: unreturned_core_parts_cost_usd {
    label: "Unreturned Defective Core Parts Cost (USD)"
    type: sum
    sql: ${TABLE}.extended_cost ;;
    filters: [defective_part_returned: "no"]
    value_format_name: usd
  }
}

view: vehicle_sales_transactions_view {
  sql_table_name: `sa-demo-agentic.auto_sales_data.vehicle_sales_transactions` ;;
  label: "Vehicle Sales Transactions"

  dimension: transaction_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.transaction_id ;;
  }

  dimension: sale_id {
    type: number
    sql: ${TABLE}.sale_id ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.vin ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: vehicle_type {
    type: string
    sql: ${TABLE}.vehicle_type ;;
  }

  dimension: dealership {
    type: string
    sql: ${TABLE}.dealership ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}.payment_method ;;
  }

  measure: gross_retail_revenue_usd {
    label: "Gross Retail Revenue (USD)"
    type: sum
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
  }

  measure: realized_profit_margin_usd {
    label: "Realized Profit Margin (USD)"
    type: sum
    sql: ${TABLE}.profit_margin ;;
    value_format_name: usd
  }

  measure: realized_gross_margin_pct {
    label: "Realized Gross Margin (%)"
    type: number
    sql: SAFE_DIVIDE(${realized_profit_margin_usd}, ${gross_retail_revenue_usd}) * 100.0 ;;
    value_format_name: decimal_2
  }

  measure: avg_transaction_csat_rating {
    label: "Avg Transaction CSAT Rating"
    type: average
    sql: ${TABLE}.customer_rating ;;
    value_format_name: decimal_2
  }
}

view: dealership_profitability_view {
  sql_table_name: `sa-demo-agentic.auto_sales_data.dealership_profitability_metrics` ;;
  label: "Dealership Profitability Metrics"

  dimension: dealership {
    type: string
    sql: ${TABLE}.dealership ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  measure: dealership_net_profit_margin_pct {
    label: "Dealership Net Profit Margin (%)"
    type: average
    sql: ${TABLE}.profit_margin_pct ;;
    value_format_name: decimal_2
  }

  measure: dealership_total_profit_usd {
    label: "Dealership Total Gross Profit (USD)"
    type: sum
    sql: ${TABLE}.total_profit ;;
    value_format_name: usd
  }
}

view: quality_inspections_view {
  sql_table_name: `sa-demo-agentic.auto_manufacturing_data.quality_inspections` ;;
  label: "Manufacturing Quality Inspections"

  dimension: inspection_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.inspection_id ;;
  }

  dimension: part_name {
    type: string
    sql: ${TABLE}.part_name ;;
  }

  dimension: plant_id {
    type: number
    sql: ${TABLE}.plant_id ;;
  }

  measure: avg_lot_pass_rate_pct {
    label: "Avg Lot Pass Rate (%)"
    type: average
    sql: ${TABLE}.pass_rate_pct ;;
    value_format_name: decimal_2
  }

  measure: total_lot_defects {
    label: "Total Inspection Lot Defects"
    type: sum
    sql: ${TABLE}.defect_count ;;
  }
}


view: vehicle_ownership_view {
  sql_table_name: `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` ;;
  label: "Vehicle Ownership & Warranty Entitlement"

  dimension: vin {
    primary_key: yes
    type: string
    sql: ${TABLE}.vin ;;
    description: "Vehicle Identification Number (Primary Key)"
  }

  dimension: sale_id {
    type: number
    sql: ${TABLE}.sale_id ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: dealership {
    type: string
    sql: ${TABLE}.dealership ;;
  }

  dimension: build_plant_name {
    type: string
    sql: ${TABLE}.build_plant_name ;;
  }

  dimension: assembly_line_id {
    type: string
    sql: ${TABLE}.assembly_line_id ;;
  }

  dimension: household_id {
    type: string
    sql: ${TABLE}.household_id ;;
  }

  dimension: ownership_status {
    type: string
    sql: ${TABLE}.ownership_status ;;
  }

  dimension: extended_warranty_purchased {
    type: yesno
    sql: ${TABLE}.extended_warranty_purchased ;;
  }

  dimension: service_plan_tier {
    type: string
    sql: ${TABLE}.service_plan_tier ;;
  }

  measure: fleet_vehicle_count {
    label: "Active & Historical Fleet VIN Count"
    type: count
    description: "Total vehicles in the ownership registry"
  }

  measure: total_fleet_purchase_value_usd {
    label: "Total Fleet Purchase Value (USD)"
    type: sum
    sql: ${TABLE}.purchase_price ;;
    value_format_name: usd
  }

  measure: avg_annual_mileage_km {
    label: "Avg Annual Mileage (km)"
    type: average
    sql: ${TABLE}.annual_mileage_km ;;
    value_format_name: decimal_1
  }
}

view: recall_campaigns_view {
  sql_table_name: `sa-demo-agentic.auto_aftersales_data.recall_campaigns` ;;
  label: "NHTSA Recall Campaigns"

  dimension: recall_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.recall_id ;;
  }

  dimension: campaign_name {
    type: string
    sql: ${TABLE}.campaign_name ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: build_plant_name {
    type: string
    sql: ${TABLE}.build_plant_name ;;
  }

  dimension: part_name {
    type: string
    sql: ${TABLE}.part_name ;;
  }

  dimension: defect_category {
    type: string
    sql: ${TABLE}.defect_category ;;
  }

  dimension: severity {
    type: string
    sql: ${TABLE}.severity ;;
  }

  measure: total_estimated_recall_cost_usd {
    label: "Total Estimated Recall Exposure (USD)"
    type: sum
    sql: ${TABLE}.estimated_total_cost ;;
    value_format_name: usd
  }

  measure: total_affected_vins {
    label: "Total Recall Affected VINs"
    type: sum
    sql: ${TABLE}.affected_vin_count ;;
  }

  measure: avg_recall_completion_rate_pct {
    label: "Avg Recall Completion Rate (%)"
    type: average
    sql: ${TABLE}.completion_rate_pct ;;
    value_format_name: decimal_2
  }
}

view: customer_identity_crosswalk_view {
  sql_table_name: `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` ;;
  label: "Cross-Cloud Customer Identity Crosswalk"

  dimension: crosswalk_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.crosswalk_id ;;
  }

  dimension: transaction_id {
    type: number
    sql: ${TABLE}.transaction_id ;;
  }

  dimension: sale_id {
    type: number
    sql: ${TABLE}.sale_id ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.vin ;;
  }

  dimension: databricks_user_id {
    type: string
    sql: ${TABLE}.databricks_user_id ;;
  }

  dimension: household_id {
    type: string
    sql: ${TABLE}.household_id ;;
  }

  dimension: identity_provider {
    type: string
    sql: ${TABLE}.identity_provider ;;
  }

  measure: distinct_household_count {
    label: "Unique Purchasing Households"
    type: count_distinct
    sql: ${TABLE}.household_id ;;
  }

  measure: avg_identity_match_confidence {
    label: "Avg Cross-Cloud Match Confidence"
    type: average
    sql: ${TABLE}.match_confidence ;;
    value_format_name: decimal_4
  }
}

view: supplier_part_lineage_view {
  sql_table_name: `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` ;;
  label: "Multi-Tier Supplier BOM Lineage"

  dimension: lineage_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.lineage_id ;;
  }

  dimension: parent_part_name {
    type: string
    sql: ${TABLE}.parent_part_name ;;
  }

  dimension: child_part_name {
    type: string
    sql: ${TABLE}.child_part_name ;;
  }

  dimension: parent_supplier_plant {
    type: string
    sql: ${TABLE}.parent_supplier_plant ;;
  }

  dimension: child_supplier_plant {
    type: string
    sql: ${TABLE}.child_supplier_plant ;;
  }

  dimension: bom_tier_depth {
    type: number
    sql: ${TABLE}.bom_tier_depth ;;
  }

  dimension: is_safety_critical_subcomponent {
    type: yesno
    sql: ${TABLE}.is_safety_critical_subcomponent ;;
  }

  measure: avg_bom_contagion_risk_score {
    label: "Avg BOM Contagion Risk Score"
    type: average
    sql: ${TABLE}.contagion_risk_score ;;
    value_format_name: decimal_3
  }

  measure: avg_supplier_lead_time_days {
    label: "Avg Subcomponent Lead Time (Days)"
    type: average
    sql: ${TABLE}.lead_time_days ;;
    value_format_name: decimal_1
  }
}

view: v_semantic_aftersales_warranty_metrics_view {
  sql_table_name: `sa-demo-agentic.auto_aftersales_data.v_semantic_aftersales_warranty_metrics` ;;
  label: "Governed Semantic View: Aftersales Warranty & Supplier Chargeback"

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: dealership {
    type: string
    sql: ${TABLE}.dealership ;;
  }

  dimension: build_plant_name {
    type: string
    sql: ${TABLE}.build_plant_name ;;
  }

  dimension: part_source_plant_name {
    type: string
    sql: ${TABLE}.part_source_plant_name ;;
  }

  dimension: defect_category {
    type: string
    sql: ${TABLE}.defect_category ;;
  }

  dimension: claim_month {
    type: date
    sql: ${TABLE}.claim_month ;;
  }

  measure: realized_warranty_cost_usd {
    label: "Realized Warranty Cost (USD)"
    type: sum
    sql: ${TABLE}.realized_warranty_cost_usd ;;
    value_format_name: usd
  }

  measure: recoverable_supplier_chargeback_usd {
    label: "Recoverable Supplier Chargeback 70% (USD)"
    type: sum
    sql: ${TABLE}.recoverable_supplier_chargeback_usd ;;
    value_format_name: usd
  }

  measure: unrecovered_supplier_leakage_usd {
    label: "Unrecovered Supplier Core Leakage (USD)"
    type: sum
    sql: ${TABLE}.unrecovered_supplier_leakage_usd ;;
    value_format_name: usd
  }

  measure: net_oem_warranty_burden_usd {
    label: "Net OEM Warranty Burden (USD)"
    type: sum
    sql: ${TABLE}.net_oem_warranty_burden_usd ;;
    value_format_name: usd
  }

  measure: oem_warranty_service_absorption_usd {
    label: "OEM Service Bay Absorption (USD)"
    type: sum
    sql: ${TABLE}.oem_warranty_service_absorption_usd ;;
    value_format_name: usd
  }
}

view: v_semantic_sales_profitability_metrics_view {
  sql_table_name: `sa-demo-agentic.auto_sales_data.v_semantic_sales_profitability_metrics` ;;
  label: "Governed Semantic View: Commercial Sales & Dealership Profitability"

  dimension: dealership {
    type: string
    sql: ${TABLE}.dealership ;;
  }

  dimension: dealership_city {
    type: string
    sql: ${TABLE}.dealership_city ;;
  }

  dimension: dealership_state {
    type: string
    sql: ${TABLE}.dealership_state ;;
  }

  dimension: vehicle_type {
    type: string
    sql: ${TABLE}.vehicle_type ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: manufacturing_plant {
    type: string
    sql: ${TABLE}.manufacturing_plant ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}.payment_method ;;
  }

  measure: gross_retail_revenue_usd {
    label: "Gross Retail Revenue (USD)"
    type: sum
    sql: ${TABLE}.gross_retail_revenue_usd ;;
    value_format_name: usd
  }

  measure: realized_gross_margin_usd {
    label: "Realized Gross Margin (USD)"
    type: sum
    sql: ${TABLE}.realized_gross_margin_usd ;;
    value_format_name: usd
  }

  measure: unique_purchasing_households {
    label: "Verified Purchasing Households"
    type: sum
    sql: ${TABLE}.unique_purchasing_households ;;
  }
}

view: v_semantic_manufacturing_quality_metrics_view {
  sql_table_name: `sa-demo-agentic.auto_manufacturing_data.v_semantic_manufacturing_quality_metrics` ;;
  label: "Governed Semantic View: Manufacturing Quality & BOM Risk"

  dimension: plant_id {
    type: number
    sql: ${TABLE}.plant_id ;;
  }

  dimension: plant_name {
    type: string
    sql: ${TABLE}.plant_name ;;
  }

  dimension: plant_location {
    type: string
    sql: ${TABLE}.plant_location ;;
  }

  dimension: part_name {
    type: string
    sql: ${TABLE}.part_name ;;
  }

  measure: total_defect_count {
    label: "Total Inspection Defects"
    type: sum
    sql: ${TABLE}.total_defect_count ;;
  }

  measure: avg_lot_pass_rate_pct {
    label: "Avg Lot Pass Rate (%)"
    type: average
    sql: ${TABLE}.avg_lot_pass_rate_pct ;;
    value_format_name: decimal_2
  }

  measure: avg_bom_contagion_risk_score {
    label: "Avg BOM Contagion Risk Score"
    type: average
    sql: ${TABLE}.avg_bom_contagion_risk_score ;;
    value_format_name: decimal_3
  }
}
