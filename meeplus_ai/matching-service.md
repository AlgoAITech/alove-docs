# Matching Service

## Overview

The Matching Service is the core engine of the MeePlus AI platform, responsible for analyzing user profiles and generating intelligent partner suggestions based on compatibility scores, preferences, and behavioral patterns.

## Purpose

The service provides sophisticated matching algorithms that consider multiple dimensions of compatibility:
- **Bio Preferences**: Compatibility based on user bios and stated preferences
- **Personality Predictors**: Attachment styles and personality dimensions
- **Geographic Proximity**: Location-based matching using haversine distance
- **Brand-Specific Criteria**: Custom matching rules per brand/community
- **Mutual Interest Indicators**: Two-way compatibility assessment

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   API Gateway   │───▶│  Lambda Function │───▶│   PostgreSQL    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │   Scoring Engine │
                       └──────────────────┘
```

## Key Components

### 1. Core Matching Engine (`suggestions.py`)
- **Function**: `get_suggestions_scores()`
- **Purpose**: Main algorithm that calculates compatibility scores
- **Process**:
  1. Retrieves user profile and preferences
  2. Fetches potential matches from database
  3. Applies bio preferences scoring
  4. Calculates geographic compatibility
  5. Applies brand-specific filters
  6. Returns ranked suggestions

### 2. Bio Preferences Analysis (`bio_prefs.py`)
- **Function**: `get_bio_pref_relations()`
- **Purpose**: Analyzes compatibility based on bio and preference data
- **Features**:
  - Question-based compatibility scoring
  - Weighted preference matching
  - Cached metadata for performance
- **Age interval scoring** (`bio_prefs_scoring.interval_age`): partner birth-month values are expected as `YYYY-MM`. Values that are missing, malformed, or not a real calendar month are treated as a zero contribution for that question so suggestion Lambdas do not fail on bad profile data.

### 3. Personality Predictors (`predictors.py`)
- **Function**: `get_predictors_questions_scores()`
- **Purpose**: Calculates attachment styles and personality dimensions
- **Dimensions**:
  - **Anxiety Dimension**: Measures relationship anxiety levels
  - **Avoidance Dimension**: Measures emotional avoidance patterns
  - **Attachment Category**: Classifies attachment style (secure, anxious, avoidant, etc.)

### 4. Introduction Management (`introductions.py`)
- **Function**: `get_introductions_status()`
- **Purpose**: Manages incoming and outgoing introduction requests
- **Features**:
  - Tracks introduction history
  - Prevents duplicate suggestions
  - Manages introduction limits

### 5. Database Operations (`queries.py`)
- **Purpose**: Handles all database interactions
- **Features**:
  - Profile retrieval
  - Questionnaire data access
  - Bio preferences metadata
  - Geographic data queries

## API Endpoints

### GET /suggestions/{profile_id}

Returns matching profile suggestions for a user.

**Parameters**:
- `profile_id` (path): The user's profile ID

**Response**:
```json
{
  "id": "uuid",
  "profile_id": "user-profile-id",
  "info_code": 200,
  "info_message": "Success",
  "incoming": {
    "id": "uuid",
    "partner_profile_id": "partner-id",
    "matching_score_to_user_pref": 68.26,
    "matching_score_to_partner_pref": 68.57,
    "tolerance_used": ["agePref", "heightPref"]
  },
  "outgoings": [
    {
      "id": "uuid",
      "partner_profile_id": "partner-id",
      "matching_score_to_user_pref": 57.80,
      "matching_score_to_partner_pref": 68.57,
      "tolerance_used": []
    }
  ]
}
```

`tolerance_used` is an array of profile attribute names for which tolerance was applied during scoring (instead of a single boolean flag).

**Status Codes**:
- `200`: Success with suggestions
- `206`: Success but no suggestions available
- `500`: Error occurred

### GET /predictors/{profile_id}

Returns personality predictor scores for a user.

**Parameters**:
- `profile_id` (path): The user's profile ID

**Response**:
```json
{
  "profile_id": "user-profile-id",
  "attachment_info": {
    "anxiety_dim": 2.5,
    "avoidance_dim": 3.2,
    "attachment_category": "secure"
  }
}
```

## Scoring Algorithm

### Bio Preferences Scoring
1. **Question Analysis**: Evaluates responses to compatibility questions
2. **Weight Calculation**: Applies importance weights to different questions
3. **Compatibility Score**: Calculates weighted average of matching responses
4. **Threshold Filtering**: Filters out profiles below minimum compatibility threshold

### Geographic Scoring
1. **Distance Calculation**: Uses haversine formula for geographic distance
2. **Proximity Weighting**: Applies distance-based scoring weights
3. **Location Preferences**: Considers user's location preferences

### Attachment Style Compatibility
1. **Dimension Calculation**: Computes anxiety and avoidance dimensions
2. **Category Classification**: Determines attachment style category
3. **Compatibility Matrix**: Applies compatibility rules between different styles

### Predictor relation score (suggestions)
When suggesting matches, the service can score each candidate pair using `predictors_relations` plus per–question-category averages stored on profiles (`profile_external_info` rows whose `attribute_name` is the category id and `attribute_value` is the numeric average, typically `source = predictorsCalc`). Those averages are produced from **predictor scale** questionnaire answers only (see profile-service `predictorsCalcFromResponses`).

- Only rows with `predictor1 = predictor2` (category id) are used. Rows sharing the same non-empty `relation_group` and the same `grade` form one group (often two categories).
- Each row’s `level1` / `level2` are discrete levels **0–4** for profile 1 and profile 2. Scale averages (1–7) map to levels: (1,2]→0, (2,3.5]→1, (3.5,4.5]→2, (4.5,6]→3, (6,7]→4.
- If all rows in a group match the pair’s levels, that group contributes its `grade`. The final raw score is a **weighted average** of matching group grades; weights are the parent **factor** `general_codes.extra.weight` (averaged across categories in the group). The suggestion predictor percent is **raw × 10** (0–100).
- If no relation group matches, predictor contribution is **0%** when `minPredictorsScorePercent` is 0; otherwise the pair is skipped when that minimum is positive.

### Brand-Specific Scoring
1. **Brand Rules**: Applies custom matching rules per brand
2. **Community Preferences**: Considers brand-specific user preferences
3. **Cultural Factors**: Incorporates cultural and community-specific criteria

## Performance Optimizations

### Caching Strategy
- **Bio Preferences Metadata**: Cached in memory for fast access
- **Question Lists**: Cached per brand to avoid repeated database queries
- **Profile Data**: Efficient retrieval with minimal database calls

### Database Optimization
- **Indexed Queries**: Optimized database indexes for profile lookups
- **Connection Pooling**: Efficient database connection management
- **Query Optimization**: Minimized database round trips

### Response Compression
- **Gzip Compression**: Enabled for responses > 1KB
- **Efficient Serialization**: Optimized JSON response formatting

## Configuration

### Environment Variables
```bash
# Database Configuration
ACCOUNT_DB_HOST=your-db-host
ACCOUNT_DB_NAME=your-db-name
ACCOUNT_DB_USER=your-db-user
ACCOUNT_DB_PASSWORD=your-db-password
ACCOUNT_DB_PORT=5432

