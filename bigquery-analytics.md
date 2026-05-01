# BigQuery: structure and workflows for agents

This note is written for tooling and engineers who reason across the meta-repo: which **Google Cloud BigQuery** resources exist, how they relate to application code, and how to confirm schemas with the **`bq`** CLI.

## Critical distinction: BigQuery versus PostgreSQL

The platform uses a PostgreSQL schema named `events` (see `alove-docs/db-schema/05_events_tables.sql`) for transactional data such as `events.match_scores` and `events.comm_logs`.

**Those PostgreSQL tables are not BigQuery tables.** Queries that need matching scores belong on Postgres (RDS), not on `mujual.events.*` in BigQuery.

Use BigQuery mainly for:

- Firebase / app analytics aggregates (datasets under GCP project **`mujual`**).
- Firebase Crashlytics export (typically dataset **`firebase_crashlytics`**).
- Operational reporting and analytics in **`mujual.events`**: `events_grouped_daily`, `events_summary`, `profile_events`, `profile_events_grouped`, `profile_summary`.

When in doubt: check where the code constructs the query. If it uses `@google-cloud/bigquery` with `projectId: 'mujual'` or the `bq` tool against project `mujual`, it is BigQuery.

## GCP project and datasets (canonical)

| Resource | Typical value | Notes |
|----------|---------------|--------|
| GCP project | `mujual` | Used by `backoffice_backend` `BigQueryService` and Crashlytics scripts defaults. |
| Analytics dataset | `events` | Tables below; all are in project **`mujual`**. |
| Crashlytics export | `firebase_crashlytics` | Firebase-linked export; app tables often follow Crashlytics naming (e.g. wildcard `com_algoai_*` in tooling). |

Full table IDs use the form **`mujual.<dataset>.<table>`**. In SQL, quote project-qualified names with backticks: `` `mujual.events.events_grouped_daily` ``.

## Dataset `events` — tables and partitioning

These objects live in **`mujual.events`**. Partitioning influences how you filter (always constrain the partition column when possible).

| Table | Partition field | Grain |
|-------|-----------------|--------|
| `events_grouped_daily` | `ts` (DATE) | DAY |
| `events_summary` | `day` (DATE) | DAY |
| `profile_events` | `ts` (TIMESTAMP) | DAY |
| `profile_events_grouped` | `ts` (TIMESTAMP) | DAY |
| `profile_summary` | `month` (DATE) | MONTH |

Refresh schemas anytime (authoritative):

```bash
bq show --schema --format=prettyjson "mujual:events.<TABLE_ID>"
bq show --format=prettyjson "mujual:events.<TABLE_ID>"   # includes timePartitioning
```

Below, **mode** is BigQuery column mode (`NULLABLE`, `REQUIRED`). Types are as reported by **`bq show`**.

### Ingest lineage (how `profile_events` is shaped)

End-user and server code emit **`AnalyticsEvent`** payloads. The profile API accepts batches via `kinesisEventsCollector`, merges client fields, and **`logEvent`** writes JSON to **Kinesis** (`SINK_KINESIS_STREAM_NAME`). A **downstream analytics pipeline** (not in this meta-repo) lands rows into BigQuery.

Canonical field names and meanings match `AnalyticsEvent.toJson()`:

```112:132:jlov-backend/infra-lib/src/model/dto/anlyticsEvent.ts
    toJson(){
        return {
            ver: this.version,
            eid: this.eventId,
            ts: this.timestamp,
            ccg: this.clientClockGap,
            ctz: this.clientTimeZone,
            lts: this.serverTimestamp,
            ip: this.ipAddress,
            src: this.source || "s",
            pid: this.profileId,
            et: this.eventType,
            ext: this.eventPayload,
            srcd: this.sourceDevice,
            bid: this.brandId,
            cmp: this.completedAt,
            sid: this.sessionId,
            p1: this.param1,
            p2: this.param2,
            p3: this.param3
        }
    }
```

