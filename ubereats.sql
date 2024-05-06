#
SELECT * FROM arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours LIMIT 10;

#extracting the hours from response column
 
WITH schedule_rules as(
  select 
  json_extract_scalar(value, '$.from') as start_time,
  json_extract_scalar(value, '$.to') as end_time,
  from `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`,
  unnest(json_extract_array(response,'$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules')) as value
)

select start_time, end_time from schedule_rules;
