#!/bin/bash

# # # # # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # 
# Created by Patrycja Sala on 15.12.2021 											 #
#																					 #	
# Automation of spatial data processing												 #
#																					 #
# This script provides downloading file with new customers data from URL, comparing  # 
# with existing data and inserting correct data to PostgreSQL database.				 #
# It finds the best customers based on distance from given location and sends 		 #
# reports about data and compressed csv file via email.								 #
# # # # # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # 

#variables

FILE_URL=https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip
ZIP_PASS=agh
WORKSPACE="`pwd`"
TIMESTAMP=`date +'%m-%d-%Y'`
INDEX_NR=400803
#directories
DOWNLOAD=${WORKSPACE}/download
TMP=${WORKSPACE}/tmp
PROCESSED=${WORKSPACE}/processed
OUTPUT=${WORKSPACE}/output
#files
ZIP=`basename ${FILE_URL}`
NAME=`basename ${FILE_URL} .zip`
FILE="${NAME}.csv"
OLD="input/Customers_old.csv"
BAD="${OUTPUT}/$NAME.bad_${TIMESTAMP}"
LOG_FILE=${PROCESSED}/`basename "$0"`_${TIMESTAMP}.log
TO_INSERT="toinsert.csv" 
TMP="tmp.csv"
#SQL
HOSTNAME="localhost"
PORT="5433"
USER="geo"
PASSWORD="geo"
DATABASE="customers"
JDBC_URL="postgresql://${USER}:${PASSWORD}@${HOSTNAME}:${PORT}/${DATABASE}"
TABLENAME="customers_${INDEX_NR}"
TABLENAME_BC="best_customers_${INDEX_NR}"

mkdir -p ${PROCESSED} ${DOWNLOAD} ${OUTPUT}
#create log file or overrite if already exists
if [ -e ${LOG_FILE} ]; then rm ${LOG_FILE}; fi
echo "Log File - `date +'%m-%d-%Y %H:%M:%S'`" > ${LOG_FILE}
#function to add info of the return value of a step to log file
log () {
	TIMESTAMP_HMS=`date +'%m-%d-%Y %H:%M:%S'`
	if [ "$1" -eq "0" ]
	then
	    echo "[${TIMESTAMP_HMS}] "$2" – successful " >> ${LOG_FILE}
	else
		echo "[${TIMESTAMP_HMS}] "$2" – unsuccessful " >> ${LOG_FILE}
	fi
}

#download data
wget -nv -q ${FILE_URL} -P ${DOWNLOAD}
log "$?" "Downloading data from ${FILE}_URL"
#unzip data
unzip -q -P ${ZIP_PASS} ${DOWNLOAD}/${ZIP} -d ${WORKSPACE}
log "$?" "Unzipping data"

#file validation (moving empty lines and duplicates to $BAD file)
awk 'NF == 0' ${FILE} > ${BAD} 
awk 'NF != 0' ${FILE} > ${TMP}
log "$?" "File validation: removing empty lines"
sort < ${OLD} > "$OLD.sor"
sort < ${TMP} > "$TMP.sor"
head -n 1 ${FILE} > ${TO_INSERT}
comm -13 ${OLD}.sor ${TMP}.sor >> ${TO_INSERT}
comm -2 ${OLD}.sor ${TMP}.sor >> ${BAD}
log "$?" "File validation: finding new customers"
rm ${TMP} ${OLD}.sor ${TMP}.sor #removing temporary files

#connect to database and create table
psql --quiet ${JDBC_URL} -c "\connect ${DATABASE}"
psql ${JDBC_URL} -c "create extension if not exists postgis;"
psql ${JDBC_URL} -c "create table if not exists $TABLENAME (first_name varchar(30), last_name varchar(30),email varchar(50), lat NUMERIC(8,6), lon NUMERIC(9,6) );"
log "$?" "Creating table $TABLENAME if not exists"

#insert data to table
psql ${JDBC_URL} -c "\copy ${TABLENAME} FROM ${TO_INSERT} delimiter ',' csv header;"
psql ${JDBC_URL} -c "ALTER TABLE ${TABLENAME} ADD COLUMN geom GEOMETRY(POINT, 4326);"
psql ${JDBC_URL} -c "UPDATE ${TABLENAME} SET geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);"
log "$?" "Inserting data from CSV file to the table ${TABLENAME}"

#move file to processed directory
mv ${FILE} "${PROCESSED}/${TIMESTAMP}_${FILE}"
log "$?" "Moving processed file"
FILE="${PROCESSED}/${TIMESTAMP}_${FILE}"

#send 1st email
rows=`tail -n +2 ${FILE} | wc -l`
correct_rows=`tail -n +2 ${TO_INSERT} | wc -l`
empty_lines=`awk 'NF == 0' ${FILE} | wc -l`
echo "Number of rows in downloaded file: `echo $rows`
Number of correct rows: `echo $correct_rows`
Number of duplicates: `echo $((rows-correct_rows-empty_lines))`
Number of inserted records to table ${TABLENAME}: `psql -X -A ${JDBC_URL} -t -c "select count(*) from ${TABLENAME};"`" \
| mailx -s "CUSTOMERS LOAD - ${TIMESTAMP}" patrycjasala5@gmail.com
log "$?" "Sending first email"
rm ${TO_INSERT}

#sql query to find the best customers
psql ${JDBC_URL} -c "drop table if exists ${TABLENAME_BC};"
query="select first_name, last_name into ${TABLENAME_BC} from ${TABLENAME}
	   where st_distancespheroid(
	       geom,
		   st_geomfromtext('POINT(-75.67329768604034 41.39988501005976)', 4326),
	   	   'SPHEROID["\""WGS 84"\"", 6378137, 298.257223563]')
	   < 50000; "
psql ${JDBC_URL} -c "${query}"
log "$?" "Creating table $TABLENAME_BC"

#export best customers table to CSV
SQL_TO_CSV="copy ${TABLENAME_BC} to stdout with (format csv, header);"
psql ${JDBC_URL} -c " ${SQL_TO_CSV}" > ${OUTPUT}/${TABLENAME_BC}.csv 
log "$?" "Exporting table ${TABLENAME_BC} to CSV"
#compress exported file
zip "${OUTPUT}/${TABLENAME_BC}.zip" "${OUTPUT}/${TABLENAME_BC}.csv"
log "$?" "Compressing "${TABLENAME_BC}.csv" file"

#send 2nd email
echo "Creation date: ${TIMESTAMP}
Number of rows: `tail -n +2 "${OUTPUT}/${TABLENAME_BC}.csv" | wc -l`" \
| mailx -a ${OUTPUT}/${TABLENAME_BC}.zip -s "BEST CUSTOMERS - ${TIMESTAMP}" patrycjasala5@gmail.com
log "$?" "Sending second email"