# Monitoring
CORALOGIX_URL=your-coralogix-url
CORALOGIX_PRIVATE_KEY=your-coralogix-key
SERVICE_NAME=matching-service
CORALOGIX_SUBSYSTEM=matching

# Assets
ASSETS_BUCKET=your-s3-bucket
BIO_PREFS_QUESTIONS_FILE_PATH=path/to/questions.json
PREDICTORS_QUESTIONS_FILE_PATH=path/to/predictors.json
```

### Brand Configuration
Brand-specific settings are managed through the database and include:
- Question sets and weights
- Geographic preferences
- Cultural matching criteria
- Introduction limits

## Monitoring and Logging

### Coralogix Integration
- **Telemetry**: Automatic performance monitoring
- **Logging**: Structured logging for debugging
- **Metrics**: Key performance indicators tracking

### Key Metrics
- Request latency
- Matching score distribution
- Geographic distribution of matches
- Brand-specific performance metrics

## Development

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Run tests
python -m pytest test/
```

### Testing
```bash
# Run all tests
python -m pytest test/

# Run specific test file
python -m pytest test/test_suggestions.py

# Run with coverage
python -m pytest test/ --cov=src
```

## Deployment

### Serverless Deployment
```bash
# Deploy to dev environment
serverless deploy --stage dev

# Deploy to production
serverless deploy --stage prod
```

### Infrastructure
- **Runtime**: Python 3.9
- **Memory**: 512MB (configurable)
- **Timeout**: 30 seconds
- **Concurrency**: Auto-scaling based on demand

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Check database credentials
   - Verify network connectivity
   - Ensure database is accessible

2. **Scoring Algorithm Issues**
   - Verify question data integrity
   - Check bio preferences metadata
   - Validate geographic data

3. **Performance Issues**
   - Monitor database query performance
   - Check caching effectiveness
   - Review Lambda cold start times

### Debugging
- Enable detailed logging in Coralogix
- Check CloudWatch logs for errors
- Monitor API Gateway metrics
- Review database query performance

## Future Enhancements

### Planned Features
- **Machine Learning Integration**: Enhanced scoring with ML models
- **Real-time Updates**: Live profile updates and re-scoring
- **Advanced Filtering**: More sophisticated filtering options
- **Performance Optimization**: Further caching and optimization improvements

### Scalability Improvements
- **Database Sharding**: Horizontal scaling for large datasets
- **Caching Layer**: Redis integration for better performance
- **Async Processing**: Background processing for heavy computations 