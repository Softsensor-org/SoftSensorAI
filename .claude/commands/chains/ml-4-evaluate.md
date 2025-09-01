# Chain: DS/ML Pipeline - Step 4/5 - EVALUATE

You are executing step 4 of 5 for DS/ML pipeline.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_MODEL_CARD_FROM_STEP_3}
</input>

<goal>
Generate comprehensive metrics table and diagnostic plots, saved to docs/metrics/.
</goal>

<plan>
- Load trained model and test data
- Calculate comprehensive metrics
- Generate diagnostic plots
- Compare against baseline
- Create performance report
</plan>

<work>
1. Comprehensive metrics calculation:
   ```python
   from sklearn.metrics import classification_report, confusion_matrix
   from sklearn.metrics import roc_auc_score, precision_recall_curve
   import matplotlib.pyplot as plt
   
   def evaluate_model(model, X_test, y_test):
       y_pred = model.predict(X_test)
       y_proba = model.predict_proba(X_test)[:, 1] if hasattr(model, 'predict_proba') else y_pred
       
       metrics = {
           # Classification metrics
           'accuracy': accuracy_score(y_test, y_pred),
           'precision': precision_score(y_test, y_pred, average='weighted'),
           'recall': recall_score(y_test, y_pred, average='weighted'),
           'f1': f1_score(y_test, y_pred, average='weighted'),
           'auc_roc': roc_auc_score(y_test, y_proba) if binary else None,
           
           # Regression metrics (if applicable)
           'rmse': np.sqrt(mean_squared_error(y_test, y_pred)),
           'mae': mean_absolute_error(y_test, y_pred),
           'r2': r2_score(y_test, y_pred),
           'mape': mean_absolute_percentage_error(y_test, y_pred)
       }
       
       return metrics
   ```

2. Diagnostic plots:
   ```python
   def create_diagnostic_plots(model, X_test, y_test):
       fig, axes = plt.subplots(2, 3, figsize=(15, 10))
       
       # 1. Confusion Matrix
       cm = confusion_matrix(y_test, y_pred)
       sns.heatmap(cm, annot=True, ax=axes[0,0])
       
       # 2. ROC Curve
       fpr, tpr, _ = roc_curve(y_test, y_proba)
       axes[0,1].plot(fpr, tpr)
       
       # 3. Precision-Recall Curve
       precision, recall, _ = precision_recall_curve(y_test, y_proba)
       axes[0,2].plot(recall, precision)
       
       # 4. Feature Importance
       if hasattr(model, 'feature_importances_'):
           importances = pd.Series(model.feature_importances_, index=feature_names)
           importances.nlargest(10).plot(kind='barh', ax=axes[1,0])
       
       # 5. Prediction Distribution
       axes[1,1].hist([y_test, y_pred], label=['Actual', 'Predicted'])
       
       # 6. Residuals (for regression)
       residuals = y_test - y_pred
       axes[1,2].scatter(y_pred, residuals)
       
       plt.savefig('docs/metrics/diagnostic_plots.png')
   ```

3. Performance comparison:
   ```python
   # Compare against baseline
   baseline_metrics = {'accuracy': 0.5, 'f1': 0.33}  # random baseline
   
   comparison = pd.DataFrame({
       'baseline': baseline_metrics,
       'current': current_metrics,
       'improvement': [(current_metrics[k] - baseline_metrics[k])/baseline_metrics[k] 
                       for k in baseline_metrics.keys()]
   })
   ```
</work>

<review>
- [ ] All relevant metrics calculated
- [ ] Diagnostic plots generated
- [ ] Comparison with baseline done
- [ ] Results saved to docs/metrics/
- [ ] Statistical significance tested (if applicable)
</review>

<handoff>
<eval>
## Evaluation Report

### Overall Performance
| Metric | Test Set | Val Set | Baseline | Improvement |
|--------|----------|---------|----------|-------------|
| Accuracy | 0.85 | 0.83 | 0.50 | +70% |
| F1 Score | 0.84 | 0.82 | 0.33 | +154% |
| AUC-ROC | 0.91 | 0.89 | 0.50 | +82% |

### Class-wise Performance
| Class | Precision | Recall | F1 | Support |
|-------|-----------|--------|-----|---------|
| Class 0 | 0.87 | 0.83 | 0.85 | 1000 |
| Class 1 | 0.83 | 0.87 | 0.85 | 1000 |

### Confusion Matrix
```
Predicted    0      1
Actual
0          830    170
1          130    870
```

### Feature Importance (Top 5)
1. feature_1: 0.25
2. feature_2: 0.18
3. engineered_ratio: 0.15
4. feature_3: 0.12
5. category_1_encoded: 0.08

### Statistical Tests
- McNemar's test vs baseline: p < 0.001 (significant improvement)
- Calibration: Brier score = 0.12 (well-calibrated)

### Files Created
- docs/metrics/evaluation_report.md
- docs/metrics/metrics.json
- docs/metrics/diagnostic_plots.png
- docs/metrics/confusion_matrix.png
- docs/metrics/roc_curve.png
- docs/metrics/feature_importance.png

### Key Insights
1. Model significantly outperforms baseline
2. Slight overfitting (train-test gap ~2%)
3. Good calibration for probability estimates
4. Feature_1 most important as expected
</eval>
</handoff>