- **`ver`**: schema version for the event envelope (currently **1** in constructors).
- **`eid`**: unique id for **this** event row (UUID), not the business “introduction id” etc.
- **`ts`**: client **event time**; **`lts`**: **server** receive/processing time (API path uses gateway timing; server-originated events use `new Date()` for both in the DTO).
- **`ccg` / `ctz`**: **client clock gap** (ms-style skew signal) and **client time zone offset** (`clientClockGap`, `clientTimeZone`); often `0` when unset.
- **`ip`**: source IP captured on the API (**`169.254.*`** often appears from internal/Lambda hops—treat as infrastructure artifact unless correlated with CDN logs).
- **`src`**: who produced the row; defaults to **`"s"`** (“server”) when `source` is empty (many backend-emitted analytics events).
- **`srcd`**: **source device** metadata from the mobile client (`sourceDevice`), JSON when present.
- **`ext`**: **payload JSON** beyond `p1`–`p3` (e.g. full `matchServiceResponse` structure with `info_code`, `profile_id`, arrays).
- **`cmp`**: **completed-at** timestamp for flows that define it (questionnaires/long tasks); otherwise null.
- **`sid`**: **session id** when the client sends it.
- **`p1`–`p3`**: mapped from **`eventNames[eventType]`** in the same file—order matches the BI catalog (`system-prompt-bigquery.txt`). Nullable when the event has no mapped params.

`events_grouped_daily`, `profile_events_grouped`, `events_summary`, and `profile_summary` are **derived** in BigQuery or adjacent jobs from this stream (exact jobs: use GCP Data Transfer / Composer / Scheduled Queries in console, or ask infra).

---

### Sample rows (live preview, project `mujual`)

Examples below were produced with **`bq query`** against production. Re-run anytime; values illustrate shape, not fixed constants.

**`events_grouped_daily`** (recent days; brand-level totals):

```json
[
  {"ts":"2026-04-30","et":"appLifecycleState","p1":"hidden","p2":null,"p3":null,"count":"80","bid":"103"},
  {"ts":"2026-04-30","et":"appLifecycleState","p1":"inactive","p2":null,"p3":null,"count":"99","bid":"103"},
  {"ts":"2026-04-30","et":"appLifecycleState","p1":"hidden","p2":null,"p3":null,"count":"1084","bid":"102"}
]
```

Interpretation: one row per **(day, brand, event type, p1,p2,p3)**; **`appLifecycleState`** uses **`p1`** for lifecycle state (`hidden`, `inactive`, …). Counts can be large (aggregate across all profiles).

**`events_summary`** (`report_name` = template key; `report_key` = breakdown dimension):

```json
[
  {"version":"1","day":"2026-04-30","report_name":"introStatusUpdated","report_key":"2","report_value":"10","bid":"102"},
  {"version":"1","day":"2026-04-30","report_name":"introStatusUpdated","report_key":"3","report_value":"10","bid":"102"},
  {"version":"1","day":"2026-04-30","report_name":"introStatusUpdated","report_key":"10","report_value":"12","bid":"102"}
]
```

Interpretation: **`introStatusUpdated`** rows bucket by **`report_key`** (stringified introduction status dimension used in dashboards). **`report_value`** is numeric but typed as **`STRING`** in the table—**cast explicitly** (`SAFE_CAST(report_value AS INT64)`).

**`profile_events`** (raw rows; `ext` abbreviated in prose):

```json
[
  {
    "ver":"1",
    "eid":"bd54eb06-6fd4-4415-a395-4494da535a1c",
    "ts":"2026-05-01 08:58:21",
    "pid":"7d7740b0-64b5-40f3-91f4-6cbea50bf49f",
    "bid":"102",
    "et":"matchServiceResponse",
    "src":"s",
    "ccg":"0","ctz":"0",
    "lts":"2026-05-01 08:58:21",
    "ip":"169.254.100.6",
    "ext":"{\"id\":\"3868fff8-...\",\"info_code\":206,\"info_message\":\"No matching partners - bio/prefs\",...}"
  }
]
```

Interpretation: server-side **`matchServiceResponse`** with structured **`ext`**; **`p1`–`p3`** null because this event uses only payload JSON. Inspect **`ext`** for API codes and messages.

**`profile_events_grouped`**:

```json
[
  {"et":"appLifecycleState","pid":"b01161a7-14b1-4a2e-87ac-9a3fa4c8f95b","ts":"2026-04-01 00:00:00","bid":"102","p1":"hidden","p2":null,"p3":null,"count":"41"}
]
```

Interpretation: same logical dimensions as **`events_grouped_daily`**, but **`pid`** is present—counts are **per profile per bucket**.

**Freshness caveat (important for tag rules):** At last check, **`profile_events`** extended to **current** timestamps while **`profile_events_grouped` `MAX(ts)`** lagged (**e.g.** last bucket **2026-04-01** vs raw events **2026-05-01**). If tag rules appear “empty,” validate that the grouped ETL job is healthy and widen `WHERE ts >= …` accordingly for historical analysis.

