BEGIN TRANSACTION;
ROLLBACK

DROP TABLE IF EXISTS account, transfers, tenmo_user;

DROP SEQUENCE IF EXISTS seq_transfer_id, seq_user_id, seq_account_id;
DROP TYPE IF EXISTS status;
-- Sequence to start user_id values at 1001 instead of 1
CREATE SEQUENCE seq_user_id
  INCREMENT BY 1
  START WITH 1001
  NO MAXVALUE;

CREATE TABLE tenmo_user (
	user_id int NOT NULL DEFAULT nextval('seq_user_id'),
	username varchar(50) UNIQUE NOT NULL,
	password_hash varchar(200) NOT NULL,
	CONSTRAINT PK_tenmo_user PRIMARY KEY (user_id),
	CONSTRAINT UQ_username UNIQUE (username)
);

-- Sequence to start account_id values at 2001 instead of 1
-- Note: Use similar sequences with unique starting values for additional tables
CREATE SEQUENCE seq_account_id
  INCREMENT BY 1
  START WITH 2001
  NO MAXVALUE;

CREATE TABLE account (
	account_id int NOT NULL DEFAULT nextval('seq_account_id'),
	user_id int NOT NULL,
	balance numeric(13, 2) NOT NULL,
	CONSTRAINT PK_account PRIMARY KEY (account_id),
	CONSTRAINT FK_account_tenmo_user FOREIGN KEY (user_id) REFERENCES tenmo_user (user_id)
);

CREATE SEQUENCE seq_transfer_id
  INCREMENT BY 1
  START WITH 3001
  NO MAXVALUE;
  
CREATE TYPE status AS ENUM ('PENDING', 'APPROVED', 'DENIED');
  
CREATE TABLE transfers (
	transfer_id int NOT NULL DEFAULT nextval('seq_transfer_id'),
	transfer_status status NOT NULL,	
	sender_id int NOT NULL,
	receiver_id int NOT NULL,
	-- bigDecimal
	transfer_amount numeric(13, 2) NOT NULL,
	CONSTRAINT PK_transfer PRIMARY KEY (transfer_id),
	CONSTRAINT FK_transfer_account FOREIGN KEY
	(sender_id) REFERENCES account (account_id),
	CONSTRAINT FK_receiver_account FOREIGN KEY
	(receiver_id) references account(account_id)
);
COMMIT;
