CREATE TABLE IF NOT EXISTS emails (
  email text NOT NULL,
  date_submitted timestamp NOT NULL,
  PRIMARY KEY (email)
);

ALTER TABLE emails ADD COLUMN IF NOT EXISTS first_name text;

ALTER TABLE emails ADD COLUMN IF NOT EXISTS last_name text;
