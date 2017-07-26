#!/bin/sh

REP_FILE="~/cert_report.csv"

usage() {
    echo "Usage: $0 <file with IP addresses> <file with cert reports>" 1>&2
    exit 1
}

if [ $# -ne 2 ]
then
    usage
fi

infile=$1
outfile=$2

certs_to_check=`cat $infile`

for CERT in $certs_to_check
do

  output=$(echo | openssl s_client -connect ${CERT} 2>/dev/null |\
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' |\
    openssl x509 -noout -subject -dates 2>/dev/null)

  if [ "$?" -ne 0 ]; then
    echo "Error connecting to host for cert [$CERT]"
    continue
  fi

  start_date=$(echo $output | sed 's/.*notBefore=\(.*\).*not.*/\1/g')
  end_date=$(echo $output | sed 's/.*notAfter=\(.*\)$/\1/g')
  subject=$(echo $output | grep -e 'subject=.*[Tt][Ee][Ss][Tt]')

  if [ -z "$subject" ]; then
    continue
  fi

  # Create CSV file: IP;CN;END_DATE
  IP=$(echo $CERT | awk -F":" '{print $1}')
  SUBJ=$(echo $subject | grep -oP '(?<=CN=).*?(?=\s|$|\/)')
  ENDDATE=$(date +%d/%m/%Y -d "$end_date")

  echo $IP";"$SUBJ";"$ENDDATE >> $outfile

done