**`profile_summary`**:

```json
[
  {
    "version":"1",
    "report_name":"ctategory_clicks",
    "profile_id":"0246f835-5d90-4766-93fe-a5ad22a2e402",
    "key":"familySettings",
    "value":"1",
    "month":"2026-05-01"
  }
]
```

Interpretation: **`profile_id`** + **`month`** grain; **`key`** names a **dimension inside the report** (here, Me/settings category identifiers such as `familySettings`, `educationSettings`). **`value`** is an integer metric (often “count” or intensity). Stored **`report_name`** may include historical typos (**`ctategory_clicks`**)—query with tolerant filters or **`LIKE`** if dashboards break.

Copy-paste preview pattern:

```sql
SELECT * FROM `mujual.events.profile_events`
WHERE ts >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
ORDER BY ts DESC LIMIT 5;
```

---

### `events_grouped_daily`

Brand-level counts per calendar day and event-parameter tuple (no profile id). Rolled up from analytics stream for dashboards and AI reports.

| Column | Mode | Type | Notes |
|--------|------|------|--------|
| `ts` | NULLABLE | DATE | Partition **day**; filter with `DATE` predicates |
| `et` | NULLABLE | STRING | Event type; allowed names align with **`system-prompt-bigquery.txt`** |
| `p1`, `p2`, `p3` | NULLABLE | STRING | Same mapping as **`AnalyticsEvent`** param slots for `et` |
| `count` | NULLABLE | INTEGER | Aggregated occurrences for `(ts, et, p1, p2, p3, bid)` |
| `bid` | NULLABLE | NUMERIC | Brand id (**NUMERIC**, not INTEGER—use literals or `CAST(:brandId AS NUMERIC)` in strict SQL if needed) |

**Used in repo:** AI BigQuery reports via `BigQueryService.runRawQuery()` on `` `events.events_grouped_daily` `` (placeholders `:brandId`, `:fromDate`, `:toDate`).

### `events_summary`

Long-running **timeline** extracts: one blob per **`report_name`** per **`day`**, subdivided by **`report_key`** (series).

| Column | Mode | Type | Notes |
|--------|------|------|--------|
| `version` | REQUIRED | INTEGER | Summary row envelope version (**1** in samples); bump if semantics change |
| `day` | REQUIRED | DATE | Partition date |
| `report_name` | REQUIRED | STRING | Same string as **`ReportTemplate.eventName`** / **`reportTemplate.eventName`** in backoffice |
| `report_key` | REQUIRED | STRING | Discrete bucket (status id, segment id, variant, etc.—always compare as string unless you KNOW it’s numeric) |
| `report_value` | NULLABLE | STRING | **Metric serialized as text** (`"10"`); **always `SAFE_CAST`** for math |
| `bid` | NULLABLE | INTEGER | Brand id |

**Used in repo:** `BigQueryService.getReport()` filters `report_name`, `day` range, and `bid`.

### `profile_events`

**Fact table**: one row per emitted analytics event. Column semantics follow **`AnalyticsEvent.toJson()`** (see ingest section above).

| Column | Mode | Type | Notes |
|--------|------|------|--------|
| `ver` | NULLABLE | INTEGER | Envelope **`version`** (default **1**) |
| `eid` | NULLABLE | STRING | UUID for this telemetry row (**`eventId`**) |
| `ts` | NULLABLE | TIMESTAMP | Client event time (**partition field**, DAY) |
| `ccg` | NULLABLE | INTEGER | **`clientClockGap`** |
| `ctz` | NULLABLE | INTEGER | **`clientTimeZone`** offset |
| `lts` | NULLABLE | TIMESTAMP | **`serverTimestamp`** |
| `ip` | NULLABLE | STRING | **`ipAddress`** at collection |
| `src` | NULLABLE | STRING | **`source`**, default **`"s"`** |
| `pid` | NULLABLE | STRING | **`profileId`** (UUID string) |
| `et` | NULLABLE | STRING | **`eventType`** string enum |
| `ext` | NULLABLE | JSON | **`eventPayload`**: unstructured fields (codes, IDs, nested objects) |
| `srcd` | NULLABLE | JSON | **`sourceDevice`** blob from mobile |
| `bid` | NULLABLE | INTEGER | **`brandId`** (schema default **102** applies when unspecified at load) |
| `cmp` | NULLABLE | TIMESTAMP | **`completedAt`** |
| `sid` | NULLABLE | STRING | **`sessionId`** |
| `p1`, `p2`, `p3` | NULLABLE | STRING | Params derived from **`eventNames[et]`** mapping |

