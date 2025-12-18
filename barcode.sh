#!/usr/bin/env bash

# This script reads JSON data from stdin and generates barcodes for a BC driver's license and BCSC card.
# It requires 'jq' for JSON parsing and 'zint' for barcode generation.
# Usage: cat example.json | ./barcode.sh
# note: on mac run `open barcodes/license_barcode_pdf417.png` to view the barcode

if [[ -t 0 ]]; then
  echo "Usage: echo \"data\" | $0" >&2
  exit 1
fi

DATA="$(cat)"

if [[ -z "$DATA" ]]; then
  echo "Error: empty stdin" >&2
  exit 1
fi

LICENSE_NUMBER=$(jq -r '.licenseNumber' <<<"$DATA")
BCSC_SERIAL=$(jq -r '.bcscSerial' <<<"$DATA")
FIRST_NAME=$(jq -r '.firstName' <<<"$DATA")
LAST_NAME=$(jq -r '.lastName' <<<"$DATA")
MIDDLE_NAMES=$(jq -r '.middleNames' <<<"$DATA")
BIRTH_DATE=$(jq -r '.birthDate' <<<"$DATA")
STREET_ADDRESS=$(jq -r '.streetAddress' <<<"$DATA")
CITY=$(jq -r '.city' <<<"$DATA")
POSTAL_CODE=$(jq -r '.postalCode' <<<"$DATA")
PROVINCE=$(jq -r '.province' <<<"$DATA")
COUNTRY=$(jq -r '.country' <<<"$DATA")
EXPIRATION_YEAR=$(($(date +%y) + 5))
EXPIRATION_MONTH=$(date -j -f "%Y-%m-%d" "$BIRTH_DATE" +"%m")

DRIVERS_LICENSE_BARCODE="%${PROVINCE}${CITY}^${LAST_NAME},\$${FIRST_NAME} ${MIDDLE_NAMES}^${STREET_ADDRESS}\$${CITY} ${PROVINCE}  ${POSTAL_CODE}^?;636028${LICENSE_NUMBER}=${EXPIRATION_YEAR}${EXPIRATION_MONTH}${BIRTH_DATE//-/}${BCSC_SERIAL_NUMBER}=?_%0A${POSTAL_CODE// /}                     M185 95BRNBLU9123456789                E$''C(R2S6L?"
DRIVERS_LICENSE_COMBO_BARCODE="%${PROVINCE}${CITY}^${LAST_NAME},\$${FIRST_NAME} ${MIDDLE_NAMES}^${STREET_ADDRESS}\$${CITY} ${PROVINCE}  ${POSTAL_CODE}^?;636028${LICENSE_NUMBER}=${EXPIRATION_YEAR}${EXPIRATION_MONTH}${BIRTH_DATE//-/}${BCSC_SERIAL_NUMBER}=?_%0A${POSTAL_CODE// /}                     M185 95BRNBLU                00${BCSC_SERIAL}?"
BCSC_BARCODE=${BCSC_SERIAL}

echo "Generating barcodes..."

echo "Driver's License Barcode Data: $DRIVERS_LICENSE_BARCODE"
zint --barcode=pdf-417 --output=barcodes/license_barcode_pdf417.png --height=30 --data="$DRIVERS_LICENSE_BARCODE"

echo "Driver's License Combo Barcode Data: $DRIVERS_LICENSE_COMBO_BARCODE"
zint --barcode=pdf-417 --output=barcodes/license_combo_barcode_pdf417.png --height=30 --data="$DRIVERS_LICENSE_COMBO_BARCODE"

echo "BCSC Barcode Data IOS: $BCSC_BARCODE"
zint --barcode=code-39 --output=barcodes/bcsc_barcode_ios_code39.png --reverse --height=15 --data="$BCSC_BARCODE"

echo "BCSC Barcode Data Android: $BCSC_BARCODE"
zint --barcode=code-39 --output=barcodes/bcsc_barcode_android_code39.png --height=15 --data="$BCSC_BARCODE"

# const BC_COMBO_CARD_DL_BARCODE_NO_BCSC_A =
#   "%BCVICTORIA^SPECIMEN,$TEST CARD^910 GOVERNMENT ST$VICTORIA BC  V8W 3Y8^?;6360282222222=240919700906=?_%0AV8W3Y8                     M185 95BRNBLU9123456789                E$''C(R2S6L?"
# const BC_COMBO_CARD_DL_BARCODE_NO_BCSC_B =
#   '%BCVICTORIA^SPECIMEN,$TEST CARD^910 GOVERNMENT ST$VICTORIA BC  V8W 3Y8^?;6360282222222=250419470429=?_%0AV8W3Y8                     X160 57WHIBLU9123456789                E$!(\\0CUPXD?'
# const BC_COMBO_CARD_DL_BARCODE_WITH_BCSC_C =
#   '%BCVICTORIA^SPECIMEN,$TEST CARD^910 GOVERNMENT ST$VICTORIA BC  V8W 3Y8^?;6360282222222=260119820104=?_%0AV8W3Y8                     M185 88BRNBLU                          00S00023254?'
