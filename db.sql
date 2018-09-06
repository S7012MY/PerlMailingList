DROP TABLE emails CASCADE;
CREATE TABLE emails (
  email text NOT NULL,
  date_submitted timestamp NOT NULL,
  PRIMARY KEY (email)
);
