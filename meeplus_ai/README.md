# MeePlus AI - Project Documentation

## Overview

MeePlus AI is a comprehensive dating and relationship platform that leverages artificial intelligence to provide intelligent matching, personality analysis, and conversational AI assistance. The platform is built as a microservices architecture deployed on AWS Lambda using the Serverless Framework.

## Architecture

The project follows a microservices architecture with three main components:

```
meeplus_ai/
├── matching-service/     # Profile matching and scoring engine
├── agent-service/        # AI conversational agent
└── common-models/        # Shared data models and validation
```

## Services

### 1. Matching Service

**Purpose**: Core matching engine that analyzes user profiles and provides intelligent partner suggestions based on compatibility scores, preferences, and behavioral patterns.

**Key Features**:
- **Profile Matching**: Analyzes user profiles and generates compatibility scores
- **Bio Preferences Scoring**: Evaluates compatibility based on bio and preference data
- **Predictors Analysis**: Calculates attachment styles and personality dimensions
- **Introduction Management**: Handles incoming and outgoing introduction requests
- **Geographic Matching**: Considers location-based compatibility using haversine distance

**API Endpoints**:
- `GET /suggestions/{profile_id}` - Get matching profile suggestions
- `GET /predictors/{profile_id}` - Get personality predictor scores

**Technology Stack**:
- **Runtime**: Python 3.9
- **Framework**: Serverless Framework
- **Database**: PostgreSQL (via Peewee ORM)
- **Caching**: In-memory caching for bio preferences metadata
- **Monitoring**: Coralogix for logging and telemetry

**Key Components**:
- `suggestions.py` - Core matching algorithm and scoring logic
- `bio_prefs.py` - Bio preferences analysis and scoring
- `predictors.py` - Personality predictor calculations
- `introductions.py` - Introduction status management
- `queries.py` - Database query operations

**Scoring Algorithm**:
The service uses a sophisticated scoring system that considers:
- Bio preferences compatibility
- Attachment style compatibility (anxiety/avoidance dimensions)
- Geographic proximity
- Mutual interest indicators
- Brand-specific matching criteria

### 2. Agent Service

**Purpose**: AI-powered conversational agent that provides personalized relationship advice, conversation insights, and interactive assistance to users.

**Key Features**:
- **Conversational AI**: Powered by OpenAI GPT models with LangChain integration
- **Profile Context**: Accesses user profile data for personalized responses
- **Introduction Insights**: Provides analysis of user's introduction history
- **Partner Search**: Allows users to search for specific partners by name
- **Conversation Analysis**: Generates insights from conversation patterns
- **Multi-tool Integration**: Uses multiple tools for comprehensive assistance

**API Endpoints**:
- `POST /inference` - Process conversational AI requests

**Technology Stack**:
- **Runtime**: Python 3.9
- **Framework**: Serverless Framework
- **AI/ML**: OpenAI GPT, LangChain, LangGraph
- **Database**: PostgreSQL
- **Monitoring**: Datadog integration

**Key Components**:
- `inference.py` - Main AI inference handler
- `prompts/` - System prompts and conversation templates
- `utils/` - Utility functions for profile, introduction, and insight management

**AI Capabilities**:
- Personalized conversation based on user profile
- Introduction history analysis
- Partner search and profile retrieval
- Conversation insights generation
- Relationship advice and guidance

### 3. Common Models

**Purpose**: Shared data models and validation layer that ensures consistency across all services.

**Key Features**:
- **Data Validation**: Pydantic-based model validation
- **Type Safety**: Full type hints for better development experience
- **Serialization**: Easy JSON conversion for API responses
- **Reusability**: Shared across all services
- **Versioning**: Proper package management and versioning

**Available Models**:
- `Profile` - User profile data
- `Question` - Question/quiz data
- `QuestionList` - List of questions
- `QuestionCategory` - Question categories
- `Brand` - Brand information
- `Attribute` - Generic attributes
- `Translation` - Multi-language support
- `Introduction` - User introductions
- `ProfileExternalInfo` - External profile data
- `SuggestedProfile` - Suggested profiles
- `BioPrefRelation` - Bio and preference relationships
- `BatchContent` - Batch processing content
- `Execution` - Execution tracking
- `BaseModel` - Base model class

**Technology Stack**:
- **Validation**: Pydantic >= 2.0.0
- **Testing**: pytest with coverage
- **Packaging**: setuptools for distribution

### 4. Jev AI Attributes Service (`jev-ai-attributes-service/`)

**Purpose**: scores profile free text with TypeSafe **Jev** (System One). Details and commands: the service's own
`README.md`.

- **AI traits** (`calcJevAiAttributes`): `aiAnalysis` traits and `aiAnalysisPref` partner preferences (1–9) from
  free text and decline answers.
- **Decline fill** (`scripts/decline_fill.py`): turns decline answers into values on the Forbidden attributes
  declared with `settings.aiFill` / `settings.aiOnly`. Dry-run by default; `--apply` writes over direct Postgres
  only, with a change log.
