# Lora Service Documentation

## Service Overview

The Lora Service provides AI-powered conversation and questionnaire functionality for the JLOV dating platform. It handles intelligent messaging, automated responses, questionnaire management, and AI inference capabilities. The service uses advanced language models to enhance user interactions and provide personalized communication experiences.

## Service Details

- **Runtime**: Node.js 22.x
- **Authentication**: AWS Cognito User Pools
- **AI Integration**: Language model inference and conversation AI
- **Database**: Conversation and questionnaire database

## Lambda Functions

### Questionnaire Management Functions

#### getQuestionnaireStatus
**Purpose**: Retrieves the current status of a user's questionnaire
- **Handler**: `src/functions/getQuestionnaireStatus.getQuestionnaireStatusHandler`
- **Path**: `/questionnaire`
- **Method**: GET
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**: None (uses authenticated user context)
- **Returns**:
  - `200` - Questionnaire status retrieved successfully
  - `401` - Unauthorized
  - `404` - No questionnaire found
  - `500` - Server error

#### startLoraQuestionnaireHandler
**Purpose**: Starts a new questionnaire session for a user
- **Handler**: `src/functions/startLoraQuestionnaire.startLoraQuestionnaireHandler`
- **Path**: `/questionnaire`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.questionnaireType` (optional) - Type of questionnaire to start
  - `body.userPreferences` (optional) - User preferences for questionnaire
- **Returns**:
  - `201` - Questionnaire started successfully
  - `400` - Invalid questionnaire parameters
  - `401` - Unauthorized
  - `409` - Questionnaire already in progress
  - `500` - Server error

#### adminStartLoraQuestionnaireHandle
**Purpose**: Administratively starts a questionnaire for a user (private function)
- **Handler**: `src/functions/startLoraQuestionnaire.adminStartLoraQuestionnaireHandler`
- **Path**: `/private/questionnaire`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.userId` - ID of the user to start questionnaire for
  - `body.questionnaireType` - Type of questionnaire to start
  - `body.adminId` - ID of the administrator
- **Returns**:
  - `201` - Questionnaire started successfully
  - `400` - Invalid parameters
  - `401` - Unauthorized
  - `500` - Server error

#### saveResponse
**Purpose**: Saves a user's response to a questionnaire question
- **Handler**: `src/functions/saveResponse.saveResponseHandler`
- **Path**: `/responses`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.questionId` - ID of the question being answered
  - `body.response` - User's response to the question
  - `body.questionnaireId` - ID of the questionnaire
- **Returns**:
  - `200` - Response saved successfully
  - `400` - Invalid response data
  - `401` - Unauthorized
  - `404` - Question not found
  - `500` - Server error

#### revertAnswerHandler
**Purpose**: Reverts a user's answer to a previous response
- **Handler**: `src/functions/revertAnswer.revertAnswerHandler`
- **Path**: `/private/revertAnswer`
- **Method**: DELETE
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.questionId` - ID of the question to revert
  - `body.questionnaireId` - ID of the questionnaire
- **Returns**:
  - `200` - Answer reverted successfully
  - `400` - Invalid revert request
  - `401` - Unauthorized
  - `404` - Answer not found
  - `500` - Server error

#### loadAutocompleteResponsesHandler
**Purpose**: Loads autocomplete response suggestions
- **Handler**: `src/functions/loadAutocompleteResponses.loadAutocompleteResponsesHandler`
- **Path**: `/autocompleteResponses`
- **Method**: GET
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.questionType` (optional) - Type of question for suggestions
  - `queryStringParameters.partialResponse` (optional) - Partial response for suggestions
- **Returns**:
  - `200` - Autocomplete responses loaded successfully
  - `401` - Unauthorized
  - `500` - Server error

### Message Management Functions

#### getLoraMessagesHandler
**Purpose**: Retrieves AI-generated messages for a user
- **Handler**: `src/functions/getLoraMessages.getLoraMessagesHandler`
- **Path**: `/messages`
- **Method**: GET
- **Timeout**: 30 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.conversationId` (optional) - ID of the conversation
  - `queryStringParameters.limit` (optional) - Number of messages to retrieve
  - `queryStringParameters.offset` (optional) - Pagination offset
- **Returns**:
  - `200` - Messages retrieved successfully
  - `401` - Unauthorized
  - `500` - Server error

