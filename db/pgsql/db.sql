CREATE USER omnissiah WITH PASSWORD 'omnissiah';
CREATE DATABASE omnissiah OWNER omnissiah ENCODING UTF8;

CREATE USER hist WITH PASSWORD 'hist';
CREATE USER info WITH PASSWORD 'info';
CREATE USER main WITH PASSWORD 'main';
CREATE USER nnml WITH PASSWORD 'nnml';
CREATE USER raw WITH PASSWORD 'raw';
CREATE USER ref WITH PASSWORD 'ref';
CREATE USER shot WITH PASSWORD 'shot';
CREATE USER src WITH PASSWORD 'src';
CREATE USER zbx WITH PASSWORD 'zbx';

GRANT TEMPORARY ON DATABASE omnissiah TO hist;
GRANT TEMPORARY ON DATABASE omnissiah TO info;
GRANT TEMPORARY ON DATABASE omnissiah TO main;
GRANT TEMPORARY ON DATABASE omnissiah TO nnml;
GRANT TEMPORARY ON DATABASE omnissiah TO raw;
GRANT TEMPORARY ON DATABASE omnissiah TO ref;
GRANT TEMPORARY ON DATABASE omnissiah TO shot;
GRANT TEMPORARY ON DATABASE omnissiah TO src;
GRANT TEMPORARY ON DATABASE omnissiah TO zbx;


