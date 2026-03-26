-- LLM match advisor (OpenAI) output for introductions (ticket 39436).
-- Run against the account DB used by jlov-backend / backoffice_backend.

ALTER TABLE public.introductions
  ADD COLUMN IF NOT EXISTS llm_match_advisor jsonb NULL;

COMMENT ON COLUMN public.introductions.llm_match_advisor IS
  'OpenAI match-advisor JSON: MM opinion, pitches, score, reasons, optional context snapshot and error.';
