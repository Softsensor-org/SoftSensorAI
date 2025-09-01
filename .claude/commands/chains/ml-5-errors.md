# Chain: DS/ML Pipeline - Step 5/5 - ERROR ANALYSIS

You are executing step 5 of 5 for DS/ML pipeline.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_EVAL_FROM_STEP_4}
</input>

<goal>
Analyze error patterns, create error buckets, and propose 3 concrete next experiments.
</goal>

<plan>
- Load model predictions and analyze failures
- Cluster errors into interpretable buckets
- Identify systematic patterns
- Propose targeted improvements
- Prioritize next experiments
</plan>

<work>
1. Error analysis:
   ```python
   def analyze_errors(X_test, y_test, y_pred, y_proba):
       # Create error dataframe
       errors_df = X_test.copy()
       errors_df['actual'] = y_test
       errors_df['predicted'] = y_pred
       errors_df['probability'] = y_proba
       errors_df['correct'] = (y_test == y_pred)
       errors_df['confidence'] = np.abs(y_proba - 0.5)
       
       # Focus on errors
       errors_only = errors_df[~errors_df['correct']]
       
       # Error types
       false_positives = errors_only[errors_only['actual'] == 0]
       false_negatives = errors_only[errors_only['actual'] == 1]
       
       # High confidence errors (model was sure but wrong)
       high_conf_errors = errors_only[errors_only['confidence'] > 0.3]
       
       return errors_only, false_positives, false_negatives, high_conf_errors
   ```

2. Error bucketing:
   ```python
   def create_error_buckets(errors_df):
       buckets = {}
       
       # Bucket 1: Edge cases (extreme feature values)
       buckets['edge_cases'] = errors_df[
           (errors_df['feature_1'] > errors_df['feature_1'].quantile(0.95)) |
           (errors_df['feature_1'] < errors_df['feature_1'].quantile(0.05))
       ]
       
       # Bucket 2: Missing data issues
       buckets['high_missing'] = errors_df[
           errors_df.isnull().sum(axis=1) > 3
       ]
       
       # Bucket 3: Rare categories
       rare_categories = ['category_rare_1', 'category_rare_2']
       buckets['rare_categories'] = errors_df[
           errors_df['category_1'].isin(rare_categories)
       ]
       
       # Bucket 4: Temporal (if applicable)
       if 'date' in errors_df.columns:
           buckets['recent_data'] = errors_df[
               errors_df['date'] > '2024-01-01'
           ]
       
       return buckets
   ```

3. Pattern identification:
   ```python
   def identify_patterns(error_buckets):
       patterns = []
       
       for bucket_name, bucket_df in error_buckets.items():
           if len(bucket_df) > 0:
               error_rate = len(bucket_df) / len(test_set)
               patterns.append({
                   'bucket': bucket_name,
                   'count': len(bucket_df),
                   'error_rate': error_rate,
                   'common_features': bucket_df.describe()
               })
       
       return sorted(patterns, key=lambda x: x['error_rate'], reverse=True)
   ```
</work>

<self_check>
- Are error buckets mutually exclusive and collectively exhaustive?
- Do proposed experiments address the main error patterns?
- Are experiments feasible with available resources?
</self_check>

<review>
- [ ] Errors analyzed systematically
- [ ] Clear buckets identified
- [ ] Patterns documented
- [ ] Next experiments proposed
- [ ] Priority order justified
</review>

<handoff>
<next_steps>
## Error Analysis Report

### Error Distribution
- Total errors: {n_errors} ({error_rate}%)
- False positives: {n_fp} ({fp_rate}%)
- False negatives: {n_fn} ({fn_rate}%)
- High confidence errors: {n_high_conf} ({high_conf_rate}%)

### Error Buckets (Ranked by Impact)

#### Bucket 1: Edge Cases (35% of errors)
- **Pattern**: Model fails on extreme feature values
- **Examples**: feature_1 > 1000 or < 0.01
- **Root cause**: Insufficient training samples in extremes
- **Fix**: Augment training data or clip extremes

#### Bucket 2: Rare Categories (25% of errors)
- **Pattern**: Poor performance on categories with <100 samples
- **Examples**: category_1 in ['rare_a', 'rare_b']
- **Root cause**: Class imbalance
- **Fix**: Group rare categories or use class weights

#### Bucket 3: Recent Data (20% of errors)
- **Pattern**: Degraded performance on data after Jan 2024
- **Examples**: All samples from Q1 2024
- **Root cause**: Potential data drift
- **Fix**: Retrain with recent data or add drift detection

#### Bucket 4: High Missingness (15% of errors)
- **Pattern**: Errors when >3 features missing
- **Examples**: Samples with null feature_2, feature_5, feature_8
- **Root cause**: Imputation strategy too simple
- **Fix**: Advanced imputation (MICE, deep learning)

### Proposed Experiments (Priority Order)

#### Experiment 1: Handle Class Imbalance
**Hypothesis**: Class weights will improve rare category performance
**Approach**: 
- Add class_weight='balanced' to model
- Or: SMOTE oversampling for rare classes
**Expected impact**: -25% error rate on Bucket 2
**Effort**: 2 hours

#### Experiment 2: Feature Engineering for Extremes
**Hypothesis**: Log transform and clipping will help edge cases
**Approach**:
- Log transform skewed features
- Clip outliers at 1st/99th percentile
- Add is_extreme binary indicator
**Expected impact**: -30% error rate on Bucket 1
**Effort**: 4 hours

#### Experiment 3: Ensemble with Recent Data Specialist
**Hypothesis**: Separate model for recent data will handle drift
**Approach**:
- Train model_recent on 2024 data only
- Blend predictions: 0.7*main + 0.3*recent for new data
**Expected impact**: -15% error rate on Bucket 3
**Effort**: 6 hours

### Summary
- Main issue: Poor handling of edge cases and rare categories
- Quick wins: Class weights (Exp 1), feature clipping (Exp 2)
- Total expected improvement: ~15-20% error reduction
- Next review: After implementing top 2 experiments
</next_steps>
</handoff>
