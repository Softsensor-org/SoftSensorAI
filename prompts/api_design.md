# API Design

## Requirements
- **Context**: {{CONTEXT}}
- **SLO Targets**: {{SLO_TARGETS}}

## Design Principles
<principles>
- RESTful conventions
- Versioning strategy (URL vs header)
- Pagination for collections
- Consistent error responses
- HATEOAS where applicable
</principles>

## Response Structure
<response>
{
  "data": {},
  "meta": {
    "version": "v1",
    "timestamp": "ISO-8601"
  },
  "errors": []
}
</response>

## Error Handling
<errors>
- 400: Bad Request - validation errors
- 401: Unauthorized - missing/invalid auth
- 403: Forbidden - insufficient permissions
- 404: Not Found - resource doesn't exist
- 429: Too Many Requests - rate limited
- 500: Internal Server Error - unexpected
</errors>

## Security
<security>
- Authentication: Bearer token / API key
- Rate limiting: 100 req/min default
- CORS configuration
- Input validation
- SQL injection prevention
</security>
