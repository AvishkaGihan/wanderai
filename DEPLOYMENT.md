# Deployment Guide

This guide covers deploying WanderAI to production.

## Pre-Deployment Checklist

- [ ] Set `ENVIRONMENT=production` in `.env`
- [ ] Generate strong `SECRET_KEY`: `python -c "import secrets; print(secrets.token_urlsafe(32))"`
- [ ] Configure production database URL
- [ ] Set restricted `CORS_ORIGINS` (no `*` or `localhost`)
- [ ] Set up Sentry for error tracking
- [ ] Configure Firebase production credentials
- [ ] Update API endpoints in mobile app for production
- [ ] Test in staging environment first
- [ ] Set up database backups
- [ ] Configure SSL/TLS certificates

## Option 1: Docker with Docker Compose (Recommended for Small-Medium Projects)

### Production Environment File

Create `.env.prod`:

```env
ENVIRONMENT=production
DEBUG=false

# Database
DB_USER=wanderai_prod
DB_PASSWORD=<generate-strong-password>
DB_NAME=wanderai_prod
DATABASE_URL=postgresql://wanderai_prod:${DB_PASSWORD}@db:5432/wanderai_prod

# Redis
REDIS_PASSWORD=<generate-strong-password>
REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379

# Security
SECRET_KEY=<generate-with-secrets-module>

# API Keys
FIREBASE_PROJECT_ID=your-prod-firebase-project
FIREBASE_WEB_API_KEY=your-prod-firebase-key
GEMINI_API_KEY=your-prod-gemini-key
PEXELS_API_KEY=your-prod-pexels-key

# CORS - Specify your actual production domain
CORS_ORIGINS=https://app.example.com,https://www.example.com

# Monitoring
SENTRY_DSN=your-production-sentry-dsn

# Docker Registry
DOCKER_REGISTRY=ghcr.io/yourusername
APP_VERSION=1.0.0
```

### Deployment Steps

```bash
# 1. Build production Docker image
docker build -t wanderai-backend:1.0.0 ./backend

# 2. Tag and push to registry
docker tag wanderai-backend:1.0.0 ghcr.io/yourusername/wanderai-backend:1.0.0
docker push ghcr.io/yourusername/wanderai-backend:1.0.0

# 3. Deploy with docker-compose.prod.yml
docker-compose -f docker-compose.prod.yml up -d

# 4. Verify deployment
curl http://localhost:8000/health

# 5. View logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

## Option 2: Google Cloud Run (Serverless)

### Prerequisites

- Google Cloud account with billing enabled
- `gcloud` CLI installed and authenticated

### Deployment Steps

```bash
# 1. Set project ID
export PROJECT_ID=your-gcp-project-id

# 2. Build and push Docker image
gcloud builds submit --tag gcr.io/$PROJECT_ID/wanderai-backend --substitutions=_REGION=us-central1

# 3. Deploy to Cloud Run
gcloud run deploy wanderai-backend \
  --image gcr.io/$PROJECT_ID/wanderai-backend \
  --platform managed \
  --region us-central1 \
  --memory 512Mi \
  --cpu 1 \
  --allow-unauthenticated \
  --set-env-vars="ENVIRONMENT=production,DATABASE_URL=$DATABASE_URL,GEMINI_API_KEY=$GEMINI_API_KEY"

# 4. Get service URL
gcloud run services describe wanderai-backend --region us-central1
```

### Cloud SQL Setup (Recommended for Cloud Run)

```bash
# Create Cloud SQL instance
gcloud sql instances create wanderai-db \
  --database-version POSTGRES_16 \
  --tier db-f1-micro \
  --region us-central1

# Create database
gcloud sql databases create wanderai_prod --instance=wanderai-db

# Create user
gcloud sql users create wanderai_user --instance=wanderai-db --password=<strong-password>

# Get connection string for Cloud Run
# Format: postgresql://wanderai_user:password@/wanderai_prod?host=/cloudsql/PROJECT:REGION:INSTANCE
```

## Option 3: AWS ECS (Elastic Container Service)

### Prerequisites

- AWS account
- AWS CLI configured
- Docker image pushed to ECR

### Deployment Steps

```bash
# 1. Create ECR repository
aws ecr create-repository --repository-name wanderai-backend --region us-east-1

# 2. Get login token and push image
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com
docker tag wanderai-backend:1.0.0 123456789.dkr.ecr.us-east-1.amazonaws.com/wanderai-backend:1.0.0
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/wanderai-backend:1.0.0

# 3. Create ECS task definition (wanderai-task.json)
# See AWS documentation for detailed task definition

# 4. Create ECS service
aws ecs create-service \
  --cluster wanderai-cluster \
  --service-name wanderai-backend \
  --task-definition wanderai-backend:1 \
  --desired-count 1 \
  --launch-type FARGATE
