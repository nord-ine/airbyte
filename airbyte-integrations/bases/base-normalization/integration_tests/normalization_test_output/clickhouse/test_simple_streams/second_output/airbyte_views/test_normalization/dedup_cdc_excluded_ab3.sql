

  create view _airbyte_test_normalization.dedup_cdc_excluded_ab3__dbt_tmp 
  
  as (
    
with __dbt__cte__dedup_cdc_excluded_ab1 as (

-- SQL model to parse JSON blob stored in a single column and extract into separated field columns as described by the JSON Schema
select
    JSONExtractRaw(_airbyte_data, 'id') as id,
    JSONExtractRaw(_airbyte_data, 'name') as name,
    JSONExtractRaw(_airbyte_data, '_ab_cdc_lsn') as _ab_cdc_lsn,
    JSONExtractRaw(_airbyte_data, '_ab_cdc_updated_at') as _ab_cdc_updated_at,
    JSONExtractRaw(_airbyte_data, '_ab_cdc_deleted_at') as _ab_cdc_deleted_at,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    now() as _airbyte_normalized_at
from test_normalization._airbyte_raw_dedup_cdc_excluded as table_alias
-- dedup_cdc_excluded
where 1 = 1

),  __dbt__cte__dedup_cdc_excluded_ab2 as (

-- SQL model to cast each column to its adequate SQL type converted from the JSON schema type
select
    accurateCastOrNull(id, '
    BIGINT
') as id,
    nullif(accurateCastOrNull(trim(BOTH '"' from name), 'String'), 'null') as name,
    accurateCastOrNull(_ab_cdc_lsn, '
    Float64
') as _ab_cdc_lsn,
    accurateCastOrNull(_ab_cdc_updated_at, '
    Float64
') as _ab_cdc_updated_at,
    accurateCastOrNull(_ab_cdc_deleted_at, '
    Float64
') as _ab_cdc_deleted_at,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    now() as _airbyte_normalized_at
from __dbt__cte__dedup_cdc_excluded_ab1
-- dedup_cdc_excluded
where 1 = 1

)-- SQL model to build a hash column based on the values of this record
select
    assumeNotNull(hex(MD5(
            
                toString(id) || '~' ||
            
            
                toString(name) || '~' ||
            
            
                toString(_ab_cdc_lsn) || '~' ||
            
            
                toString(_ab_cdc_updated_at) || '~' ||
            
            
                toString(_ab_cdc_deleted_at)
            
    ))) as _airbyte_dedup_cdc_excluded_hashid,
    tmp.*
from __dbt__cte__dedup_cdc_excluded_ab2 tmp
-- dedup_cdc_excluded
where 1 = 1

  )