Large volume (order **1e6+** rows / multi-month)—always bound **`ts`** and **`bid`** in exploration queries.

### `profile_events_grouped`

**Agg table**: `(et, pid, ts_bucket, bid, p1,p2,p3)` with **`count`**. Intended for cheap per-profile rollups (**`processTagRules`**, exploratory BI).

| Column | Mode | Type | Notes |
|--------|------|------|--------|
| `et` | REQUIRED | STRING | Event type |
| `pid` | REQUIRED | STRING | Profile id |
| `ts` | REQUIRED | TIMESTAMP | Partition timestamp; sampled rows showed **midnight** bucket per day (confirm in your environment) |
| `bid` | REQUIRED | INTEGER | Brand id |
| `p1`, `p2`, `p3` | NULLABLE | STRING | Params; must match **`events_grouped_daily`** semantics for same `et` |
| `count` | NULLABLE | INTEGER | Number of qualifying events for that grouping |

**Used in repo:** `` `processTagRules` `` aggregates **`sum(count)`** with **`ts >= TIMESTAMP(...)`**.

### `profile_summary`

**Monthly** per-profile KPI table (wide reports materialized long).

| Column | Mode | Type | Notes |
|--------|------|------|--------|
| `version` | REQUIRED | INTEGER | Row format version (**1** in samples) |
| `report_name` | REQUIRED | STRING | Stable report slug (strings may retain typos from historical pipelines—see sample) |
| `profile_id` | REQUIRED | STRING | Subject profile UUID |
| `key` | REQUIRED | STRING | Sub-dimension (**category** slices, funnel step name, attribute bucket, etc.) |
| `value` | REQUIRED | INTEGER | Integer metric for `(profile_id, month, report_name, key)` |
| `month` | NULLABLE | DATE | First-of-month **partition** date for the rollup |

**Used in repo:** Not directly queried in tracked application SQL; use for **per-user** engagement summaries and settings-category style reports.

---

## Tables agents actually query (from this codebase)

### 1. `events.events_grouped_daily`

See **dataset `events` → `events_grouped_daily`** above for all columns and types. **Role:** daily **brand-scoped** aggregates (no profile id).

**Used by:** AI-generated BigQuery reports (`BigQueryService.runRawQuery()`).

**Agent rule:** Prefer for “how much did X happen for this brand” when the report source is BigQuery. Filter **`bid`** and **`ts`**.

### 2. `events.events_summary`

See **dataset `events` → `events_summary`** above for all columns and types. **Role:** timeline / chart extracts by `report_name`.

**Used by:** `BigQueryService.getReport()`.

**Agent rule:** Use when templates map to `events_summary`, not AI raw SQL.

### 3. `mujual.events.profile_events_grouped`

See **dataset `events` → `profile_events_grouped`** above for all columns and types. **Role:** profile-level counts for tagging rules.

**Used by:** `processTagRules` Lambda.

**Agent rule:** Use **`profile_events_grouped`** for server-side tagging (not Postgres `events.profile_events`, not **`profile_events`** unless you deliberately need raw rows).

**Introduction chat analytics (backoffice):** `backoffice_backend` → `IntroductionChatAnalyticsService` exposes **`GET introductions/:id/chat-analytics`**. There is **no `introduction_id`** in BigQuery; the handler restricts **`bid`**, **both initiator and responder `pid`**, and a **half-open timestamp window** `[t_start, t_end)` derived from Postgres **`introduction_history`** (first **MATCHED** through first terminal status or “now”). The SQL uses the same **`bounds`** pattern as above: **`DATE(pe.ts) BETWEEN d_start AND d_end`** plus **`pe.ts >= t_start AND pe.ts < t_end`** for partition pruning. Counts come from grouped buckets (see **freshness caveat** above); **`last_activity_at`** is **`MAX(ts)`** over `messageSent` / `mediaSent`, which may be **day-resolution** depending on ETL.

### 4. Firebase Crashlytics export tables (`firebase_crashlytics` dataset)

**Role:** Crash and non-fatal event rows exported from Firebase Crashlytics to BigQuery.

**Used by:**

- `meeplus_app/scripts/crashlytics/crashlytics_bigquery_manager.py` and `crashlytics_bigquery.sh` (defaults: project `mujual`, dataset `firebase_crashlytics`, wildcard table pattern `com_algoai_*` in the Python query).

