semantic_model: automotive_enterprise_ontology {
  display_name: "Automotive Enterprise Unified Semantic Ontology (BQ Measures, dbt MetricFlow, LookML)"
  description: "Unified Semantic Ontology spanning auto_aftersales_data, auto_sales_data, and auto_manufacturing_data in sa-demo-agentic"

  source: src_warranty_claims {
    table: bigquery:sa-demo-agentic.auto_aftersales_data.warranty_claims ;;
  }
  source: src_service_orders {
    table: bigquery:sa-demo-agentic.auto_aftersales_data.service_orders ;;
  }
  source: src_service_parts_usage {
    table: bigquery:sa-demo-agentic.auto_aftersales_data.service_parts_usage ;;
  }
  source: src_sales_transactions {
    table: bigquery:sa-demo-agentic.auto_sales_data.vehicle_sales_transactions ;;
  }
  source: src_dealership_profitability {
    table: bigquery:sa-demo-agentic.auto_sales_data.dealership_profitability_metrics ;;
  }
  source: src_quality_inspections {
    table: bigquery:sa-demo-agentic.auto_manufacturing_data.quality_inspections ;;
  }

  entity: warranty_claims {
    source: src_warranty_claims
    field: claim_id { type: string expression: { field: claim_id } }
    field: service_order_id { type: string expression: { field: service_order_id } }
    field: vin { type: string expression: { field: vin } }
    field: part_name { type: string expression: { field: part_name } }
    field: claim_status { type: string expression: { field: claim_status } }
    field: supplier_fault { type: boolean expression: { field: supplier_fault } }
    field: claim_amount { type: number expression: { field: claim_amount } }
    field: resolution_days { type: number expression: { field: resolution_days } }
  }

  entity: service_orders {
    source: src_service_orders
    field: service_order_id { type: string expression: { field: service_order_id } }
    field: vin { type: string expression: { field: vin } }
    field: dealership { type: string expression: { field: dealership } }
    field: total_cost { type: number expression: { field: total_cost } }
    field: customer_paid_amount { type: number expression: { field: customer_paid_amount } }
    field: is_warranty_covered { type: boolean expression: { field: is_warranty_covered } }
  }

  entity: sales_transactions {
    source: src_sales_transactions
    field: transaction_id { type: number expression: { field: transaction_id } }
    field: sale_id { type: number expression: { field: sale_id } }
    field: vin { type: string expression: { field: vin } }
    field: dealership { type: string expression: { field: dealership } }
    field: model { type: string expression: { field: model } }
    field: sale_price { type: number expression: { field: sale_price } }
    field: profit_margin { type: number expression: { field: profit_margin } }
  }

  metric: realized_warranty_cost_usd {
    entity: warranty_claims
    kind: sum
    description: "Approved warranty claim spend: SUM(claim_amount) WHERE claim_status = 'Approved'"
    expression: {
      value_sql: claim_amount
      filter_sql: claim_status = 'Approved'
    }
  }

  metric: oem_warranty_service_absorption_usd {
    entity: service_orders
    kind: sum
    description: "Total dealership repair cost absorbed by the OEM on warranty-covered repair orders"
    expression: {
      value_sql: total_cost - customer_paid_amount
      filter_sql: is_warranty_covered = TRUE
    }
  }

  metric: gross_retail_sales_revenue_usd {
    entity: sales_transactions
    kind: sum
    description: "Total settled retail vehicle sales revenue in USD"
    expression: {
      value_sql: sale_price
    }
  }

  metric: realized_vehicle_profit_margin_usd {
    entity: sales_transactions
    kind: sum
    description: "Total realized gross margin across retail vehicle transactions in USD"
    expression: {
      value_sql: profit_margin
    }
  }
}
