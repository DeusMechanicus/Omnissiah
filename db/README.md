# Databases
Omnissiah supports MariaDB and PostgreSQL as a database. Information for each DBMS is contained in the corresponding directory.
## Database layers
All tables are divided into groups, further called layers. Each layer has its own prefix. Each layer has its own purpose.
* cfg - onmissiah settings
* code - queries for processing the database by various programs
* log - work logs
* ref - various types of reference books
* info - source data not related to devices (IP subnets, MAC addresses, etc.)
* raw - raw data from various sources
* src - processed raw data from various sources
* nnml - everything related to neural networks and machine learning
* main - current state of the network and devices
* hist - accumulated history of network and device states
* zbx - synchronization with Zabbix
* tmp - temporary tables
## Naming rules
* SQL commands are written in capital letters
* all names (tables, fields, etc.) are written in non-capital letters
* in SQL queries, field names are used together with table names (table.field). If the query uses only one table, then the field names can be used without the table name
* table names contain layer prefix
* separation of prefixes, suffixes and names consisting of several words is done by the symbol _
* common prefixes and suffixes such as "id" are not separated by _
* identifier fields should contain the purpose in their name, for example "hostid" instead of just "id"
* using id as a field name is allowed if it is a local id for one table
* To create unique names (for example, for CONSTRAINT), a suffix with the first letters of the table name is added to the field name, for example programid_cpl for the programid field of the code_program_launch table
