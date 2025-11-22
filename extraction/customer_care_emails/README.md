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
```
# Running the Pipeline

## 1. Start Docker Compose
```bash
docker compose up -d
```
## 3. Access airflow
   -Open http://127.0.0.1:8081 
   -Add login credentials (Present in docker-compose.yml)
   -Enable the DAG:
     DAG ID: customer_care_emails_ingest
## 4. Trigger DAG
   -From the Airflow UI, click Trigger DAG.
   -Tasks will run in sequence: file_check → validate_schema → transform → load
## 5. DAG Overview
  Task Flow:
  -1. file_check → Ensures CSV exists.
  -2. validate_schema → Confirms CSV columns match schema_expected.yaml.
  -3. transform → Cleans whitespace, fills NaN, writes logs/cleaned.csv.
  -4. load → Creates table (via create_table.sql) and inserts rows into Postgres.
## 6.Troubleshooting
  -Schema mismatch Error: Schema mismatch! Expected [...] got [...]
    → Update schema_expected.yaml 
      accordingly with the help of code editor.
  -Missing CSV Error: FileNotFoundError: CSV file not found
    → Ensure sample_data/customer_care_emails_sample.csv exists.
  -Invalid credentials Error: psycopg2.OperationalError: FATAL: password authentication failed
    → Check .env values and Docker Compose environment variables.
       
 ## 7. Resetting DAG
   In Airflow UI, Clear DAG Runs → re‑trigger DAG.
## 8. Reloading Data
   Drop table if needed:
   ```sql
      DROP TABLE IF EXISTS public.customer_care_emails;
   ```
   Re‑run DAG to reload from full CSV.
## 9.  Runbook
  ### Updating Schema YAML or DDL When Dataset Evolves
     - Update schema_expected.yaml
     Open `extraction/customer_care_emails/config/schema_expected.yaml`.
     Add/remove/modify column definitions to match the new CSV headers.
     Example: If a new column priority_level is added:
   ```yaml
   - name: priority_level
     type: text
     nullable: true
   ```
   - Update create_table.sql
     Open extraction/customer_care_emails/config/create_table.sql.
     Add the same column definition in SQL:
   
   ```sql
   ALTER TABLE public.customer_care_emails ADD COLUMN priority_level TEXT;
   ```
   Or, if recreating from scratch:
   
   ```sql
   CREATE TABLE IF NOT EXISTS public.customer_care_emails (
     subject TEXT NOT NULL,
     sender TEXT NOT NULL,
     receiver TEXT NOT NULL,
     timestamp TIMESTAMPTZ NOT NULL,
     message_body TEXT,
     thread_id TEXT NOT NULL,
     email_types TEXT,
     email_status TEXT,
     email_criticality TEXT,
     product_types TEXT,
     agent_effectivity TEXT,
     agent_efficiency TEXT,
     customer_satisfaction FLOAT,
     priority_level TEXT
   );
   ```
   - Validate
      - Run the DAG again. 
      - The validate_schema task will check that the CSV headers match the YAML.
      - If mismatched, it will raise an error so you know to fix either the CSV or the YAML.
   
 - Rerunning with New CSV Drops
   - Place the new CSV
   - Copy the new file into:
   `extraction/customer_care_emails/sample_data/customer_care_emails_sample.csv`
   - Overwrite the old one, or keep multiple versions with different names if you want history.
   
Clear old DAG runs
   
   In Airflow UI: Select the DAG → Clear DAG Runs.
   
###Drop and recreate the table

   ```sql
   DROP TABLE IF EXISTS public.customer_care_emails;
  ```
   The DAG’s load task will recreate it using create_table.sql.
 
###Verify
   
   Connect to Postgres:
   
   ```bash
   psql -h postgres -U airflow -d airflow
  ```
   
###Checklist Before Committing New Datasets
  - [ ] Add dataset manifest.
  - [ ] Update schema_expected.yaml.
  - [ ] Update create_table.sql.
  - [ ] Provide sample CSV in sample_data/.
  - [ ] Verify DAG runs successfully end‑to‑end.
   
   End‑to‑end reproducibility is guaranteed with the provided YAML, DDL, and sample CSV.