#### addMessageIfNotExsitsHandler
**Purpose**: Adds a message if it doesn't already exist (private function)
- **Handler**: `src/functions/addMessage.addMessageIfNotExsitsHandler`
- **Path**: `/private/messages`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.messageData` - Message content and metadata
  - `body.conversationId` - ID of the conversation
  - `body.messageType` (optional) - Type of message
- **Returns**:
  - `200` - Message added successfully
  - `400` - Invalid message data
  - `401` - Unauthorized
  - `409` - Message already exists
  - `500` - Server error

#### getIntroductionByIdHandler
**Purpose**: Retrieves messages by introduction ID (private function)
- **Handler**: `src/functions/getByIntroductionId.getByIntroductionIdHandler`
- **Path**: `/private/messages`
- **Method**: GET
- **Timeout**: 30 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `queryStringParameters.introductionId` - ID of the introduction
  - `queryStringParameters.profileId` - ID of the profile
- **Returns**:
  - `200` - Messages retrieved successfully
  - `401` - Unauthorized
  - `404` - Introduction not found
  - `500` - Server error

#### replyLoraHandler
**Purpose**: Generates AI-powered replies to messages (private function)
- **Handler**: `src/functions/replyLora.replyLoraHandler`
- **Path**: `/private/reply`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.messageId` - ID of the message to reply to
  - `body.context` (optional) - Additional context for reply generation
  - `body.style` (optional) - Reply style preferences
- **Returns**:
  - `200` - Reply generated successfully
  - `400` - Invalid reply request
  - `401` - Unauthorized
  - `404` - Message not found
  - `500` - Server error

