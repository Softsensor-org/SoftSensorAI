# Chain: DS/ML Pipeline - Step 3/5 - MODEL

You are executing step 3 of 5 for DS/ML pipeline.

<context>
- OS: Linux (WSL/devcontainer). Node LTS + pnpm; Python .venv + pytest.
- Tools allowed: rg, jq, pnpm, pytest, docker, kubectl, helm.
- Conventions: small atomic diffs; tests-first for new behavior; link JIRA key in commits.
</context>

<input>
{PASTE_FEATURES_FROM_STEP_2}
</input>

<goal>
Create config-driven training script with fixed seeds, save artifacts under runs/{exp_name}.
</goal>

<plan>
- Implement configurable training pipeline
- Set all random seeds for reproducibility
- Track experiments with metrics logging
- Save models and configs
- Generate model card documentation
</plan>

<work>
1. Config-driven training script:
   ```python
   # config.yaml
   experiment:
     name: "baseline_v1"
     seed: 42
     
   model:
     type: "RandomForest"  # or "XGBoost", "LinearRegression"
     params:
       n_estimators: 100
       max_depth: 10
       random_state: 42
   
   training:
     epochs: 100  # for neural nets
     early_stopping_patience: 10
     batch_size: 32
   
   paths:
     data: "data/processed/"
     models: "runs/{exp_name}/models/"
     logs: "runs/{exp_name}/logs/"
   ```

2. Training pipeline:
   ```python
   import yaml
   import mlflow
   import joblib
   from datetime import datetime
   
   def train(config_path):
       # Load config
       with open(config_path) as f:
           config = yaml.safe_load(f)
       
       # Set seeds
       set_all_seeds(config['experiment']['seed'])
       
       # Setup MLflow
       mlflow.set_experiment(config['experiment']['name'])
       
       with mlflow.start_run():
           # Log config
           mlflow.log_params(flatten_dict(config))
           
           # Load data
           X_train, y_train = load_features(config['paths']['data'])
           
           # Train model
           model = create_model(config['model'])
           model.fit(X_train, y_train)
           
           # Validate
           metrics = evaluate(model, X_val, y_val)
           mlflow.log_metrics(metrics)
           
           # Save artifacts
           model_path = f"{config['paths']['models']}/model.pkl"
           joblib.dump(model, model_path)
           mlflow.log_artifact(model_path)
           
       return model, metrics
   ```

3. Reproducibility utilities:
   ```python
   def set_all_seeds(seed):
       random.seed(seed)
       np.random.seed(seed)
       torch.manual_seed(seed)
       torch.cuda.manual_seed_all(seed)
       os.environ['PYTHONHASHSEED'] = str(seed)
   ```
</work>

<self_check>
- Is training fully reproducible?
- Are all hyperparameters logged?
- Can I recreate this exact model later?
- Are artifacts organized clearly?
</self_check>

<review>
- [ ] Config file created
- [ ] Seeds set everywhere
- [ ] Metrics logged
- [ ] Model saved with version
- [ ] Training reproducible
</review>

<handoff>
<model_card>
## Model Card: {experiment_name}

**Version**: {version_hash}
**Date**: {training_date}
**Author**: {author}

### Model Details
- **Algorithm**: {RandomForest|XGBoost|etc}
- **Framework**: {scikit-learn 1.3.0}
- **Task**: {classification|regression}
- **Training time**: {duration}

### Training Data
- **Dataset**: {dataset_name}
- **Samples**: {n_train} train, {n_val} val
- **Features**: {n_features} ({n_numerical} numerical, {n_categorical} categorical)
- **Target**: {target_variable}

### Hyperparameters
```yaml
{model_hyperparameters}
```

### Performance
| Metric | Train | Val |
|--------|-------|-----|
| {primary_metric} | {value} | {value} |
| {secondary_metric} | {value} | {value} |

### Files Created
- `runs/{exp_name}/model.pkl` - Serialized model
- `runs/{exp_name}/config.yaml` - Full configuration
- `runs/{exp_name}/metrics.json` - All metrics
- `runs/{exp_name}/features.json` - Feature list
- `runs/{exp_name}/requirements.txt` - Dependencies

### Reproduction
```bash
python train.py --config runs/{exp_name}/config.yaml
```

### Notes
- {any_special_considerations}
- {known_limitations}
</model_card>
</handoff>
