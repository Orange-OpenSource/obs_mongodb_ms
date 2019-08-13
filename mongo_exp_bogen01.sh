# Third Party Software
# Mongo Backup Scripts – version 1.0
# Copyright © Orange Business Service – 2019 Guillaume CHARRIER
# Mongo Backup Scripts is distributed under the terms and conditions of the MIT license (http://spdx.org/licenses/MIT)
# You may download the source code on the following website https://github.com/

#  Input parameters :
#
#       MONGOBIN_PATH           : MongoDB Bin directory path
#       MONGO_BKP_DIR           : Location of MongoDB database backup directory
#       MONGO_PORT=27017        : Port no. on which MongoDB is running
#

# input parameters:
${MONGOBIN_PATH+"false"} && echo "MONGOBIN_PATH is unset" && exit 1
${MONGO_BKP_DIR+"false"} && echo "MONGO_BKP_DIR is unset" && exit 1
${MONGO_PORT+"false"} && echo "MONGO_PORT is unset" && exit 1

# derived parameters
MONGO_USER_BKP="yyyy"
MONGO_PASSWORD_BKP="xxxx"

echo "Export partiel de la base ocsauthent"
${MONGOBIN_PATH}/mongoexport --port $MONGO_PORT --username $MONGO_USER_BKP --password $MONGO_PASSWORD_BKP --authenticationDatabase admin --db ocsauthent --collection oauth_users --fields user_id,zuora_accountnumber,creationdate --type=csv --out $MONGO_BKP_DIR/users_export.csv
ret=$?
  if [ $ret -eq 0 ];then
        echo "Export MongoDB ocsauthent termine"
  else
        echo "Export MongoDB ocsauthent KO"
        exit 1
  fi

echo "Copie vers YYYY"
chmod g+rw $MONGO_BKP_DIR/users_export.csv
scp -i xxx.pem $MONGO_BKP_DIR/users_export.csv ocs@xxx:/yyyy
echo "Fin de copie "
