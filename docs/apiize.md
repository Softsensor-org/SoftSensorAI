# SoftSensorAI Apiize: Model-to-API Conversion

Convert ML models into production-ready FastAPI services with a single command.

## Overview

`ssai apiize` transforms trained machine learning models into fully-functional REST APIs with:

- Automatic framework detection (PyTorch, ONNX, TensorFlow, Scikit-learn, XGBoost)
- FastAPI service with validation and error handling
- Docker containerization (including GPU support)
- Comprehensive test suite
- OpenAPI documentation
- Production-ready deployment configs

## Quick Start

```bash
# Convert a PyTorch model
ssai apiize from-model model.pt api_service

# Convert an ONNX model
ssai apiize from-model model.onnx my_api

# Convert a Scikit-learn model
ssai apiize from-model model.pkl prediction_service
```

## Supported Frameworks

| Framework    | Extensions        | GPU Support | Notes                      |
| ------------ | ----------------- | ----------- | -------------------------- |
| PyTorch      | `.pt`, `.pth`     | ✅          | Includes CUDA Docker image |
| ONNX         | `.onnx`           | ✅          | Cross-platform inference   |
| TensorFlow   | `.h5`, `.keras`   | ✅          | Keras/SavedModel formats   |
| Scikit-learn | `.pkl`, `.joblib` | ❌          | Joblib serialization       |
| XGBoost      | `.json`, `.xgb`   | ✅          | Native and JSON formats    |

## Generated Structure

```
api_service/
├── app/
│   ├── main.py          # FastAPI application
│   ├── models.py         # Pydantic schemas (if needed)
│   └── inference.py      # Model loading and prediction
├── models/
│   └── model.*           # Your model file(s)
├── tests/
│   └── test_api.py       # API test suite
├── docker/
│   ├── Dockerfile        # CPU container
│   └── Dockerfile.gpu    # GPU container (PyTorch/TF)
├── requirements.txt      # Python dependencies
├── docker-compose.yml    # Orchestration config
├── Makefile             # Common tasks
└── README.md            # API documentation
```

## API Endpoints

The generated service includes:

- `GET /` - Service information
- `GET /health` - Health check endpoint
- `POST /predict` - Model inference endpoint
- `GET /docs` - Interactive OpenAPI documentation

## Usage Examples

### Local Development

```bash
cd api_service

# Install dependencies
pip install -r requirements.txt

# Run locally
uvicorn app.main:app --reload

# Access API
curl http://localhost:8000/health
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"data": [[1.0, 2.0, 3.0]]}'
```

### Docker Deployment

```bash
# Build and run with Docker Compose
docker-compose up

# Or build manually
docker build -f docker/Dockerfile -t model-api .
docker run -p 8000:8000 model-api

# For GPU support (PyTorch)
docker build -f docker/Dockerfile.gpu -t model-api-gpu .
docker run --gpus all -p 8000:8000 model-api-gpu
```

### Testing

```bash
# Run tests
pytest tests/

# With coverage
pytest tests/ --cov=app --cov-report=html
```

## Customization

### Input/Output Schemas

Edit `app/main.py` to customize request/response models:

```python
class PredictRequest(BaseModel):
    data: List[List[float]]
    # Add your fields
    batch_size: Optional[int] = 32

class PredictResponse(BaseModel):
    predictions: List[Any]
    model_version: str = "1.0.0"
    # Add metadata
    confidence: Optional[List[float]] = None
```

### Model Loading

Framework-specific loading is auto-generated. Customize in `app/main.py`:

```python
def load_model():
    global model
    # Add preprocessing, device selection, etc.
    model = torch.load("models/model.pt", map_location=device)
    model.eval()
```

### Environment Configuration

Add environment variables to `docker-compose.yml`:

```yaml
environment:
  - LOG_LEVEL=INFO
  - MAX_BATCH_SIZE=32
  - MODEL_CACHE_SIZE=100
  - GPU_DEVICE_ID=0
```

