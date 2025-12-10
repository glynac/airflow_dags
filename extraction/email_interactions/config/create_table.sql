CREATE TABLE IF NOT EXISTS public.email_interactions (
  subject TEXT,
  sender TEXT,
  receiver TEXT,
  timestamp TIMESTAMP,
  message_text TEXT,
  thread_id TEXT NOT NULL,
  email_type TEXT,
  email_state TEXT,
  email_criticality TEXT,
  product_types TEXT,
  agent_effectivity TEXT,
  agent_efficiency TEXT,
  customer_satisfaction FLOAT,
  PRIMARY KEY (thread_id)
);
