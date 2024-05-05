#!/bin/bash

# Download and install the latest PostgreSQL client library
#sudo yum install -y postgresql
sudo dnf update -y
sudo dnf install postgresql15 -y

# Set the password as an environment variable
export PGPASSWORD=${DB_PASSWORD}

# Run psql command to create the "strapi-schema" schema
# Replace <psql_command> with the actual psql command
psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USERNAME} -d ${DB_NAME} -c "CREATE SCHEMA IF NOT EXISTS ${DB_SCHEMA};"
psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USERNAME} -d ${DB_NAME} -c "ALTER USER ${DB_USERNAME} SET search_path = ${DB_SCHEMA}, public;"
psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USERNAME} -d ${DB_NAME} -c "GRANT ALL PRIVILEGES ON SCHEMA ${DB_SCHEMA} TO ${DB_USERNAME};"

echo "Startup script execution completed.."