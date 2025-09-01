# Chain: DS/ML Pipeline - Step 1/5 - PROFILE

You are executing step 1 of 5 for DS/ML pipeline.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
<dataset_path>{PATH_TO_DATASET}</dataset_path>
<target>{TARGET_VARIABLE_NAME}</target>
</input>

<goal>
Create comprehensive data profile: dictionary, missingness, distributions, and target leakage check.
</goal>

<plan>
- Load dataset and basic statistics
- Generate data dictionary with types and descriptions
- Analyze missingness patterns
- Create distribution plots for key features
- Check for target leakage
- Save artifacts to docs/eda/
</plan>

<work>
1. Data loading and initial inspection:
   ```python
   import pandas as pd
   import numpy as np
   import matplotlib.pyplot as plt
   import seaborn as sns
   
   df = pd.read_csv("{dataset_path}")
   print(f"Shape: {df.shape}")
   print(f"Memory: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
   ```

2. Data dictionary generation:
   ```python
   data_dict = pd.DataFrame({
       'column': df.columns,
       'dtype': df.dtypes,
       'non_null': df.count(),
       'null_pct': (df.isnull().sum() / len(df) * 100).round(2),
       'unique': df.nunique(),
       'sample_values': [df[col].dropna().head(3).tolist() for col in df.columns]
   })
   ```

3. Missingness analysis:
   ```python
   # Patterns
   msno.matrix(df)
   msno.heatmap(df)
   ```

4. Distribution analysis:
   ```python
   # Numerical features
   df.select_dtypes(include=[np.number]).hist(figsize=(15, 10))
   
   # Categorical features
   for col in df.select_dtypes(include=['object']).columns[:10]:
       df[col].value_counts().head(10).plot(kind='bar')
   ```

5. Target leakage detection:
   ```python
   # High correlation with target
   correlations = df.corr()[target].abs().sort_values(ascending=False)
   suspicious = correlations[correlations > 0.95].index.tolist()
   ```
</work>

<self_check>
- Are all numeric columns profiled?
- Are missing patterns identified?
- Is target leakage assessment complete?
- Are visualizations saved?
</self_check>

<review>
- [ ] Data dictionary created
- [ ] Missingness patterns documented
- [ ] Distributions visualized
- [ ] Target leakage checked
- [ ] Artifacts saved to docs/eda/
</review>

<handoff>
<profile>
## Dataset Profile

**Basic Stats**:
- Rows: {n_rows}
- Columns: {n_cols}
- Memory: {memory_mb} MB
- Target: {target_variable}

**Data Types**:
- Numerical: {list_of_numerical}
- Categorical: {list_of_categorical}
- DateTime: {list_of_datetime}

**Missingness**:
- Columns with >50% missing: {high_missing}
- MCAR/MAR/MNAR assessment: {pattern_type}

**Target Analysis**:
- Type: {regression/classification}
- Distribution: {balanced/imbalanced/normal/skewed}
- Potential leakage: {suspicious_features}

**Key Insights**:
1. {insight_1}
2. {insight_2}
3. {insight_3}

**Files Created**:
- docs/eda/profile.md
- docs/eda/data_dictionary.csv
- docs/eda/figs/distributions.png
- docs/eda/figs/missingness.png
- docs/eda/figs/target_analysis.png
</profile>
</handoff>
