# Third Party Software
# Mongo Backup Scripts – version 1.0
# Copyright © Orange Business Service – 2019 Guillaume CHARRIER
# Mongo Backup Scripts is distributed under the terms and conditions of the MIT license (http://spdx.org/licenses/MIT)
# You may download the source code on the following website https://github.com/

TIMESTAMP=`date +%F-0300`
MONGO_BKP_NAME_PRFIX="mongobkp_"
MONGO_BKP_NAME="$MONGO_BKP_NAME_PRFIX$TIMESTAMP"   #Name current backup directory

echo "Copie de "$MONGO_BKP_NAME
chmod -R g+rwx /mongodata/4.0.5/backup/$MONGO_BKP_NAME
scp -ri xxx.pem /mongodata/4.0.5/backup/$MONGO_BKP_NAME  mongobackup@xxx:/mongodata/4.0.5/backup/import
echo "Fin de copie "