## Production Considerations

### Scaling

For production deployments, consider:

1. **Horizontal scaling**: Deploy multiple replicas behind a load balancer
2. **Caching**: Add Redis for prediction caching
3. **Queue**: Use Celery/RabbitMQ for async processing
4. **Monitoring**: Add Prometheus metrics and Grafana dashboards

### Security

1. **Authentication**: Add API key or OAuth2
2. **Rate limiting**: Implement request throttling
3. **Input validation**: Strict schema validation
4. **CORS**: Configure allowed origins

Example with FastAPI security:

```python
from fastapi.security import APIKeyHeader

api_key_header = APIKeyHeader(name="X-API-Key")

@app.post("/predict")
async def predict(request: PredictRequest, api_key: str = Depends(api_key_header)):
    if api_key != os.getenv("API_KEY"):
        raise HTTPException(status_code=403, detail="Invalid API key")
    # ... prediction logic
```

### Model Updates

Implement zero-downtime model updates:

1. Version your models: `models/v1/`, `models/v2/`
2. Load new model in background
3. Atomic swap when ready
4. Keep old version for rollback

```python
async def update_model(version: str):
    new_model = load_model_version(version)
    # Validate new model
    test_predictions = new_model.predict(test_data)
    # Swap if valid
    global model
    old_model = model
    model = new_model
    # Cleanup
    del old_model
```

## Integration Examples

### With SoftSensorAI Agent

```bash
# Create agent task for model deployment
ssai agent new "Deploy the trained model as an API service"

# Agent will use apiize automatically
ssai agent run --id <task-id>
```

### In CI/CD Pipeline

```yaml
# .github/workflows/deploy-model.yml
steps:
  - name: Convert Model to API
    run: ssai apiize from-model model.pt api_service

  - name: Build Docker Image
    run: docker build -f api_service/docker/Dockerfile -t model-api:${{ github.sha }}

  - name: Push to Registry
    run: docker push registry.example.com/model-api:${{ github.sha }}
```

## Troubleshooting

### Common Issues

1. **Model not loading**: Check file path and framework version compatibility
2. **Out of memory**: Reduce batch size or use model quantization
3. **Slow inference**: Enable GPU, use ONNX, or implement batching
4. **Docker build fails**: Ensure base image matches your Python version

### Debug Mode

Enable detailed logging:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

Or via environment:

```bash
LOG_LEVEL=DEBUG uvicorn app.main:app
```

## Advanced Features

### Batch Processing

The generated API supports batch predictions by default:

```python
# Send multiple samples
{
  "data": [
    [1.0, 2.0, 3.0],
    [4.0, 5.0, 6.0],
    [7.0, 8.0, 9.0]
  ]
}
```

### Model Ensemble

Combine multiple models:

```python
models = {
    "model1": load_model("models/model1.pt"),
    "model2": load_model("models/model2.pt")
}

@app.post("/predict")
async def predict(request: PredictRequest):
    results = []
    for name, model in models.items():
        pred = model.predict(request.data)
        results.append(pred)
    # Aggregate predictions
    return {"predictions": aggregate(results)}
```

### A/B Testing

Implement model comparison:

```python
import random

@app.post("/predict")
async def predict(request: PredictRequest):
    # Route to different models
    if random.random() < 0.1:  # 10% to new model
        model = model_v2
        version = "v2"
    else:
        model = model_v1
        version = "v1"

    predictions = model.predict(request.data)

    # Log for analysis
    logger.info(f"Prediction with {version}: {predictions}")

    return {
        "predictions": predictions,
        "model_version": version
    }
```

## Related Commands

- `ssai agent` - Create tasks for model training/deployment
- `ssai review` - Review API implementation
- `ssai sandbox` - Test API in isolated environment

## Support

For issues or feature requests, see:

- [GitHub Issues](https://github.com/softsensorai/softsensorai/issues)
- [Documentation](https://softsensorai.dev/docs)
