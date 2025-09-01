# Chain: DS/ML Pipeline - Step 2/5 - FEATURES

You are executing step 2 of 5 for DS/ML pipeline.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_PROFILE_FROM_STEP_1}
</input>

<goal>
Propose minimal viable feature set and train/val/test split strategy.
</goal>

<plan>
- Select features based on profile insights
- Design feature engineering pipeline
- Define preprocessing steps
- Specify train/val/test split strategy
- Create feature importance baseline
</plan>

<work>
1. Feature selection rationale:
   ```python
   # Start with features that have:
   # - <30% missing values
   # - Low correlation with each other (<0.9)
   # - Some predictive signal (>0.1 correlation with target)
   
   selected_features = [
       # Numerical
       'feature_1',  # Strong correlation: 0.65
       'feature_2',  # Domain importance
       
       # Categorical  
       'category_1',  # High cardinality but important
       
       # Engineered
       'ratio_1',  # feature_1 / feature_2
       'is_weekend',  # from date_column
   ]
   ```

2. Preprocessing pipeline:
   ```python
   from sklearn.pipeline import Pipeline
   from sklearn.preprocessing import StandardScaler, OneHotEncoder
   from sklearn.impute import SimpleImputer
   
   numeric_pipeline = Pipeline([
       ('imputer', SimpleImputer(strategy='median')),
       ('scaler', StandardScaler())
   ])
   
   categorical_pipeline = Pipeline([
       ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
       ('encoder', OneHotEncoder(handle_unknown='ignore', sparse=False))
   ])
   ```

3. Split strategy:
   ```python
   # Time-based if temporal
   # Stratified if imbalanced
   # Random if no special constraints
   
   if has_time_column:
       train_end = '2023-12-31'
       val_end = '2024-03-31'
       # Train: < train_end
       # Val: train_end <= date < val_end  
       # Test: >= val_end
   else:
       # 60/20/20 stratified split
       X_temp, X_test, y_temp, y_test = train_test_split(
           X, y, test_size=0.2, stratify=y, random_state=42
       )
       X_train, X_val, y_train, y_val = train_test_split(
           X_temp, y_temp, test_size=0.25, stratify=y_temp, random_state=42
       )
   ```
</work>

<review>
- [ ] Features justified by data profile
- [ ] Engineering steps clear
- [ ] Preprocessing handles edge cases
- [ ] Split strategy prevents leakage
- [ ] Baseline metrics defined
</review>

<handoff>
<features>
## Feature Engineering Plan

**Selected Features** (15 total):
### Keep As-Is (8):
- `feature_1`: numerical, 5% missing, corr=0.65
- `feature_2`: numerical, 0% missing, corr=0.45
- `category_1`: categorical, 10 unique values

### Engineer (5):
- `ratio_1 = feature_1 / feature_2`: domain-specific ratio
- `log_feature_3 = log1p(feature_3)`: handle skewness
- `is_weekend`: binary from date_column
- `hour_of_day`: cyclical encoding from timestamp
- `text_length`: from text_column

### Drop (2):
- `id_column`: no predictive value
- `leaked_feature`: 0.99 correlation with target

**Preprocessing**:
```yaml
numerical:
  impute: median
  scale: StandardScaler
  
categorical:
  impute: constant('missing')
  encode: OneHotEncoder(max_categories=20)
  
text:
  vectorize: TfidfVectorizer(max_features=100)
```

**Split Strategy**:
- Method: {time-based|stratified|random}
- Train: 60% ({n_train} samples)
- Val: 20% ({n_val} samples)
- Test: 20% ({n_test} samples)
- Stratify by: {target_variable}
- Random seed: 42

**Validation Approach**:
- Primary metric: {RMSE|F1|AUC}
- Secondary: {MAE|Precision|Recall}
- Cross-validation: 5-fold on train set
</features>
</handoff>
