# Customer Care Emails Ingestion Pipeline

##  Purpose
This pipeline ingests **customer care email logs** from CSV files into a **PostgreSQL table** for downstream analysis.  
It ensures reproducibility, schema validation, and onboarding support for future engineers.

- **Dataset location**: `extraction/customer_care_emails/sample_data/customer_care_emails_sample.csv`
- **Target table**: `public.customer_care_emails`

---

##  Environment Setup

### Required Environment Variables
Reference `.env.sample` for values injected via Docker Compose:

```env
PG_HOST=postgres
PG_PORT=5432
PG_DB=airflow
PG_USER=airflow
PG_PASSWORD=airflow

# Running the Pipeline

## 1. Start Docker Compose
```bash
docker compose up -d
## 2. Initialize airflow
```bash
docker compose run airflow-init
## 3. Access airflow
   Open http://127.0.0.1:8081 and enable the DAG:
     DAG ID: customer_care_emails_ingest
## 4. Trigger DAG
   From the Airflow UI, click Trigger DAG. Tasks will run in sequence: file_check → validate_schema → transform → load
## 5. DAG Overview
  Task Flow:
  file_check → Ensures CSV exists.
  validate_schema → Confirms CSV columns match schema_expected.yaml.
  transform → Cleans whitespace, fills NaN, writes logs/cleaned.csv.
  load → Creates table (via create_table.sql) and inserts rows into Postgres.
## 6.Troubleshooting
   Common Errors
     Schema mismatch Error: Schema mismatch! Expected [...] got [...]
       → Update schema_expected.yaml or fix CSV headers.
     Missing CSV Error: FileNotFoundError: CSV file not found
       → Ensure sample_data/customer_care_emails_sample.csv exists.
     Invalid credentials Error: psycopg2.OperationalError: FATAL: password authentication failed
       → Check .env values and Docker Compose environment variables.
 ## 7. Resetting DAG Runs
    In Airflow UI, Clear DAG Runs → re‑trigger DAG.
    Or reset via CLI:
    ```bash
       docker exec -it <airflow-scheduler-container> airflow dags clear customer_care_emails_ingest --yes
## 8. Reloading Data
   Drop table if needed:
   ```sql
      DROP TABLE IF EXISTS public.customer_care_emails;
   Re‑run DAG to reload from full CSV.
## 9.  Runbook
   Updating Schema
   Modify config/schema_expected.yaml when dataset evolves.
   Update config/create_table.sql to match new schema.
   Re‑run DAG to apply changes.

   Rerunning with New CSV Drops
   Place new CSV in sample_data/.
   Trigger DAG again — pipeline will validate and load.

   Checklist Before Committing New Datasets
   [ ] Add dataset manifest.
   [ ] Update schema_expected.yaml.
   [ ] Update create_table.sql.
   [ ] Provide sample CSV in sample_data/.
   [ ] Verify DAG runs successfully end‑to‑end.

End‑to‑end reproducibility is guaranteed with the provided YAML, DDL, and sample CSV.
