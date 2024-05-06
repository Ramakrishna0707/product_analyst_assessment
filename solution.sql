WITH grubhub_hours AS (
  SELECT
    JSON_EXTRACT_SCALAR(response, '$.slug') AS gh_slug,
    JSON_EXTRACT(response, '$.openHours') AS gh_open_hours
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`
),
ubereats_hours AS (
  SELECT
    JSON_EXTRACT_SCALAR(response, '$.slug') AS ue_slug,
    JSON_EXTRACT(response, '$.openHours') AS ue_open_hours
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours`
),
hours_joined AS (
  SELECT
    gh_slug,
    gh_open_hours,
    ue_slug,
    ue_open_hours
  FROM grubhub_hours
  JOIN ubereats_hours
    ON JSON_EXTRACT_SCALAR(gh_open_hours, '$[0]') = ue_slug
)
SELECT
  gh_slug,
  JSON_EXTRACT_SCALAR(gh_open_hours, '$[0]') AS gh_open_hours_string,
  ue_slug,
  JSON_EXTRACT_SCALAR(ue_open_hours, '$[1]') AS ue_start_time,
  JSON_EXTRACT_SCALAR(ue_open_hours, '$[2]') AS ue_end_time,
  CASE
    WHEN PARSE_TIMESTAMP('%I:%M %p', JSON_EXTRACT_SCALAR(gh_open_hours, '$[1]'))
      BETWEEN PARSE_TIMESTAMP('%I:%M %p', JSON_EXTRACT_SCALAR(ue_open_hours, '$[1]'))
      AND PARSE_TIMESTAMP('%I:%M %p', JSON_EXTRACT_SCALAR(ue_open_hours, '$[2]'))
    THEN "In Range"
    WHEN ABS(TIMESTAMP_DIFF(
      PARSE_TIMESTAMP('%I:%M %p', JSON_EXTRACT_SCALAR(gh_open_hours, '$[1]')),
      PARSE_TIMESTAMP('%I:%M %p', JSON_EXTRACT_SCALAR(ue_open_hours, '$[1]')),
      MINUTE)) < 5
    THEN "Out of Range with 5 mins difference"
    ELSE "Out of Range"
  END AS is_out_of_range
FROM hours_joined