```

## Option 4: DigitalOcean App Platform

### Deployment Steps

1. Push code to GitHub
2. Connect GitHub repository to DigitalOcean
3. Create `app.yaml` in repository root:

```yaml
name: wanderai
services:
  - name: backend
    github:
      repo: AvishkaGihan/wanderai
      branch: main
    build_command: pip install -r backend/requirements.txt
    run_command: uvicorn app.main:app --host 0.0.0.0 --port 8080
    source_dir: backend
    http_port: 8080
    env:
      - key: ENVIRONMENT
        value: production
      - key: DATABASE_URL
        scope: RUN_TIME
        value: ${db.connection_string}
databases:
  - name: db
    engine: PG
    version: "16"
```

4. Deploy through DigitalOcean dashboard

## Post-Deployment Verification

```bash
# Test health endpoint
curl https://your-domain.com/health

# Test API endpoints
curl https://your-domain.com/docs

# Check logs
docker-compose -f docker-compose.prod.yml logs backend

# Test database connection
curl https://your-domain.com/v1/auth/me \
  -H "Authorization: Bearer <test-token>"
```

## Monitoring & Maintenance

### Sentry Monitoring

1. Create account at https://sentry.io
2. Create new project for Python/FastAPI
3. Copy DSN to `SENTRY_DSN` environment variable
4. Errors will be automatically tracked

### Database Backups

#### Docker Compose Method

```bash
# Create backup
docker exec wanderai-db pg_dump -U postgres wanderai_prod > backup.sql

# Restore from backup
docker exec -i wanderai-db psql -U postgres wanderai_prod < backup.sql
```

#### Cloud SQL (GCP)

```bash
# Automated backups configured in GCP console
# Manual backup:
gcloud sql backups create --instance=wanderai-db
```

#### RDS (AWS)

```bash
# Automated backups through AWS console
# Manual snapshot:
aws rds create-db-snapshot --db-instance-identifier wanderai-db --db-snapshot-identifier backup-2025-01-01
```

### Scaling

#### Vertical Scaling (More Powerful Server)

```bash
# Update docker-compose resources
# Restart service
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

#### Horizontal Scaling (Multiple Instances)

- Use load balancer (Nginx, HAProxy)
- Deploy multiple instances behind load balancer
- Ensure stateless backend design

## Rollback Procedure

### Docker Compose Rollback

```bash
# Stop current deployment
docker-compose -f docker-compose.prod.yml down

# Roll back database (if needed)
docker exec -i wanderai-db psql -U postgres < backup.sql

# Start previous version
docker-compose -f docker-compose.prod.yml up -d

# Verify
curl https://your-domain.com/health
```

## Security Hardening

1. **SSL/TLS Certificates**

   - Use Let's Encrypt with Certbot
   - Auto-renew certificates

2. **Firewall Rules**

   - Only allow necessary ports (80, 443)
   - Restrict database access to backend only

3. **Rate Limiting**

   - Already implemented (100 req/min per IP)
   - Adjust `RATE_LIMIT_PER_MINUTE` as needed

4. **API Keys Rotation**

   - Rotate Gemini API key quarterly
   - Update Firebase credentials yearly

5. **Database Security**
   - Enable SSL connections
   - Use strong passwords
   - Regular security updates

## Troubleshooting

### Database Connection Issues

```bash
# Check connection string
echo $DATABASE_URL

# Test connection
docker exec wanderai-backend psql $DATABASE_URL -c "SELECT 1"
```

### High Error Rate

1. Check Sentry dashboard
2. Review application logs
3. Check database connection pool
4. Verify API keys are valid

### Out of Memory

1. Increase container memory limits
2. Check for memory leaks in application
3. Enable Redis for caching

### API Slow Response

1. Enable query profiling
2. Add database indexes
3. Check Redis cache hit rate
4. Scale horizontally

## Updating to New Version

```bash
# 1. Test in staging first
# 2. Build new image
docker build -t wanderai-backend:1.1.0 ./backend

# 3. Push to registry
docker push ghcr.io/yourusername/wanderai-backend:1.1.0

# 4. Update docker-compose.prod.yml with new version
# 5. Perform rolling update
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# 6. Run database migrations if needed
docker exec wanderai-backend alembic upgrade head

# 7. Verify health
curl https://your-domain.com/health
```

## Performance Optimization

### Database Optimization

```sql
-- Create indexes for frequently queried columns
CREATE INDEX idx_trips_user_id ON trips(user_id);
CREATE INDEX idx_expenses_trip_id ON expenses(trip_id);
CREATE INDEX idx_chat_messages_trip_id ON chat_messages(trip_id);

-- Enable connection pooling in production
-- Use PgBouncer for connection pooling
```

### Caching Strategy

- Redis caches destination data
- API responses cached when possible
- Cache invalidation on updates

### Load Testing

```bash
# Using Apache Bench
ab -n 1000 -c 100 https://your-domain.com/health

# Using wrk
wrk -t4 -c100 -d30s https://your-domain.com/health
```

---

For questions or issues, open a GitHub issue or contact the development team.
