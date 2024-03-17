#********** Project Path *************
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype
cd ${PROJECT_PATH}

#********** CLEANUP *************
echo "Cleaning up all temp files and artifacts"
cd ${PROJECT_PATH}
make -s clean