**Agent rule:** For mobile stability triage use this dataset via the documented scripts or `bq`; do not assume the same schema as `events.events_grouped_daily`.

## Workflows (how data moves and who runs queries)

### A. Backoffice BigQuery charts (AI report SQL)

1. Operator configures a report with source BigQuery in the BO reports tooling.
2. `AiService` selects the **`reports-system-bigquery`** prompt set; SQL targets `events.events_grouped_daily` and outputs a single column **`chart_json`** (stringified JSON for charts).
3. `BigQueryService.runRawQuery()` replaces placeholders:

   - `:brandId` → numeric brand id.
   - `:fromDate` → `DATE('YYYY-MM-DD')`.
   - `:toDate` → `DATE('YYYY-MM-DD')`.

4. Optional post-processing regroups **time** charts by week/month for long ranges.

**Reference files:**  
`backoffice_backend/src/services/bigquery.service.ts`,  
`backoffice_backend/src/services/ai.service.ts`,  
`backoffice_backend/src/prompts/reports/system-prompt-bigquery.txt`.

### B. Backoffice timeline reports from `events_summary`

Classic path: template name → `report_name`, date range → `day`, brand → `bid`. Implemented in `BigQueryService.getReport()`.

### C. Profile tag rules (`processTagRules`)

Nightly-style job resolves active rules per brand, runs parallel BigQuery queries against `` `mujual.events.profile_events_grouped` ``, merges results, persists tags (`ProfileExternalInfo`).

Credentials: Lambda loads **`BIGQUERY_CREDENTIALS`** from SSM (JSON base64). Local emulation may use **`bigquery-key.json`** and `FIREBASE_PROJECT_ID`.

**Reference:**  
`jlov-backend/profile-service/src/functions/private/processTagRules.ts`.

## Authentication (operational sketch)

Agents should **not** hardcode secrets. In this repo:

- **Backoffice Nest app:** expects `bigquery-key.json` (ignored from git) in the backend working directory; project id **`mujual`**.
- **Profile service Lambda:** SSM **`BIGQUERY_CREDENTIALS`**; project from **`FIREBASE_PROJECT_ID`**.
- **Local scripts (Crashlytics):** service account JSON path wired in shell/Python script.

Humans/automation needing CLI access use **`gcloud auth application-default login`** or a service account JSON with BigQuery scopes.

## Using the BigQuery CLI (`bq`) for discovery

Install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) so `bq` is available. Set project:

```bash
gcloud config set project mujual
```

### List datasets and tables

```bash
bq ls
bq ls events
bq ls firebase_crashlytics
```

### Inspect schema (authoritative columns and types)

```bash
for t in events_grouped_daily events_summary profile_events profile_events_grouped profile_summary; do
  echo "=== $t ===" && bq show --schema --format=prettyjson "mujual:events.$t"
done
```

### Dry-run or run a minimal query

```bash
bq query --dry_run --use_legacy_sql=false 'SELECT COUNT(*) AS n FROM `mujual.events.events_grouped_daily` WHERE bid = 1 AND ts BETWEEN DATE("2026-04-01") AND DATE("2026-04-30") LIMIT 1'
```

Adjust `bid`, dates, and table names once schema inspection confirms partitioning and column names in your environment.

### Crashlytics table discovery

Exported table names vary by Firebase app bundle id:

```bash
bq ls firebase_crashlytics | head
```

Then:

```bash
bq show --schema --format=prettyjson "mujual:firebase_crashlytics.<YOUR_TABLE_SUFFIX>"
```

## Event name catalog for `events_grouped_daily`

Exact `et` values and `(p1, p2, p3)` meanings are centralized in **`backoffice_backend/src/prompts/reports/system-prompt-bigquery.txt`** (maintain that file when adding new tracked events intended for BI).

## Related documentation in this repo

- Backoffice APIs and integrations overview: `alove-docs/backoffice_backend/API_DOCUMENTATION.md` (mentions BigQuery and report agents).
- Tag rules behavior (conceptual — verify table name against code): `jlov-backend/profile-service/docs/processTagRules.md`.
- Supporting skill for report creation flows: `.cursor/skills/create-backoffice-report/SKILL.md` (points at prompts under `backoffice_backend/src/prompts/reports/`).
- Crashlytics BigQuery tooling: `meeplus_app/scripts/crashlytics/README.md` and `crashlytics_bigquery.sh`.
