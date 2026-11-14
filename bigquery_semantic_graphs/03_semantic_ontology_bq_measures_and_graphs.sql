-- Object: auto_aftersales_data.auto_enterprise_graph (us-central1)
CREATE OR REPLACE PROPERTY GRAPH `sa-demo-agentic.auto_aftersales_data.auto_enterprise_graph`
  NODE TABLES (
    `sa-demo-agentic.auto_manufacturing_data.plants` AS Plant
      KEY (plant_name)
      LABEL Plant PROPERTIES (
        plant_id,
        plant_name OPTIONS(description="Manufacturing or supplier facility name", synonyms=["facility", "factory"]),
        location OPTIONS(description="Geographic city and region of the plant"),
        capacity OPTIONS(description="Annual manufacturing capacity in units"),
        MEASURE(SUM(capacity)) AS total_plant_capacity OPTIONS(description="Total annual manufacturing capacity across plants", synonyms=["capacity_sum"]),
        MEASURE(COUNT(plant_id)) AS plant_count OPTIONS(description="Number of manufacturing or supplier plants")
      ),
    `sa-demo-agentic.auto_manufacturing_data.assembly_line_status` AS AssemblyLine
      KEY (line_id)
      LABEL AssemblyLine PROPERTIES (
        line_id,
        plant_name,
        status OPTIONS(description="Operational status of the assembly line"),
        daily_output OPTIONS(description="Daily vehicle assembly output"),
        MEASURE(SUM(daily_output)) AS total_daily_output OPTIONS(description="Total daily vehicle output across assembly lines", synonyms=["line_throughput"]),
        MEASURE(AVG(daily_output)) AS avg_daily_output OPTIONS(description="Average daily output per assembly line")
      ),
    `sa-demo-agentic.auto_manufacturing_data.parts_inventory` AS Part
      KEY (part_name)
      LABEL Part PROPERTIES (
        part_id,
        part_name OPTIONS(description="Canonical component or assembly part name"),
        quantity OPTIONS(description="On-hand inventory stock quantity"),
        plant_name,
        MEASURE(SUM(quantity)) AS total_inventory_quantity OPTIONS(description="Total on-hand part stock quantity", synonyms=["stock_on_hand"]),
        MEASURE(COUNT(part_id)) AS distinct_part_count OPTIONS(description="Count of distinct cataloged parts")
      ),
    `sa-demo-agentic.auto_manufacturing_data.quality_inspections` AS QualityInspection
      KEY (inspection_id)
      LABEL QualityInspection PROPERTIES (
        inspection_id,
        plant_id,
        part_name,
        inspect_date,
        defect_count OPTIONS(description="Defects detected in the inspection lot"),
        pass_rate_pct OPTIONS(description="Lot quality inspection pass rate percentage"),
        inspector_comments,
        MEASURE(SUM(defect_count)) AS total_inspection_defects OPTIONS(description="Total defects found across quality inspection lots", synonyms=["lot_defects"]),
        MEASURE(AVG(pass_rate_pct)) AS avg_lot_pass_rate_pct OPTIONS(description="Average quality inspection lot pass rate percentage", synonyms=["ftt_pass_rate"])
      ),
    `sa-demo-agentic.auto_sales_data.vehicle_models` AS VehicleModel
      KEY (model)
      LABEL VehicleModel PROPERTIES (
        model_id,
        model OPTIONS(description="Commercial vehicle model name"),
        vehicle_type OPTIONS(description="Vehicle body style or segment"),
        base_price OPTIONS(description="Base MSRP in USD"),
        MEASURE(AVG(base_price)) AS avg_model_base_msrp OPTIONS(description="Average base MSRP across vehicle models", synonyms=["avg_msrp"])
      ),
    `sa-demo-agentic.auto_sales_data.dealerships` AS Dealership
      KEY (dealership)
      LABEL Dealership PROPERTIES (
        dealership_id,
        dealership OPTIONS(description="Authorized retail dealership franchise name"),
        city,
        state,
        MEASURE(COUNT(dealership_id)) AS dealership_count OPTIONS(description="Number of retail dealerships")
      ),
    `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` AS CustomerIdentity
      KEY (crosswalk_id)
      LABEL CustomerIdentity PROPERTIES (
        crosswalk_id,
        databricks_user_id,
        transaction_id,
        sale_id,
        vin,
        customer_name,
        customer_email,
        household_id,
        identity_provider,
        match_confidence,
        match_method,
        MEASURE(AVG(match_confidence)) AS avg_identity_match_confidence OPTIONS(description="Average cross-cloud identity resolution match confidence"),
        MEASURE(COUNT(DISTINCT household_id)) AS distinct_household_count OPTIONS(description="Count of unique customer households")
      ),
    `sa-demo-agentic.auto_sales_data.customer_reviews` AS CustomerReview
      KEY (review_id)
      LABEL CustomerReview PROPERTIES (
        review_id,
        model,
        customer_rating OPTIONS(description="Post-sale customer star rating (1 to 5)"),
        feedback_category,
        review_date,
        comments,
        MEASURE(AVG(customer_rating)) AS avg_review_star_rating OPTIONS(description="Average post-sale customer satisfaction star rating", synonyms=["csat_rating"]),
        MEASURE(COUNT(review_id)) AS review_count OPTIONS(description="Total customer reviews submitted")
      ),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS Vehicle
      KEY (vin)
      LABEL Vehicle PROPERTIES (
        vin,
        sale_id,
        model,
        dealership,
        build_plant_name,
        assembly_line_id,
        household_id,
        ownership_start_date,
        purchase_price,
        warranty_months,
        warranty_end_date,
        extended_warranty_purchased,
        service_plan_tier,
        annual_mileage_km,
        ownership_status,
        MEASURE(COUNT(vin)) AS fleet_vehicle_count OPTIONS(description="Total vehicles in the active and historical fleet", synonyms=["vin_count"]),
        MEASURE(SUM(purchase_price)) AS total_fleet_purchase_value OPTIONS(description="Total retail purchase value of vehicles in fleet"),
        MEASURE(AVG(annual_mileage_km)) AS avg_annual_mileage_km OPTIONS(description="Average annual vehicle mileage in kilometers")
      ),
    `sa-demo-agentic.auto_aftersales_data.technicians` AS Technician
      KEY (technician_id)
      LABEL Technician PROPERTIES (
        technician_id,
        technician_name,
        dealership,
        certification_level,
        specialty,
        hire_date,
        hourly_rate,
        is_master_tech,
        MEASURE(AVG(hourly_rate)) AS avg_technician_hourly_rate OPTIONS(description="Average service technician hourly rate in USD"),
        MEASURE(COUNT(technician_id)) AS technician_headcount OPTIONS(description="Total certified service technicians")
      ),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS ServiceOrder
      KEY (service_order_id)
      LABEL ServiceOrder PROPERTIES (
        service_order_id,
        vin,
        model,
        dealership,
        build_plant_name,
        technician_id,
        service_date,
        service_type,
        service_channel,
        odometer_km,
        labor_hours,
        labor_cost,
        parts_cost,
        total_cost,
        customer_paid_amount,
        is_warranty_covered,
        days_in_shop,
        customer_satisfaction,
        MEASURE(SUM(total_cost)) AS total_service_order_cost OPTIONS(description="Total dealership service order cost (labor + parts)", synonyms=["ro_total_cost"]),
        MEASURE(SUM(customer_paid_amount)) AS total_customer_out_of_pocket OPTIONS(description="Total customer out-of-pocket amount paid on service orders"),
        MEASURE(AVG(days_in_shop)) AS avg_service_days_in_shop OPTIONS(description="Average vehicle turnaround days in shop", synonyms=["dwell_days"])
      ),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS WarrantyClaim
      KEY (claim_id)
      LABEL WarrantyClaim PROPERTIES (
        claim_id,
        service_order_id,
        vin,
        model,
        dealership,
        build_plant_name,
        part_name,
        part_source_plant_name,
        claim_date,
        months_in_service,
        failure_odometer_km,
        claim_amount,
        claim_status,
        defect_category,
        root_cause,
        supplier_fault,
        resolution_days,
        originating_service_type,
        MEASURE(SUM(claim_amount)) AS total_warranty_claim_amount OPTIONS(description="Total warranty claim spend in USD across claims", synonyms=["warranty_spend", "claim_cost"]),
        MEASURE(COUNT(claim_id)) AS warranty_claim_count OPTIONS(description="Total number of warranty claims filed"),
        MEASURE(AVG(resolution_days)) AS avg_claim_resolution_days OPTIONS(description="Average days to adjudicate and resolve a warranty claim")
      ),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallCampaign
      KEY (recall_id)
      LABEL RecallCampaign PROPERTIES (
        recall_id,
        campaign_name,
        model,
        build_plant_name,
        part_name,
        defect_category,
        severity,
        remedy_type,
        announced_date,
        affected_vin_count,
        completed_vin_count,
        completion_rate_pct,
        estimated_cost_per_vin,
        estimated_total_cost,
        MEASURE(SUM(estimated_total_cost)) AS total_estimated_recall_cost OPTIONS(description="Total estimated recall campaign financial exposure in USD"),
        MEASURE(SUM(affected_vin_count)) AS total_recall_affected_vins OPTIONS(description="Total VINs affected by safety recall campaigns"),
        MEASURE(AVG(completion_rate_pct)) AS avg_recall_completion_rate_pct OPTIONS(description="Average recall remedy completion percentage")
      )
  )
  EDGE TABLES (
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS VehicleBuiltAtPlant
      KEY (vin)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (build_plant_name) REFERENCES Plant (plant_name)
      LABEL BUILT_AT PROPERTIES (vin, build_plant_name, assembly_line_id, ownership_start_date),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS VehicleAssembledOnLine
      KEY (vin)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (assembly_line_id) REFERENCES AssemblyLine (line_id)
      LABEL ASSEMBLED_ON_LINE PROPERTIES (vin, assembly_line_id, build_plant_name),
    `sa-demo-agentic.auto_manufacturing_data.assembly_line_status` AS LineInPlant
      KEY (line_id)
      SOURCE KEY (line_id) REFERENCES AssemblyLine (line_id)
      DESTINATION KEY (plant_name) REFERENCES Plant (plant_name)
      LABEL LINE_IN_PLANT PROPERTIES (line_id, plant_name, status, daily_output),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS VehicleOfModel
      KEY (vin)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL OF_MODEL PROPERTIES (vin, model, purchase_price),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS VehicleSoldByDealership
      KEY (vin)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (dealership) REFERENCES Dealership (dealership)
      LABEL SOLD_BY PROPERTIES (vin, sale_id, dealership, ownership_start_date, purchase_price),
    `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` AS VehicleOwnedByCustomer
      KEY (crosswalk_id)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (crosswalk_id) REFERENCES CustomerIdentity (crosswalk_id)
      LABEL OWNED_BY_CUSTOMER PROPERTIES (crosswalk_id, vin, databricks_user_id, household_id, match_confidence),
    `sa-demo-agentic.auto_sales_data.customer_reviews` AS CustomerReviewedModel
      KEY (review_id)
      SOURCE KEY (review_id) REFERENCES CustomerReview (review_id)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL REVIEWED_MODEL PROPERTIES (review_id, model, customer_rating, feedback_category, review_date),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS VehicleServicedInOrder
      KEY (service_order_id)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      LABEL SERVICED_IN PROPERTIES (service_order_id, vin, service_date, service_type, odometer_km),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS OrderPerformedAtDealership
      KEY (service_order_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (dealership) REFERENCES Dealership (dealership)
      LABEL PERFORMED_AT PROPERTIES (service_order_id, dealership, service_date, total_cost),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS OrderHandledByTech
      KEY (service_order_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (technician_id) REFERENCES Technician (technician_id)
      LABEL HANDLED_BY PROPERTIES (service_order_id, technician_id, labor_hours, labor_cost),
    `sa-demo-agentic.auto_aftersales_data.technicians` AS DealershipEmploysTech
      KEY (technician_id)
      SOURCE KEY (dealership) REFERENCES Dealership (dealership)
      DESTINATION KEY (technician_id) REFERENCES Technician (technician_id)
      LABEL EMPLOYS PROPERTIES (dealership, technician_id, certification_level, specialty, is_master_tech),
    `sa-demo-agentic.auto_aftersales_data.service_parts_usage` AS OrderReplacedPart
      KEY (usage_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL REPLACED_PART PROPERTIES (
        usage_id, service_order_id, vin, part_name, part_source_plant_name,
        quantity_used, unit_cost, extended_cost, defective_part_returned, usage_date
      ),
    `sa-demo-agentic.auto_manufacturing_data.parts_inventory` AS PartManufacturedByPlant
      KEY (part_name)
      SOURCE KEY (part_name) REFERENCES Part (part_name)
      DESTINATION KEY (plant_name) REFERENCES Plant (plant_name)
      LABEL MANUFACTURED_BY_PLANT PROPERTIES (part_id, part_name, plant_name, quantity),
    `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` AS SubcomponentSuppliesPart
      KEY (lineage_id)
      SOURCE KEY (child_part_name) REFERENCES Part (part_name)
      DESTINATION KEY (parent_part_name) REFERENCES Part (part_name)
      LABEL SUPPLIES_SUBCOMPONENT PROPERTIES (
        lineage_id, child_part_name, parent_part_name, child_supplier_plant,
        parent_supplier_plant, bom_tier_depth, subcomponent_lot_id,
        lead_time_days, contagion_risk_score, is_safety_critical_subcomponent
      ),
    `sa-demo-agentic.auto_manufacturing_data.quality_inspections` AS InspectionTestedPart
      KEY (inspection_id)
      SOURCE KEY (inspection_id) REFERENCES QualityInspection (inspection_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL INSPECTED_PART PROPERTIES (inspection_id, part_name, plant_id, inspect_date, defect_count, pass_rate_pct),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS OrderGeneratedClaim
      KEY (claim_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (claim_id) REFERENCES WarrantyClaim (claim_id)
      LABEL GENERATED_CLAIM PROPERTIES (claim_id, service_order_id, claim_date, claim_amount, claim_status, supplier_fault),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS ClaimAgainstPart
      KEY (claim_id)
      SOURCE KEY (claim_id) REFERENCES WarrantyClaim (claim_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL CLAIM_AGAINST_PART PROPERTIES (claim_id, part_name, part_source_plant_name, defect_category, root_cause, supplier_fault),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallTargetsPart
      KEY (recall_id)
      SOURCE KEY (recall_id) REFERENCES RecallCampaign (recall_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL TARGETS_PART PROPERTIES (recall_id, campaign_name, part_name, severity, remedy_type),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallTargetsModel
      KEY (recall_id)
      SOURCE KEY (recall_id) REFERENCES RecallCampaign (recall_id)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL TARGETS_MODEL PROPERTIES (recall_id, campaign_name, model, severity, completion_rate_pct),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallOriginatedAtPlant
      KEY (recall_id)
      SOURCE KEY (recall_id) REFERENCES RecallCampaign (recall_id)
      DESTINATION KEY (build_plant_name) REFERENCES Plant (plant_name)
      LABEL ORIGINATED_AT_PLANT PROPERTIES (recall_id, campaign_name, build_plant_name, severity)
  );


-- Object: auto_sales_data.automotive_enterprise_graph (us-central1)
CREATE OR REPLACE PROPERTY GRAPH `sa-demo-agentic.auto_sales_data.automotive_enterprise_graph`
  NODE TABLES (
    `sa-demo-agentic.auto_manufacturing_data.plants` AS Plant
      KEY (plant_name)
      LABEL Plant PROPERTIES (
        plant_id,
        plant_name OPTIONS(description="Manufacturing or supplier facility name", synonyms=["facility", "factory"]),
        location OPTIONS(description="Geographic city and region of the plant"),
        capacity OPTIONS(description="Annual manufacturing capacity in units"),
        MEASURE(SUM(capacity)) AS total_plant_capacity OPTIONS(description="Total annual manufacturing capacity across plants", synonyms=["capacity_sum"]),
        MEASURE(COUNT(plant_id)) AS plant_count OPTIONS(description="Number of manufacturing or supplier plants")
      ),
    `sa-demo-agentic.auto_manufacturing_data.assembly_line_status` AS AssemblyLine
      KEY (line_id)
      LABEL AssemblyLine PROPERTIES (
        line_id,
        plant_name,
        status OPTIONS(description="Operational status of the assembly line"),
        daily_output OPTIONS(description="Daily vehicle assembly output"),
        MEASURE(SUM(daily_output)) AS total_daily_output OPTIONS(description="Total daily vehicle output across assembly lines", synonyms=["line_throughput"]),
        MEASURE(AVG(daily_output)) AS avg_daily_output OPTIONS(description="Average daily output per assembly line")
      ),
    `sa-demo-agentic.auto_manufacturing_data.parts_inventory` AS Part
      KEY (part_name)
      LABEL Part PROPERTIES (
        part_id,
        part_name OPTIONS(description="Canonical component or assembly part name"),
        quantity OPTIONS(description="On-hand inventory stock quantity"),
        plant_name,
        MEASURE(SUM(quantity)) AS total_inventory_quantity OPTIONS(description="Total on-hand part stock quantity", synonyms=["stock_on_hand"]),
        MEASURE(COUNT(part_id)) AS distinct_part_count OPTIONS(description="Count of distinct cataloged parts")
      ),
    `sa-demo-agentic.auto_manufacturing_data.quality_inspections` AS QualityInspection
      KEY (inspection_id)
      LABEL QualityInspection PROPERTIES (
        inspection_id,
        plant_id,
        part_name,
        inspect_date,
        defect_count OPTIONS(description="Defects detected in the inspection lot"),
        pass_rate_pct OPTIONS(description="Lot quality inspection pass rate percentage"),
        inspector_comments,
        MEASURE(SUM(defect_count)) AS total_inspection_defects OPTIONS(description="Total defects found across quality inspection lots", synonyms=["lot_defects"]),
        MEASURE(AVG(pass_rate_pct)) AS avg_lot_pass_rate_pct OPTIONS(description="Average quality inspection lot pass rate percentage", synonyms=["ftt_pass_rate"])
      ),
    `sa-demo-agentic.auto_sales_data.vehicle_models` AS VehicleModel
      KEY (model)
      LABEL VehicleModel PROPERTIES (
        model_id,
        model OPTIONS(description="Commercial vehicle model name"),
        vehicle_type OPTIONS(description="Vehicle body style or segment"),
        base_price OPTIONS(description="Base MSRP in USD"),
        MEASURE(AVG(base_price)) AS avg_model_base_msrp OPTIONS(description="Average base MSRP across vehicle models", synonyms=["avg_msrp"])
      ),
    `sa-demo-agentic.auto_sales_data.dealerships` AS Dealership
      KEY (dealership)
      LABEL Dealership PROPERTIES (
        dealership_id,
        dealership OPTIONS(description="Authorized retail dealership franchise name"),
        city,
        state,
        MEASURE(COUNT(dealership_id)) AS dealership_count OPTIONS(description="Number of retail dealerships")
      ),
    `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` AS CustomerIdentity
      KEY (crosswalk_id)
      LABEL CustomerIdentity PROPERTIES (
        crosswalk_id,
        databricks_user_id,
        transaction_id,
        sale_id,
        vin,
        customer_name,
        customer_email,
        household_id,
        identity_provider,
        match_confidence,
        match_method,
        MEASURE(AVG(match_confidence)) AS avg_identity_match_confidence OPTIONS(description="Average cross-cloud identity resolution match confidence"),
        MEASURE(COUNT(DISTINCT household_id)) AS distinct_household_count OPTIONS(description="Count of unique customer households")
      ),
    `sa-demo-agentic.auto_sales_data.customer_reviews` AS CustomerReview
      KEY (review_id)
      LABEL CustomerReview PROPERTIES (
        review_id,
        model,
        customer_rating OPTIONS(description="Post-sale customer star rating (1 to 5)"),
        feedback_category,
        review_date,
        comments,
        MEASURE(AVG(customer_rating)) AS avg_review_star_rating OPTIONS(description="Average post-sale customer satisfaction star rating", synonyms=["csat_rating"]),
        MEASURE(COUNT(review_id)) AS review_count OPTIONS(description="Total customer reviews submitted")
      ),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS Vehicle
      KEY (vin)
      LABEL Vehicle PROPERTIES (
        vin,
        sale_id,
        model,
        dealership,
        build_plant_name,
        assembly_line_id,
        household_id,
        ownership_start_date,
        purchase_price,
        warranty_months,
        warranty_end_date,
        extended_warranty_purchased,
        service_plan_tier,
        annual_mileage_km,
        ownership_status,
        MEASURE(COUNT(vin)) AS fleet_vehicle_count OPTIONS(description="Total vehicles in the active and historical fleet", synonyms=["vin_count"]),
        MEASURE(SUM(purchase_price)) AS total_fleet_purchase_value OPTIONS(description="Total retail purchase value of vehicles in fleet"),
        MEASURE(AVG(annual_mileage_km)) AS avg_annual_mileage_km OPTIONS(description="Average annual vehicle mileage in kilometers")
      ),
    `sa-demo-agentic.auto_aftersales_data.technicians` AS Technician
      KEY (technician_id)
      LABEL Technician PROPERTIES (
        technician_id,
        technician_name,
        dealership,
        certification_level,
        specialty,
        hire_date,
        hourly_rate,
        is_master_tech,
        MEASURE(AVG(hourly_rate)) AS avg_technician_hourly_rate OPTIONS(description="Average service technician hourly rate in USD"),
        MEASURE(COUNT(technician_id)) AS technician_headcount OPTIONS(description="Total certified service technicians")
      ),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS ServiceOrder
      KEY (service_order_id)
      LABEL ServiceOrder PROPERTIES (
        service_order_id,
        vin,
        model,
        dealership,
        build_plant_name,
        technician_id,
        service_date,
        service_type,
        service_channel,
        odometer_km,
        labor_hours,
        labor_cost,
        parts_cost,
        total_cost,
        customer_paid_amount,
        is_warranty_covered,
        days_in_shop,
        customer_satisfaction,
        MEASURE(SUM(total_cost)) AS total_service_order_cost OPTIONS(description="Total dealership service order cost (labor + parts)", synonyms=["ro_total_cost"]),
        MEASURE(SUM(customer_paid_amount)) AS total_customer_out_of_pocket OPTIONS(description="Total customer out-of-pocket amount paid on service orders"),
        MEASURE(AVG(days_in_shop)) AS avg_service_days_in_shop OPTIONS(description="Average vehicle turnaround days in shop", synonyms=["dwell_days"])
      ),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS WarrantyClaim
      KEY (claim_id)
      LABEL WarrantyClaim PROPERTIES (
        claim_id,
        service_order_id,
        vin,
        model,
        dealership,
        build_plant_name,
        part_name,
        part_source_plant_name,
        claim_date,
        months_in_service,
        failure_odometer_km,
        claim_amount,
        claim_status,
        defect_category,
        root_cause,
        supplier_fault,
        resolution_days,
        originating_service_type,
        MEASURE(SUM(claim_amount)) AS total_warranty_claim_amount OPTIONS(description="Total warranty claim spend in USD across claims", synonyms=["warranty_spend", "claim_cost"]),
        MEASURE(COUNT(claim_id)) AS warranty_claim_count OPTIONS(description="Total number of warranty claims filed"),
        MEASURE(AVG(resolution_days)) AS avg_claim_resolution_days OPTIONS(description="Average days to adjudicate and resolve a warranty claim")
      ),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallCampaign
      KEY (recall_id)
      LABEL RecallCampaign PROPERTIES (
        recall_id,
        campaign_name,
        model,
        build_plant_name,
        part_name,
        defect_category,
        severity,
        remedy_type,
        announced_date,
        affected_vin_count,
        completed_vin_count,
        completion_rate_pct,
        estimated_cost_per_vin,
        estimated_total_cost,
        MEASURE(SUM(estimated_total_cost)) AS total_estimated_recall_cost OPTIONS(description="Total estimated recall campaign financial exposure in USD"),
        MEASURE(SUM(affected_vin_count)) AS total_recall_affected_vins OPTIONS(description="Total VINs affected by safety recall campaigns"),
        MEASURE(AVG(completion_rate_pct)) AS avg_recall_completion_rate_pct OPTIONS(description="Average recall remedy completion percentage")
      )
  )
  EDGE TABLES (
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS VehicleBuiltAtPlant
      KEY (vin)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (build_plant_name) REFERENCES Plant (plant_name)
      LABEL BUILT_AT PROPERTIES (vin, build_plant_name, assembly_line_id, ownership_start_date),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS VehicleAssembledOnLine
      KEY (vin)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (assembly_line_id) REFERENCES AssemblyLine (line_id)
      LABEL ASSEMBLED_ON_LINE PROPERTIES (vin, assembly_line_id, build_plant_name),
    `sa-demo-agentic.auto_manufacturing_data.assembly_line_status` AS LineInPlant
      KEY (line_id)
      SOURCE KEY (line_id) REFERENCES AssemblyLine (line_id)
      DESTINATION KEY (plant_name) REFERENCES Plant (plant_name)
      LABEL LINE_IN_PLANT PROPERTIES (line_id, plant_name, status, daily_output),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS VehicleOfModel
      KEY (vin)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL OF_MODEL PROPERTIES (vin, model, purchase_price),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS VehicleSoldByDealership
      KEY (vin)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (dealership) REFERENCES Dealership (dealership)
      LABEL SOLD_BY PROPERTIES (vin, sale_id, dealership, ownership_start_date, purchase_price),
    `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` AS VehicleOwnedByCustomer
      KEY (crosswalk_id)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (crosswalk_id) REFERENCES CustomerIdentity (crosswalk_id)
      LABEL OWNED_BY_CUSTOMER PROPERTIES (crosswalk_id, vin, databricks_user_id, household_id, match_confidence),
    `sa-demo-agentic.auto_sales_data.customer_reviews` AS CustomerReviewedModel
      KEY (review_id)
      SOURCE KEY (review_id) REFERENCES CustomerReview (review_id)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL REVIEWED_MODEL PROPERTIES (review_id, model, customer_rating, feedback_category, review_date),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS VehicleServicedInOrder
      KEY (service_order_id)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      LABEL SERVICED_IN PROPERTIES (service_order_id, vin, service_date, service_type, odometer_km),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS OrderPerformedAtDealership
      KEY (service_order_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (dealership) REFERENCES Dealership (dealership)
      LABEL PERFORMED_AT PROPERTIES (service_order_id, dealership, service_date, total_cost),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS OrderHandledByTech
      KEY (service_order_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (technician_id) REFERENCES Technician (technician_id)
      LABEL HANDLED_BY PROPERTIES (service_order_id, technician_id, labor_hours, labor_cost),
    `sa-demo-agentic.auto_aftersales_data.technicians` AS DealershipEmploysTech
      KEY (technician_id)
      SOURCE KEY (dealership) REFERENCES Dealership (dealership)
      DESTINATION KEY (technician_id) REFERENCES Technician (technician_id)
      LABEL EMPLOYS PROPERTIES (dealership, technician_id, certification_level, specialty, is_master_tech),
    `sa-demo-agentic.auto_aftersales_data.service_parts_usage` AS OrderReplacedPart
      KEY (usage_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL REPLACED_PART PROPERTIES (
        usage_id, service_order_id, vin, part_name, part_source_plant_name,
        quantity_used, unit_cost, extended_cost, defective_part_returned, usage_date
      ),
    `sa-demo-agentic.auto_manufacturing_data.parts_inventory` AS PartManufacturedByPlant
      KEY (part_name)
      SOURCE KEY (part_name) REFERENCES Part (part_name)
      DESTINATION KEY (plant_name) REFERENCES Plant (plant_name)
      LABEL MANUFACTURED_BY_PLANT PROPERTIES (part_id, part_name, plant_name, quantity),
    `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` AS SubcomponentSuppliesPart
      KEY (lineage_id)
      SOURCE KEY (child_part_name) REFERENCES Part (part_name)
      DESTINATION KEY (parent_part_name) REFERENCES Part (part_name)
      LABEL SUPPLIES_SUBCOMPONENT PROPERTIES (
        lineage_id, child_part_name, parent_part_name, child_supplier_plant,
        parent_supplier_plant, bom_tier_depth, subcomponent_lot_id,
        lead_time_days, contagion_risk_score, is_safety_critical_subcomponent
      ),
    `sa-demo-agentic.auto_manufacturing_data.quality_inspections` AS InspectionTestedPart
      KEY (inspection_id)
      SOURCE KEY (inspection_id) REFERENCES QualityInspection (inspection_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL INSPECTED_PART PROPERTIES (inspection_id, part_name, plant_id, inspect_date, defect_count, pass_rate_pct),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS OrderGeneratedClaim
      KEY (claim_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (claim_id) REFERENCES WarrantyClaim (claim_id)
      LABEL GENERATED_CLAIM PROPERTIES (claim_id, service_order_id, claim_date, claim_amount, claim_status, supplier_fault),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS ClaimAgainstPart
      KEY (claim_id)
      SOURCE KEY (claim_id) REFERENCES WarrantyClaim (claim_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL CLAIM_AGAINST_PART PROPERTIES (claim_id, part_name, part_source_plant_name, defect_category, root_cause, supplier_fault),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallTargetsPart
      KEY (recall_id)
      SOURCE KEY (recall_id) REFERENCES RecallCampaign (recall_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL TARGETS_PART PROPERTIES (recall_id, campaign_name, part_name, severity, remedy_type),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallTargetsModel
      KEY (recall_id)
      SOURCE KEY (recall_id) REFERENCES RecallCampaign (recall_id)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL TARGETS_MODEL PROPERTIES (recall_id, campaign_name, model, severity, completion_rate_pct),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallOriginatedAtPlant
      KEY (recall_id)
      SOURCE KEY (recall_id) REFERENCES RecallCampaign (recall_id)
      DESTINATION KEY (build_plant_name) REFERENCES Plant (plant_name)
      LABEL ORIGINATED_AT_PLANT PROPERTIES (recall_id, campaign_name, build_plant_name, severity)
  );


-- Object: auto_aftersales_data.warranty_supplier_chargeback_graph (us-central1)
CREATE OR REPLACE PROPERTY GRAPH `sa-demo-agentic.auto_aftersales_data.warranty_supplier_chargeback_graph`
  NODE TABLES (
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS WarrantyClaim
      KEY (claim_id)
      LABEL WarrantyClaim PROPERTIES (
        claim_id,
        service_order_id,
        vin,
        model,
        dealership,
        build_plant_name,
        part_name,
        part_source_plant_name,
        claim_date,
        months_in_service,
        failure_odometer_km,
        claim_amount,
        claim_status,
        defect_category,
        root_cause,
        supplier_fault,
        resolution_days,
        originating_service_type,
        MEASURE(SUM(claim_amount)) AS total_claim_amount_usd OPTIONS(description="Total warranty claim amount in USD", synonyms=["claim_spend"]),
        MEASURE(COUNT(claim_id)) AS total_claims_count OPTIONS(description="Total warranty claims count"),
        MEASURE(AVG(resolution_days)) AS avg_adjudication_days OPTIONS(description="Average claim adjudication turnaround in days"),
        MEASURE(AVG(failure_odometer_km)) AS avg_failure_odometer_km OPTIONS(description="Average vehicle odometer reading at failure in km")
      ),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS ServiceOrder
      KEY (service_order_id)
      LABEL ServiceOrder PROPERTIES (
        service_order_id,
        vin,
        model,
        dealership,
        build_plant_name,
        technician_id,
        service_date,
        service_type,
        service_channel,
        odometer_km,
        labor_hours,
        labor_cost,
        parts_cost,
        total_cost,
        customer_paid_amount,
        is_warranty_covered,
        days_in_shop,
        customer_satisfaction,
        MEASURE(SUM(total_cost)) AS total_ro_cost_usd OPTIONS(description="Total repair order cost USD"),
        MEASURE(SUM(labor_cost)) AS total_labor_cost_usd OPTIONS(description="Total service bay labor cost USD"),
        MEASURE(SUM(parts_cost)) AS total_parts_cost_usd OPTIONS(description="Total replacement parts cost USD"),
        MEASURE(SUM(customer_paid_amount)) AS total_customer_paid_usd OPTIONS(description="Total out-of-pocket amount paid by customer USD"),
        MEASURE(AVG(labor_hours)) AS avg_labor_hours OPTIONS(description="Average labor hours per service order")
      ),
    `sa-demo-agentic.auto_aftersales_data.service_parts_usage` AS ServicePartUsage
      KEY (usage_id)
      LABEL ServicePartUsage PROPERTIES (
        usage_id,
        service_order_id,
        vin,
        part_name,
        part_source_plant_name,
        quantity_used,
        unit_cost,
        extended_cost,
        defective_part_returned,
        usage_date,
        MEASURE(SUM(extended_cost)) AS total_replaced_parts_spend_usd OPTIONS(description="Total extended cost of parts replaced in service orders", synonyms=["part_replacement_spend"]),
        MEASURE(SUM(quantity_used)) AS total_parts_quantity_replaced OPTIONS(description="Total units of replacement parts consumed"),
        MEASURE(COUNT(usage_id)) AS part_replacement_line_count OPTIONS(description="Count of part replacement line items")
      ),
    `sa-demo-agentic.auto_aftersales_data.technicians` AS Technician
      KEY (technician_id)
      LABEL Technician PROPERTIES (
        technician_id,
        technician_name,
        dealership,
        certification_level,
        specialty,
        hire_date,
        hourly_rate,
        is_master_tech,
        MEASURE(AVG(hourly_rate)) AS avg_tech_hourly_rate OPTIONS(description="Average technician hourly rate USD")
      ),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallCampaign
      KEY (recall_id)
      LABEL RecallCampaign PROPERTIES (
        recall_id,
        campaign_name,
        model,
        build_plant_name,
        part_name,
        defect_category,
        severity,
        remedy_type,
        announced_date,
        affected_vin_count,
        completed_vin_count,
        completion_rate_pct,
        estimated_cost_per_vin,
        estimated_total_cost,
        MEASURE(SUM(estimated_total_cost)) AS total_recall_campaign_budget_usd OPTIONS(description="Total estimated recall campaign cost USD"),
        MEASURE(AVG(completion_rate_pct)) AS avg_recall_remedy_completion_pct OPTIONS(description="Average recall completion rate percentage")
      ),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS Vehicle
      KEY (vin)
      LABEL Vehicle PROPERTIES (
        vin,
        sale_id,
        model,
        dealership,
        build_plant_name,
        assembly_line_id,
        household_id,
        ownership_start_date,
        purchase_price,
        warranty_months,
        warranty_end_date,
        extended_warranty_purchased,
        service_plan_tier,
        annual_mileage_km,
        ownership_status,
        MEASURE(COUNT(vin)) AS entitled_vehicle_count OPTIONS(description="Count of vehicles in ownership registry")
      ),
    `sa-demo-agentic.auto_manufacturing_data.parts_inventory` AS Part
      KEY (part_name)
      LABEL Part PROPERTIES (
        part_id,
        part_name,
        quantity,
        plant_name
      ),
    `sa-demo-agentic.auto_manufacturing_data.plants` AS SupplierPlant
      KEY (plant_name)
      LABEL SupplierPlant PROPERTIES (
        plant_id,
        plant_name,
        location,
        capacity
      )
  )
  EDGE TABLES (
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS ClaimForServiceOrder
      KEY (claim_id)
      SOURCE KEY (claim_id) REFERENCES WarrantyClaim (claim_id)
      DESTINATION KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      LABEL CLAIM_FOR_ORDER PROPERTIES (claim_id, service_order_id, claim_amount, claim_status, supplier_fault),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS ClaimOnVehicle
      KEY (claim_id)
      SOURCE KEY (claim_id) REFERENCES WarrantyClaim (claim_id)
      DESTINATION KEY (vin) REFERENCES Vehicle (vin)
      LABEL CLAIM_ON_VIN PROPERTIES (claim_id, vin, months_in_service, failure_odometer_km),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS ClaimAgainstDefectivePart
      KEY (claim_id)
      SOURCE KEY (claim_id) REFERENCES WarrantyClaim (claim_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL CLAIM_AGAINST_PART PROPERTIES (claim_id, part_name, defect_category, root_cause, supplier_fault),
    `sa-demo-agentic.auto_aftersales_data.warranty_claims` AS ClaimChargedToSupplierPlant
      KEY (claim_id)
      SOURCE KEY (claim_id) REFERENCES WarrantyClaim (claim_id)
      DESTINATION KEY (part_source_plant_name) REFERENCES SupplierPlant (plant_name)
      LABEL CHARGED_TO_SUPPLIER_PLANT PROPERTIES (claim_id, part_source_plant_name, claim_amount, supplier_fault),
    `sa-demo-agentic.auto_aftersales_data.service_parts_usage` AS OrderConsumedPartUsage
      KEY (usage_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (usage_id) REFERENCES ServicePartUsage (usage_id)
      LABEL CONSUMED_PART_LINE PROPERTIES (usage_id, service_order_id, defective_part_returned, extended_cost),
    `sa-demo-agentic.auto_aftersales_data.service_parts_usage` AS PartUsageReferencesPart
      KEY (usage_id)
      SOURCE KEY (usage_id) REFERENCES ServicePartUsage (usage_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL USAGE_OF_PART PROPERTIES (usage_id, part_name, quantity_used, unit_cost, defective_part_returned),
    `sa-demo-agentic.auto_aftersales_data.service_parts_usage` AS PartUsageFromSupplierPlant
      KEY (usage_id)
      SOURCE KEY (usage_id) REFERENCES ServicePartUsage (usage_id)
      DESTINATION KEY (part_source_plant_name) REFERENCES SupplierPlant (plant_name)
      LABEL SOURCED_FROM_SUPPLIER_PLANT PROPERTIES (usage_id, part_source_plant_name, defective_part_returned, extended_cost),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS OrderHandledByTechnician
      KEY (service_order_id)
      SOURCE KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      DESTINATION KEY (technician_id) REFERENCES Technician (technician_id)
      LABEL HANDLED_BY_TECH PROPERTIES (service_order_id, technician_id, labor_hours, labor_cost),
    `sa-demo-agentic.auto_aftersales_data.service_orders` AS VehicleServicedInOrder
      KEY (service_order_id)
      SOURCE KEY (vin) REFERENCES Vehicle (vin)
      DESTINATION KEY (service_order_id) REFERENCES ServiceOrder (service_order_id)
      LABEL SERVICED_IN_ORDER PROPERTIES (service_order_id, vin, service_date, service_type, is_warranty_covered),
    `sa-demo-agentic.auto_aftersales_data.recall_campaigns` AS RecallTargetsDefectivePart
      KEY (recall_id)
      SOURCE KEY (recall_id) REFERENCES RecallCampaign (recall_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL RECALL_TARGETS_PART PROPERTIES (recall_id, campaign_name, part_name, severity, remedy_type),
    `sa-demo-agentic.auto_manufacturing_data.parts_inventory` AS PartProducedAtSupplierPlant
      KEY (part_name)
      SOURCE KEY (part_name) REFERENCES Part (part_name)
      DESTINATION KEY (plant_name) REFERENCES SupplierPlant (plant_name)
      LABEL PRODUCED_AT_PLANT PROPERTIES (part_id, part_name, plant_name, quantity)
  );


-- Object: auto_sales_data.commercial_revenue_loyalty_graph (us-central1)
CREATE OR REPLACE PROPERTY GRAPH `sa-demo-agentic.auto_sales_data.commercial_revenue_loyalty_graph`
  NODE TABLES (
    `sa-demo-agentic.auto_sales_data.dealerships` AS Dealership
      KEY (dealership)
      LABEL Dealership PROPERTIES (
        dealership_id,
        dealership OPTIONS(description="Authorized dealership franchise name"),
        city,
        state,
        MEASURE(COUNT(dealership_id)) AS dealership_franchise_count OPTIONS(description="Count of dealership franchises")
      ),
    `sa-demo-agentic.auto_sales_data.dealership_profitability_metrics` AS DealershipProfitability
      KEY (dealership, model)
      LABEL DealershipProfitability PROPERTIES (
        dealership,
        dealership_city,
        dealership_state,
        model,
        total_units_sold,
        avg_production_cost,
        avg_sale_price,
        total_revenue,
        total_profit,
        profit_margin_pct,
        avg_customer_rating,
        MEASURE(SUM(total_revenue)) AS sum_dealership_revenue_usd OPTIONS(description="Total dealership revenue USD across models", synonyms=["dealer_revenue"]),
        MEASURE(SUM(total_profit)) AS sum_dealership_gross_profit_usd OPTIONS(description="Total dealership gross profit USD", synonyms=["dealer_profit"]),
        MEASURE(SUM(total_units_sold)) AS sum_dealership_units_sold OPTIONS(description="Total retail vehicle units sold by dealership"),
        MEASURE(AVG(profit_margin_pct)) AS avg_dealership_profit_margin_pct OPTIONS(description="Average dealership net profit margin percentage")
      ),
    `sa-demo-agentic.auto_sales_data.vehicle_models` AS VehicleModel
      KEY (model)
      LABEL VehicleModel PROPERTIES (
        model_id,
        model,
        vehicle_type,
        base_price,
        MEASURE(AVG(base_price)) AS avg_catalog_msrp_usd OPTIONS(description="Average vehicle catalog base MSRP in USD")
      ),
    `sa-demo-agentic.auto_sales_data.vehicle_sales` AS VehicleSale
      KEY (sale_id)
      LABEL VehicleSale PROPERTIES (
        sale_id,
        model,
        dealership,
        sale_price,
        sale_date,
        MEASURE(SUM(sale_price)) AS total_retail_sales_usd OPTIONS(description="Total retail vehicle sales revenue in USD", synonyms=["gross_sales_revenue"]),
        MEASURE(AVG(sale_price)) AS avg_retail_sale_price_usd OPTIONS(description="Average retail vehicle transaction price in USD"),
        MEASURE(COUNT(sale_id)) AS retail_sale_count OPTIONS(description="Total count of retail vehicle sales")
      ),
    `sa-demo-agentic.auto_sales_data.vehicle_sales_transactions` AS SalesTransaction
      KEY (transaction_id)
      LABEL SalesTransaction PROPERTIES (
        transaction_id,
        sale_id,
        vin,
        model,
        vehicle_type,
        dealership,
        dealership_city,
        dealership_state,
        manufacturing_plant,
        plant_location,
        assembly_line_id,
        production_cost,
        sale_price,
        profit_margin,
        transaction_date,
        payment_method,
        customer_rating,
        warranty_plan,
        MEASURE(SUM(sale_price)) AS total_transaction_gross_usd OPTIONS(description="Total settled sales transaction revenue USD"),
        MEASURE(SUM(production_cost)) AS total_vehicle_production_cost_usd OPTIONS(description="Total OEM manufacturing cost of sold vehicles USD"),
        MEASURE(SUM(profit_margin)) AS total_transaction_profit_margin_usd OPTIONS(description="Total realized profit margin USD across transactions", synonyms=["realized_margin_usd"]),
        MEASURE(AVG(customer_rating)) AS avg_transaction_csat_rating OPTIONS(description="Average customer rating recorded at transaction settlement")
      ),
    `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` AS CustomerIdentity
      KEY (crosswalk_id)
      LABEL CustomerIdentity PROPERTIES (
        crosswalk_id,
        databricks_user_id,
        transaction_id,
        sale_id,
        vin,
        customer_name,
        customer_email,
        customer_phone,
        postal_code,
        household_id,
        identity_provider,
        match_confidence,
        match_method,
        cross_cloud_origin,
        MEASURE(AVG(match_confidence)) AS avg_cross_cloud_match_confidence OPTIONS(description="Average identity resolution confidence across GCP and Databricks CRM"),
        MEASURE(COUNT(DISTINCT household_id)) AS unique_customer_households OPTIONS(description="Count of distinct purchasing households")
      ),
    `sa-demo-agentic.auto_sales_data.customer_reviews` AS CustomerReview
      KEY (review_id)
      LABEL CustomerReview PROPERTIES (
        review_id,
        model,
        customer_rating,
        feedback_category,
        review_date,
        comments,
        MEASURE(AVG(customer_rating)) AS avg_nps_review_rating OPTIONS(description="Average post-purchase review rating")
      ),
    `sa-demo-agentic.auto_aftersales_data.vehicle_ownership` AS Vehicle
      KEY (vin)
      LABEL Vehicle PROPERTIES (
        vin,
        sale_id,
        model,
        dealership,
        build_plant_name,
        household_id,
        purchase_price,
        extended_warranty_purchased,
        service_plan_tier,
        ownership_status
      ),
    `sa-demo-agentic.auto_manufacturing_data.plants` AS Plant
      KEY (plant_name)
      LABEL Plant PROPERTIES (
        plant_id,
        plant_name,
        location,
        capacity
      )
  )
  EDGE TABLES (
    `sa-demo-agentic.auto_sales_data.vehicle_sales` AS SaleAtDealership
      KEY (sale_id)
      SOURCE KEY (sale_id) REFERENCES VehicleSale (sale_id)
      DESTINATION KEY (dealership) REFERENCES Dealership (dealership)
      LABEL SALE_AT_DEALERSHIP PROPERTIES (sale_id, dealership, sale_price, sale_date),
    `sa-demo-agentic.auto_sales_data.vehicle_sales` AS SaleOfVehicleModel
      KEY (sale_id)
      SOURCE KEY (sale_id) REFERENCES VehicleSale (sale_id)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL SALE_OF_MODEL PROPERTIES (sale_id, model, sale_price, sale_date),
    `sa-demo-agentic.auto_sales_data.vehicle_sales_transactions` AS TransactionForSale
      KEY (transaction_id)
      SOURCE KEY (transaction_id) REFERENCES SalesTransaction (transaction_id)
      DESTINATION KEY (sale_id) REFERENCES VehicleSale (sale_id)
      LABEL SETTLES_SALE PROPERTIES (transaction_id, sale_id, payment_method, profit_margin, warranty_plan),
    `sa-demo-agentic.auto_sales_data.vehicle_sales_transactions` AS TransactionForVehicle
      KEY (transaction_id)
      SOURCE KEY (transaction_id) REFERENCES SalesTransaction (transaction_id)
      DESTINATION KEY (vin) REFERENCES Vehicle (vin)
      LABEL TRANSACTED_VIN PROPERTIES (transaction_id, vin, sale_price, production_cost, profit_margin),
    `sa-demo-agentic.auto_sales_data.vehicle_sales_transactions` AS TransactionBuiltAtPlant
      KEY (transaction_id)
      SOURCE KEY (transaction_id) REFERENCES SalesTransaction (transaction_id)
      DESTINATION KEY (manufacturing_plant) REFERENCES Plant (plant_name)
      LABEL BUILT_AT_MANUFACTURING_PLANT PROPERTIES (transaction_id, manufacturing_plant, production_cost),
    `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` AS IdentityLinkedToTransaction
      KEY (crosswalk_id)
      SOURCE KEY (crosswalk_id) REFERENCES CustomerIdentity (crosswalk_id)
      DESTINATION KEY (transaction_id) REFERENCES SalesTransaction (transaction_id)
      LABEL COMPLETED_TRANSACTION PROPERTIES (crosswalk_id, transaction_id, databricks_user_id, match_confidence),
    `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` AS IdentityLinkedToSale
      KEY (crosswalk_id)
      SOURCE KEY (crosswalk_id) REFERENCES CustomerIdentity (crosswalk_id)
      DESTINATION KEY (sale_id) REFERENCES VehicleSale (sale_id)
      LABEL PURCHASED_IN_SALE PROPERTIES (crosswalk_id, sale_id, household_id, identity_provider),
    `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` AS IdentityOwnsVehicle
      KEY (crosswalk_id)
      SOURCE KEY (crosswalk_id) REFERENCES CustomerIdentity (crosswalk_id)
      DESTINATION KEY (vin) REFERENCES Vehicle (vin)
      LABEL OWNS_VEHICLE_VIN PROPERTIES (crosswalk_id, vin, household_id, match_method),
    `sa-demo-agentic.auto_sales_data.dealership_profitability_metrics` AS DealershipModelProfitabilityEdge
      KEY (dealership, model)
      SOURCE KEY (dealership, model) REFERENCES DealershipProfitability (dealership, model)
      DESTINATION KEY (dealership) REFERENCES Dealership (dealership)
      LABEL PROFITABILITY_FOR_DEALERSHIP PROPERTIES (dealership, model, total_revenue, total_profit, profit_margin_pct),
    `sa-demo-agentic.auto_sales_data.dealership_profitability_metrics` AS ProfitabilityForVehicleModel
      KEY (dealership, model)
      SOURCE KEY (dealership, model) REFERENCES DealershipProfitability (dealership, model)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL PROFITABILITY_BY_MODEL PROPERTIES (dealership, model, total_units_sold, avg_sale_price, profit_margin_pct),
    `sa-demo-agentic.auto_sales_data.customer_reviews` AS ReviewTargetsVehicleModel
      KEY (review_id)
      SOURCE KEY (review_id) REFERENCES CustomerReview (review_id)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL REVIEWS_MODEL PROPERTIES (review_id, model, customer_rating, feedback_category)
  );


-- Object: auto_manufacturing_data.supply_chain_bom_quality_graph (us-central1)
CREATE OR REPLACE PROPERTY GRAPH `sa-demo-agentic.auto_manufacturing_data.supply_chain_bom_quality_graph`
  NODE TABLES (
    `sa-demo-agentic.auto_manufacturing_data.plants` AS Plant
      KEY (plant_name)
      LABEL Plant PROPERTIES (
        plant_id,
        plant_name,
        location,
        capacity,
        MEASURE(SUM(capacity)) AS total_facility_capacity OPTIONS(description="Total annual production capacity across facilities"),
        MEASURE(COUNT(plant_id)) AS facility_count OPTIONS(description="Count of manufacturing and supplier plants")
      ),
    `sa-demo-agentic.auto_manufacturing_data.assembly_line_status` AS AssemblyLine
      KEY (line_id)
      LABEL AssemblyLine PROPERTIES (
        line_id,
        plant_name,
        status,
        daily_output,
        MEASURE(SUM(daily_output)) AS total_line_daily_output OPTIONS(description="Total daily vehicle output across assembly lines"),
        MEASURE(AVG(daily_output)) AS avg_line_daily_output OPTIONS(description="Average daily vehicle output per line")
      ),
    `sa-demo-agentic.auto_manufacturing_data.parts_inventory` AS Part
      KEY (part_name)
      LABEL Part PROPERTIES (
        part_id,
        part_name,
        quantity,
        plant_name,
        MEASURE(SUM(quantity)) AS total_part_inventory_units OPTIONS(description="Total on-hand inventory units across parts")
      ),
    `sa-demo-agentic.auto_manufacturing_data.quality_inspections` AS QualityInspection
      KEY (inspection_id)
      LABEL QualityInspection PROPERTIES (
        inspection_id,
        plant_id,
        part_name,
        inspect_date,
        defect_count,
        pass_rate_pct,
        inspector_comments,
        MEASURE(SUM(defect_count)) AS total_lot_defects OPTIONS(description="Total defects detected across quality inspection lots"),
        MEASURE(AVG(pass_rate_pct)) AS avg_inspection_pass_rate_pct OPTIONS(description="Average lot inspection pass rate percentage")
      ),
    `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` AS SupplierBomLineage
      KEY (lineage_id)
      LABEL SupplierBomLineage PROPERTIES (
        lineage_id,
        parent_part_name,
        child_part_name,
        parent_supplier_plant,
        child_supplier_plant,
        bom_tier_depth,
        subcomponent_lot_id,
        lead_time_days,
        contagion_risk_score,
        is_safety_critical_subcomponent,
        MEASURE(AVG(lead_time_days)) AS avg_supplier_lead_time_days OPTIONS(description="Average subcomponent supply lead time in days"),
        MEASURE(AVG(contagion_risk_score)) AS avg_bom_contagion_risk_score OPTIONS(description="Average supply-chain contagion risk score"),
        MEASURE(MAX(bom_tier_depth)) AS max_bom_tier_depth OPTIONS(description="Maximum N-tier BOM depth")
      )
  )
  EDGE TABLES (
    `sa-demo-agentic.auto_manufacturing_data.assembly_line_status` AS LineOperatesInPlant
      KEY (line_id)
      SOURCE KEY (line_id) REFERENCES AssemblyLine (line_id)
      DESTINATION KEY (plant_name) REFERENCES Plant (plant_name)
      LABEL OPERATES_IN_PLANT PROPERTIES (line_id, plant_name, status, daily_output),
    `sa-demo-agentic.auto_manufacturing_data.parts_inventory` AS PartManufacturedAtPlant
      KEY (part_name)
      SOURCE KEY (part_name) REFERENCES Part (part_name)
      DESTINATION KEY (plant_name) REFERENCES Plant (plant_name)
      LABEL MANUFACTURED_AT_PLANT PROPERTIES (part_id, part_name, plant_name, quantity),
    `sa-demo-agentic.auto_manufacturing_data.quality_inspections` AS InspectionEvaluatedPart
      KEY (inspection_id)
      SOURCE KEY (inspection_id) REFERENCES QualityInspection (inspection_id)
      DESTINATION KEY (part_name) REFERENCES Part (part_name)
      LABEL EVALUATED_PART PROPERTIES (inspection_id, part_name, defect_count, pass_rate_pct),
    `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` AS ChildSubcomponentToParentPart
      KEY (lineage_id)
      SOURCE KEY (child_part_name) REFERENCES Part (part_name)
      DESTINATION KEY (parent_part_name) REFERENCES Part (part_name)
      LABEL SUPPLIES_SUBCOMPONENT_TO PROPERTIES (lineage_id, child_part_name, parent_part_name, bom_tier_depth, contagion_risk_score, is_safety_critical_subcomponent),
    `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` AS BomNodeFromChildPart
      KEY (lineage_id)
      SOURCE KEY (lineage_id) REFERENCES SupplierBomLineage (lineage_id)
      DESTINATION KEY (child_part_name) REFERENCES Part (part_name)
      LABEL HAS_CHILD_SUBCOMPONENT PROPERTIES (lineage_id, child_part_name, subcomponent_lot_id),
    `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` AS BomNodeToParentAssembly
      KEY (lineage_id)
      SOURCE KEY (lineage_id) REFERENCES SupplierBomLineage (lineage_id)
      DESTINATION KEY (parent_part_name) REFERENCES Part (part_name)
      LABEL FEEDS_PARENT_ASSEMBLY PROPERTIES (lineage_id, parent_part_name, bom_tier_depth),
    `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` AS BomNodeSourcedFromSupplierPlant
      KEY (lineage_id)
      SOURCE KEY (lineage_id) REFERENCES SupplierBomLineage (lineage_id)
      DESTINATION KEY (child_supplier_plant) REFERENCES Plant (plant_name)
      LABEL SOURCED_FROM_TIER_PLANT PROPERTIES (lineage_id, child_supplier_plant, lead_time_days)
  );


-- Object: auto_sales_lakehouse.cross_cloud_lakehouse_graph (us-east4)
CREATE OR REPLACE PROPERTY GRAPH `sa-demo-agentic.auto_sales_lakehouse.cross_cloud_lakehouse_graph`
  NODE TABLES (
    `sa-demo-agentic.auto_sales_lakehouse.dealerships` AS Dealership
      KEY (dealership)
      LABEL Dealership PROPERTIES (
        dealership_id,
        dealership,
        city,
        state,
        MEASURE(COUNT(dealership_id)) AS lakehouse_dealership_count OPTIONS(description="Count of dealerships in cross-cloud lakehouse")
      ),
    `sa-demo-agentic.auto_sales_lakehouse.dealership_profitability_metrics` AS DealershipProfitability
      KEY (dealership, model)
      LABEL DealershipProfitability PROPERTIES (
        dealership,
        dealership_city,
        dealership_state,
        model,
        total_units_sold,
        avg_production_cost,
        avg_sale_price,
        total_revenue,
        total_profit,
        profit_margin_pct,
        avg_customer_rating,
        MEASURE(SUM(total_revenue)) AS lakehouse_total_revenue_usd OPTIONS(description="Total dealership revenue USD in lakehouse"),
        MEASURE(SUM(total_profit)) AS lakehouse_total_profit_usd OPTIONS(description="Total dealership profit USD in lakehouse"),
        MEASURE(AVG(profit_margin_pct)) AS lakehouse_avg_profit_margin_pct OPTIONS(description="Average dealership profit margin percentage in lakehouse")
      ),
    `sa-demo-agentic.auto_sales_lakehouse.vehicle_models` AS VehicleModel
      KEY (model)
      LABEL VehicleModel PROPERTIES (
        model_id,
        model,
        vehicle_type,
        base_price,
        MEASURE(AVG(base_price)) AS lakehouse_avg_base_msrp_usd OPTIONS(description="Average base MSRP USD in lakehouse")
      ),
    `sa-demo-agentic.auto_sales_lakehouse.vehicle_sales` AS VehicleSale
      KEY (sale_id)
      LABEL VehicleSale PROPERTIES (
        sale_id,
        model,
        dealership,
        sale_price,
        sale_date,
        MEASURE(SUM(sale_price)) AS lakehouse_sales_volume_usd OPTIONS(description="Total vehicle sales USD in lakehouse"),
        MEASURE(COUNT(sale_id)) AS lakehouse_sales_count OPTIONS(description="Count of vehicle sales in lakehouse")
      ),
    `sa-demo-agentic.auto_sales_lakehouse.vehicle_sales_transactions` AS SalesTransaction
      KEY (transaction_id)
      LABEL SalesTransaction PROPERTIES (
        transaction_id,
        sale_id,
        vin,
        model,
        vehicle_type,
        dealership,
        manufacturing_plant,
        production_cost,
        sale_price,
        profit_margin,
        transaction_date,
        payment_method,
        customer_rating,
        warranty_plan,
        MEASURE(SUM(sale_price)) AS lakehouse_txn_revenue_usd OPTIONS(description="Total transaction revenue USD"),
        MEASURE(SUM(profit_margin)) AS lakehouse_txn_margin_usd OPTIONS(description="Total transaction profit margin USD"),
        MEASURE(AVG(customer_rating)) AS lakehouse_avg_txn_rating OPTIONS(description="Average transaction customer rating")
      ),
    `sa-demo-agentic.auto_sales_lakehouse.customer_identity_crosswalk` AS CustomerIdentity
      KEY (crosswalk_id)
      LABEL CustomerIdentity PROPERTIES (
        crosswalk_id,
        databricks_user_id,
        transaction_id,
        sale_id,
        vin,
        customer_name,
        customer_email,
        household_id,
        identity_provider,
        match_confidence,
        match_method,
        cross_cloud_origin,
        MEASURE(AVG(match_confidence)) AS lakehouse_avg_match_confidence OPTIONS(description="Average cross-cloud identity match confidence"),
        MEASURE(COUNT(DISTINCT databricks_user_id)) AS linked_databricks_users OPTIONS(description="Count of distinct linked AWS Databricks CRM users")
      )
  )
  EDGE TABLES (
    `sa-demo-agentic.auto_sales_lakehouse.vehicle_sales` AS LakehouseSaleAtDealership
      KEY (sale_id)
      SOURCE KEY (sale_id) REFERENCES VehicleSale (sale_id)
      DESTINATION KEY (dealership) REFERENCES Dealership (dealership)
      LABEL SALE_AT_DEALERSHIP PROPERTIES (sale_id, dealership, sale_price),
    `sa-demo-agentic.auto_sales_lakehouse.vehicle_sales` AS LakehouseSaleOfModel
      KEY (sale_id)
      SOURCE KEY (sale_id) REFERENCES VehicleSale (sale_id)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL SALE_OF_MODEL PROPERTIES (sale_id, model, sale_price),
    `sa-demo-agentic.auto_sales_lakehouse.vehicle_sales_transactions` AS LakehouseTxnForSale
      KEY (transaction_id)
      SOURCE KEY (transaction_id) REFERENCES SalesTransaction (transaction_id)
      DESTINATION KEY (sale_id) REFERENCES VehicleSale (sale_id)
      LABEL SETTLES_SALE PROPERTIES (transaction_id, sale_id, payment_method, profit_margin),
    `sa-demo-agentic.auto_sales_lakehouse.customer_identity_crosswalk` AS LakehouseIdentityToTxn
      KEY (crosswalk_id)
      SOURCE KEY (crosswalk_id) REFERENCES CustomerIdentity (crosswalk_id)
      DESTINATION KEY (transaction_id) REFERENCES SalesTransaction (transaction_id)
      LABEL COMPLETED_TRANSACTION PROPERTIES (crosswalk_id, transaction_id, databricks_user_id, match_confidence),
    `sa-demo-agentic.auto_sales_lakehouse.customer_identity_crosswalk` AS LakehouseIdentityToSale
      KEY (crosswalk_id)
      SOURCE KEY (crosswalk_id) REFERENCES CustomerIdentity (crosswalk_id)
      DESTINATION KEY (sale_id) REFERENCES VehicleSale (sale_id)
      LABEL PURCHASED_IN_SALE PROPERTIES (crosswalk_id, sale_id, household_id),
    `sa-demo-agentic.auto_sales_lakehouse.dealership_profitability_metrics` AS LakehouseDealerProfitability
      KEY (dealership, model)
      SOURCE KEY (dealership, model) REFERENCES DealershipProfitability (dealership, model)
      DESTINATION KEY (dealership) REFERENCES Dealership (dealership)
      LABEL PROFITABILITY_FOR_DEALERSHIP PROPERTIES (dealership, model, total_revenue, total_profit),
    `sa-demo-agentic.auto_sales_lakehouse.dealership_profitability_metrics` AS LakehouseModelProfitability
      KEY (dealership, model)
      SOURCE KEY (dealership, model) REFERENCES DealershipProfitability (dealership, model)
      DESTINATION KEY (model) REFERENCES VehicleModel (model)
      LABEL PROFITABILITY_BY_MODEL PROPERTIES (dealership, model, total_units_sold, profit_margin_pct)
  );


-- Object: auto_aftersales_data.v_semantic_aftersales_warranty_metrics (us-central1)
CREATE OR REPLACE VIEW `sa-demo-agentic.auto_aftersales_data.v_semantic_aftersales_warranty_metrics`
OPTIONS(
  description="Governed Semantic Ontology Metric View for Automotive Aftersales & Warranty: exposes additive measures and derived ratio KPIs (Realized Warranty Cost, Recoverable Supplier Chargeback 70%, Unrecovered Core-Return Leakage, Net OEM Warranty Burden, and OEM Service Bay Absorption) by model, dealership, build_plant_name, and part_source_plant_name."
) AS
WITH order_core_returns AS (
  SELECT
    service_order_id,
    LOGICAL_AND(defective_part_returned) AS all_cores_returned,
    SUM(extended_cost) AS replaced_parts_extended_cost,
    SUM(quantity_used) AS replaced_parts_qty
  FROM `sa-demo-agentic.auto_aftersales_data.service_parts_usage`
  GROUP BY service_order_id
)
SELECT
  wc.model,
  wc.dealership,
  wc.build_plant_name,
  wc.part_source_plant_name,
  wc.defect_category,
  DATE_TRUNC(wc.claim_date, MONTH) AS claim_month,
  COUNT(DISTINCT wc.claim_id) AS total_claims_filed,
  COUNT(DISTINCT IF(wc.claim_status = 'Approved', wc.claim_id, NULL)) AS approved_claim_count,
  ROUND(SUM(IF(wc.claim_status = 'Approved', wc.claim_amount, 0)), 2) AS realized_warranty_cost_usd,
  ROUND(SUM(IF(wc.claim_status = 'Approved' AND wc.supplier_fault = TRUE AND COALESCE(ocr.all_cores_returned, FALSE) = TRUE, wc.claim_amount * 0.70, 0)), 2) AS recoverable_supplier_chargeback_usd,
  ROUND(SUM(IF(wc.claim_status = 'Approved' AND wc.supplier_fault = TRUE AND COALESCE(ocr.all_cores_returned, FALSE) = FALSE, wc.claim_amount * 0.70, 0)), 2) AS unrecovered_supplier_leakage_usd,
  ROUND(
    SUM(IF(wc.claim_status = 'Approved', wc.claim_amount, 0))
    - SUM(IF(wc.claim_status = 'Approved' AND wc.supplier_fault = TRUE AND COALESCE(ocr.all_cores_returned, FALSE) = TRUE, wc.claim_amount * 0.70, 0)),
    2
  ) AS net_oem_warranty_burden_usd,
  ROUND(SUM(IF(so.is_warranty_covered = TRUE, so.total_cost - so.customer_paid_amount, 0)), 2) AS oem_warranty_service_absorption_usd,
  ROUND(AVG(wc.resolution_days), 2) AS avg_claim_resolution_days
FROM `sa-demo-agentic.auto_aftersales_data.warranty_claims` wc
LEFT JOIN `sa-demo-agentic.auto_aftersales_data.service_orders` so
  ON wc.service_order_id = so.service_order_id
LEFT JOIN order_core_returns ocr
  ON wc.service_order_id = ocr.service_order_id
GROUP BY 1, 2, 3, 4, 5, 6;


-- Object: auto_sales_data.v_semantic_sales_profitability_metrics (us-central1)
CREATE OR REPLACE VIEW `sa-demo-agentic.auto_sales_data.v_semantic_sales_profitability_metrics`
OPTIONS(
  description="Governed Semantic Ontology Metric View for Automotive Commercial Sales & Loyalty: exposes Gross Retail Revenue, Total Production Cost, Realized Gross Margin, MSRP Price Realization Ratio, Cross-Cloud Verified Identity Rate, and Post-Sale CSAT by dealership, state, vehicle_type, model, and transaction_month."
) AS
SELECT
  t.dealership,
  t.dealership_city,
  t.dealership_state,
  t.vehicle_type,
  t.model,
  t.manufacturing_plant,
  t.payment_method,
  DATE_TRUNC(t.transaction_date, MONTH) AS transaction_month,
  COUNT(DISTINCT t.transaction_id) AS settled_transaction_count,
  COUNT(DISTINCT ci.household_id) AS unique_purchasing_households,
  ROUND(SUM(t.sale_price), 2) AS gross_retail_revenue_usd,
  ROUND(SUM(t.production_cost), 2) AS total_production_cost_usd,
  ROUND(SUM(t.profit_margin), 2) AS realized_gross_margin_usd,
  ROUND(SAFE_DIVIDE(SUM(t.profit_margin), SUM(t.sale_price)) * 100, 2) AS realized_gross_margin_pct,
  ROUND(SAFE_DIVIDE(AVG(t.sale_price), AVG(vm.base_price)) * 100, 2) AS msrp_price_realization_pct,
  ROUND(AVG(t.customer_rating), 2) AS avg_transaction_csat_score,
  ROUND(AVG(ci.match_confidence), 4) AS avg_identity_match_confidence
FROM `sa-demo-agentic.auto_sales_data.vehicle_sales_transactions` t
LEFT JOIN `sa-demo-agentic.auto_sales_data.vehicle_models` vm
  ON t.model = vm.model
LEFT JOIN `sa-demo-agentic.auto_sales_data.customer_identity_crosswalk` ci
  ON t.transaction_id = ci.transaction_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8;


-- Object: auto_manufacturing_data.v_semantic_manufacturing_quality_metrics (us-central1)
CREATE OR REPLACE VIEW `sa-demo-agentic.auto_manufacturing_data.v_semantic_manufacturing_quality_metrics`
OPTIONS(
  description="Governed Semantic Ontology Metric View for Automotive Manufacturing & Multi-Tier BOM Quality: exposes Lot Pass Rate, Total Defects, On-Hand Component Stock, Safety-Critical Subcomponent Contagion Risk, and Supplier Lead Time by plant_name and part_name."
) AS
SELECT
  p.plant_id,
  p.plant_name,
  p.location AS plant_location,
  p.capacity AS annual_plant_capacity,
  pi.part_name,
  pi.quantity AS on_hand_inventory_qty,
  COUNT(DISTINCT qi.inspection_id) AS inspection_lot_count,
  SUM(COALESCE(qi.defect_count, 0)) AS total_defect_count,
  ROUND(AVG(qi.pass_rate_pct), 2) AS avg_lot_pass_rate_pct,
  COUNT(DISTINCT spl.lineage_id) AS bom_subcomponent_links,
  ROUND(AVG(spl.contagion_risk_score), 3) AS avg_bom_contagion_risk_score,
  ROUND(AVG(spl.lead_time_days), 1) AS avg_subcomponent_lead_time_days
FROM `sa-demo-agentic.auto_manufacturing_data.parts_inventory` pi
INNER JOIN `sa-demo-agentic.auto_manufacturing_data.plants` p
  ON pi.plant_name = p.plant_name
LEFT JOIN `sa-demo-agentic.auto_manufacturing_data.quality_inspections` qi
  ON pi.part_name = qi.part_name
LEFT JOIN `sa-demo-agentic.auto_manufacturing_data.supplier_part_lineage` spl
  ON pi.part_name = spl.parent_part_name
GROUP BY 1, 2, 3, 4, 5, 6;