- **Match checks** (`scripts/match_checks.py`, dry-run only, Oct 2026): before a suggestion is sent, one Jev call
  asks a fixed set of yes/no questions about the pair. A yes at or above its threshold, or a code check (the pair
  was declined before, an empty About me), flags it for an admin. The questions are `general_codes` rows of type
  `matchCheck`, so admins add and tune them on the General Codes page:

  | Field | Meaning |
  |---|---|
  | `name` | The question, written about "the member" and "the candidate" |
  | `extra.threshold` | Yes/no score that flags (default 0.7) |
  | `extra.bothWays` | Also ask it with "member" and "candidate" swapped (default true) |
  | `extra.scope` | `pair` (default) or `member`: asked once per member; a yes is a note on that member's pairs, never a hold |

  Brand rows come first, then brand 0, then a built-in set. Plan and test cases: meta-repo
  `docs/ai-compatibility/steps/5-checks.md`.

## Data Flow

```
User Request → API Gateway → Lambda Function → Database/External APIs → Response
```

### Matching Service Flow:
1. User requests profile suggestions
2. Service retrieves user profile and preferences
3. Calculates compatibility scores with potential matches
4. Applies filters (geographic, brand-specific, etc.)
5. Returns ranked list of suggestions

### Agent Service Flow:
1. User sends conversational message
2. Service loads user context (profile, introductions, insights)
3. AI agent processes request using available tools
4. Generates personalized response and insights
5. Returns response with conversation analysis

## Deployment

### Prerequisites
- AWS CLI configured
- Serverless Framework installed
- Python 3.9+
- Node.js (for Serverless Framework)

### Environment Variables

**Matching Service**:
- `STAGE` - Deployment stage (dev/prod)
- `AWS_REGION` - AWS region
- `CORALOGIX_URL` - Coralogix logging URL
- `CORALOGIX_PRIVATE_KEY` - Coralogix API key
- `ACCOUNT_DB_*` - Database connection parameters
- `ASSETS_BUCKET` - S3 bucket for assets
- `BIO_PREFS_QUESTIONS_FILE_PATH` - Bio preferences questions file
- `PREDICTORS_QUESTIONS_FILE_PATH` - Predictors questions file

**Agent Service**:
- `STAGE` - Deployment stage
- `AWS_REGION` - AWS region
- `OPENAI_API_KEY` - OpenAI API key
- `ALOVE_API_KEY` - ALOVE API key
- `ACCOUNT_DB_*` - Database connection parameters
- `ALOVE_API_BASE_URL` - ALOVE API base URL

### Deployment Commands

```bash
# Deploy matching service
cd matching-service
npm install
serverless deploy --stage dev

# Deploy agent service
cd agent-service
npm install
serverless deploy --stage dev

# Deploy common models (if needed as package)
cd common-models
pip install -e .
```

## Development

### Local Development Setup

1. **Clone the repository**:
```bash
git clone <repository-url>
cd meeplus_ai
```

2. **Set up virtual environments**:
```bash
# For each service
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

3. **Install common models locally**:
```bash
cd common-models
pip install -e .
```

4. **Set up environment variables**:
Create `.env` files in each service directory with required environment variables.

### Testing

**Common Models**:
```bash
cd common-models
pytest tests/
```

**Matching Service**:
```bash
cd matching-service
python -m pytest test/
```

**Agent Service**:
```bash
cd agent-service
python test_partner_tool.py
```

## Monitoring and Logging

### Coralogix Integration
- **Matching Service**: Uses Coralogix for telemetry and logging
- **Configuration**: Set via environment variables
- **Features**: Low overhead reporting strategy

### Datadog Integration
- **Agent Service**: Uses Datadog for monitoring
- **Configuration**: API key via environment variables
- **Features**: Performance monitoring and alerting

## Security

### Authentication
- AWS Cognito integration for user authentication
- API Gateway with private endpoints
- IAM role-based access control

### Data Protection
- Environment variable management for sensitive data
- SSM Parameter Store for secrets
- Database connection encryption

## Performance

### Optimization Features
- **Caching**: In-memory caching for frequently accessed data
- **Compression**: Gzip compression for API responses > 1KB
- **Lambda Layers**: Shared dependencies via Lambda layers
- **Database Optimization**: Efficient queries with proper indexing

### Scalability
- **Serverless**: Automatic scaling based on demand
- **Microservices**: Independent scaling of services
- **Database**: PostgreSQL with connection pooling

## API Documentation

### Matching Service API

#### GET /suggestions/{profile_id}
Returns matching profile suggestions for a user.

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
    "matching_score_to_partner_pref": 68.57
  },
  "outgoings": [
    {
      "id": "uuid",
      "partner_profile_id": "partner-id",
      "matching_score_to_user_pref": 57.80,
      "matching_score_to_partner_pref": 68.57
    }
  ]
}
```

#### GET /predictors/{profile_id}
Returns personality predictor scores for a user.

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

### Agent Service API

#### POST /inference
Processes conversational AI requests.

**Request**:
```json
{
  "profile_id": "user-profile-id",
  "messages": [
    {"role": "user", "content": "Hello, can you help me with dating advice?"}
  ],
  "model": "openai:gpt-4.1-nano"
}
```

**Response**:
```json
{
  "message": "Hello! I'd be happy to help you with dating advice...",
  "insights": {
    "conversation_style": "friendly",
    "topics_of_interest": ["dating", "relationships"]
  }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

[Add license information here]

## Support

For technical support or questions about the MeePlus AI platform, please contact the development team or create an issue in the repository. 