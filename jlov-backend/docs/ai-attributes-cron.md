# AI Attributes Cron — profile-service

## Overview

The `calcAiAttributes` Lambda runs daily at **03:00 UTC** and automatically extracts personality and occupation attributes from users' free-text questionnaire responses using an LLM.

## Attributes extracted

| Profile attribute | Display name | Type | Storage |
|---|---|---|---|
| `aiFunLevel` | Fun level | Integer 1–10 | `profiles.attributes_values` |
| `aiCalmLevel` | Calm level | Integer 1–10 | `profiles.attributes_values` |
| `aiEmotionalDepth` | Emotional depth | Integer 1–10 | `profiles.attributes_values` |
| `aiAliyah` | Aliyah | Boolean (`"true"`/`"false"`) | `profiles.attributes_values` |
| `aiOccupation` | Occupation (AI) | Multi-choice array | `profiles.attributes_values` |

Corresponding **pref** attributes (`aiFunLevelPref`, `aiCalmLevelPref`, `aiEmotionalDepthPref`, `aiAliyahPref`, `aiOccupationPref`) are created in the `pref` attribute group and populated by users or matchmakers.

## How it works

1. Finds all profiles (per brand) that answered at least one **free-text** question (`ResponseType.Text`) in the configured time window (default: **last 24 hours** for the scheduled cron).
2. Loads the latest free-text Q&A for each profile (question text + answer).
3. Sends the Q&A array to OpenAI via the `ai-attributes` agent configured in `general_codes`.
4. Parses the JSON response and writes results into `profiles.attributes_values`.

## Manual invoke (backfill / custom window)

The scheduled Lambda (`calcAiAttributes`) accepts an optional JSON event when invoked manually (AWS console **Test**, or `aws lambda invoke`). An empty event `{}` keeps cron behaviour (last 24h, all brands with an active `ai-attributes` agent).

| Field | Type | Meaning |
|---|---|---|
| `brandId` | number (optional) | Process only this brand; omit for all configured brands |
| `since` | ISO date string (optional) | Include free-text answers with `profile_responses.reported >= since`. Default: now − 24h |
| `until` | ISO date string (optional) | Upper bound: `reported <= until`. Omit for no upper bound |
| `sinceDays` | number (optional) | Shorthand for `since = now − N days` when `since` is omitted (e.g. `7` = last week, `30` = last month) |

Examples:

```json
{ "brandId": 102, "sinceDays": 7 }
```

```json
{
  "brandId": 102,
  "since": "2026-08-01T00:00:00.000Z",
  "until": "2026-09-07T23:59:59.999Z"
}
```

Function name: `profile-service-<stage>-calcAiAttributes` (e.g. `profile-service-alove-dev-calcAiAttributes`). The Lambda timeout is **900s**; profiles beyond the time budget are counted as `deferred` and can be picked up on a later invoke.

Per-profile on-demand calc (all latest free-text for one user, no date window) remains **`POST /private/profiles/{pid}/calc-ai-attributes`**.

## Agent configuration

The agent is stored in `general_codes` with `type = 'agent'` and `name = 'ai-attributes'`.

| Field | Value |
|---|---|
| `model` | `gpt-4o-mini` |
| `temperature` | `0.2` |
| `tokens` | `800` |
| `prompt` | System prompt instructing the LLM to return JSON with the 5 attributes |

**To activate:** approve the `ai-attributes` general_code proposal in backoffice Change Proposals (page 9.3) and set an OpenAI API key in `extra.apiKey`.

The cron is **gated** — if no active `ai-attributes` general_code exists for a brand, it silently skips that brand.

## Scoring (bio/pref relations)

- **Boolean (`aiAliyah`)** and **multi-choice (`aiOccupation`)**: mapped via `bio_pref_relations` token rows (inserted after attributes are approved and have DB IDs).
- **Numeric scale** (`aiFunLevel`, `aiCalmLevel`, `aiEmotionalDepth`): require a proximity scorer in the matching algorithm that computes `10 – |bio_score – pref_score|`. This is a future enhancement in `meeplus_ai`.

## Files

- `profile-service/src/functions/private/calcAiAttributes.ts` — main logic
- `profile-service/serverless.yml` — schedule definition (`calcAiAttributes` function)

## Related ticket

[#61947 — Create Attributes with AI](https://app.alove.ai)