#### addCommHandler
**Purpose**: Adds communication events (private function)
- **Handler**: `src/functions/addMessage.addCommHandler`
- **Path**: `/private/comm`
- **Method**: POST
- **Timeout**: 30 seconds
- **CORS**: true
- **Private**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.communicationData` - Communication event data
  - `body.eventType` - Type of communication event
  - `body.timestamp` (optional) - Event timestamp
- **Returns**:
  - `200` - Communication event added successfully
  - `400` - Invalid communication data
  - `401` - Unauthorized
  - `500` - Server error

### AI Inference Functions

#### inferenceHandler
**Purpose**: Performs AI inference for various tasks
- **Handler**: `src/functions/inference.inferenceHandler`
- **Path**: `/inference`
- **Method**: POST
- **Timeout**: 300 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters**:
  - `body.input` - Input data for inference
  - `body.model` (optional) - AI model to use for inference
  - `body.parameters` (optional) - Inference parameters
- **Returns**:
  - `200` - Inference completed successfully
  - `400` - Invalid inference request
  - `401` - Unauthorized
  - `500` - Server error

**Agent settings integration**:
- Before calling `agent/inference`, the lambda resolves `general_codes` entry:
  - `type = "agent"`
  - `name = "lora-inference"`
  - `brand_id = current user brand` (fallback to `brand_id = 0`)
  - `is_active = true`
- Supported `extra` fields:
  - `model`
  - `prompt`
  - `tokens`
  - `temperature`
  - `apiKey` (stored encrypted, decrypted only at runtime)
- If agent row/field is missing, behavior falls back to legacy defaults (e.g. `SettingName.aiModel`).

#### transcribeAudioFromUrl (user)
**Purpose**: Transcribes audio for the signed-in user (e.g. Lora chat text questions with voice input)
- **Handler**: `src/functions/transcribeAudioFromUrl.transcribeAudioFromUrlUserHandler`
- **Path**: `/transcribeAudioFromUrl`
- **Method**: POST
- **Timeout**: 120 seconds
- **CORS**: true
- **Authentication**: Required (Cognito User Pools)
- **Parameters** (JSON body):
  - `audioUrl` (required) - HTTPS URL to the audio file, or a `data:` URL with base64 audio
  - `caller` (optional) - Short label for logging and default prompt tuning (e.g. `lora_chat_text_question`)
  - `instructions` (optional) - Extra transcription instructions for this caller
  - `questionText` (optional) - Question being answered; included in the prompt for context
- **Behavior**: Requires brand setting `voiceTranscription` app feature. Uses OpenAI speech-to-text; model from setting `audioTranscribeModel` or `whisper-1` if unset. Builds a prompt from caller, optional instructions, default accuracy instructions, and optional question text.
- **Returns**:
  - `200` - `{ "text": "...", "summary": "" }`
  - `400` - Missing or invalid `audioUrl`
  - `403` - Voice transcription disabled for brand
  - `401` - Unauthorized
  - `502` - Transcription provider error

#### transcribeAudioFromUrl (private / API key)
**Purpose**: Same transcription for server-to-server callers (e.g. backoffice) with explicit brand
- **Handler**: `src/functions/transcribeAudioFromUrl.transcribeAudioFromUrlPrivateHandler`
- **Path**: `/private/transcribeAudioFromUrl`
- **Method**: POST
- **Timeout**: 120 seconds
- **CORS**: true
- **Private**: true (API Gateway API key)
- **Parameters** (JSON body): Same as user endpoint, plus `brandId` (required, number)

## Environment Variables

The service uses the following environment variables:

- `CX_REPORTING_STRATEGY` - Coralogix reporting strategy
- `CX_DOMAIN` - Coralogix domain
- `CX_APPLICATION_NAME` - Coralogix application name
- `CX_SUBSYSTEM_NAME` - Coralogix subsystem name
- `CX_API_KEY` - Coralogix API key (from SSM)
- `WSS_API_GATEWAY_ENDPOINT` - WebSocket API Gateway endpoint

## AI Features

### Questionnaire Types
- **Personality Assessment**: Comprehensive personality questionnaires
- **Preferences Survey**: Dating preferences and compatibility questions
- **Communication Style**: Communication preference assessment
- **Values Assessment**: Core values and beliefs evaluation

### AI Capabilities
- **Natural Language Processing**: Advanced text understanding and generation
- **Context Awareness**: Contextual conversation understanding
- **Personalization**: Personalized responses based on user data
- **Multi-language Support**: Support for multiple languages
- **Sentiment Analysis**: Understanding user sentiment and emotions

### Message Generation
- **Conversation Starters**: AI-generated conversation openers
- **Response Suggestions**: Intelligent response recommendations
- **Ice Breakers**: Creative ice breaker messages
- **Follow-up Messages**: Contextual follow-up suggestions

## Security Features

- **Authentication Required**: All endpoints require valid JWT tokens
- **Data Privacy**: User data protection and privacy compliance
- **Content Moderation**: AI-generated content moderation
- **Rate Limiting**: Protection against abuse of AI services
- **Audit Logging**: All AI interactions are logged

## Error Handling

The service implements comprehensive error handling:

- **Validation Errors**: Invalid questionnaire or message data
- **Authentication Errors**: Invalid or expired tokens
- **AI Service Errors**: External AI service failures
- **Timeout Errors**: Long-running inference operations
- **Content Errors**: Inappropriate or flagged content
- **Service Errors**: Internal service failures

## Integration Points

- **AI Models**: External language model services
- **User Service**: User profile and preference data
- **Chat Service**: Message integration and conversation flow
- **Profile Service**: User profile information for personalization
- **Analytics Service**: AI performance and usage analytics
- **Database**: Conversation and questionnaire data storage

## Monitoring and Logging

- **Coralogix Integration**: Centralized logging
- **AI Performance Monitoring**: Model performance and accuracy tracking
- **Usage Analytics**: AI feature usage patterns
- **Error Tracking**: Failed AI operations logging
- **Response Quality**: AI response quality metrics

## AI Model Management

### Model Types
- **Language Models**: Large language models for text generation
- **Classification Models**: Models for content classification
- **Recommendation Models**: Models for personalized recommendations
- **Sentiment Models**: Models for sentiment analysis

### Model Performance
- **Accuracy Monitoring**: Continuous accuracy tracking
- **Response Time**: Performance monitoring for inference speed
- **Quality Metrics**: Response quality and relevance metrics
- **User Feedback**: User feedback integration for model improvement

## Scheduled Operations

### Daily Operations
- **Model Health Checks**: Daily AI model health monitoring
- **Usage Analytics**: Daily usage pattern analysis
- **Performance Review**: Daily performance metrics review

### Weekly Operations
- **Model Updates**: Weekly model performance updates
- **Quality Assessment**: Weekly response quality assessment
- **User Feedback Analysis**: Weekly user feedback analysis

### Monthly Operations
- **Model Optimization**: Monthly model optimization and tuning
- **Feature Analysis**: Monthly feature usage analysis
- **Performance Review**: Monthly comprehensive performance review 