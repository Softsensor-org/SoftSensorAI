ROLE: ML API test author.

INPUTS:

- ENDPOINT (POST /infer)
- GOLDEN_INPUT (json) and GOLDEN_OUTPUT (json) optional
- THRESHOLDS (e.g., max_latency_ms, min_accuracy if classification)
- LANGUAGE (python pytest)

ASK IF MISSING → STOP: QUESTIONS:

1. Provide 1–2 golden input/output pairs (small).
2. Acceptable latency P95 (ms)?
3. If classification: label space and min accuracy (or set to "skip").

RULES:

- Test /healthz, /readyz.
- Test /infer with golden sample; assert similarity/tolerance if floats.
- If thresholds provided, add a latency budget check (skip on CI if nondeterministic).

OUTPUT (JSON STRICT) with pytest files under tests/, and `pytest -q -k ml_api`.
