#!/usr/bin/env bash
export $(grep -v '^#' .env | xargs)

#xhost +

docker run -d \
  --name qgis-testing-environment \
  -v  $(pwd)/../${PLUGIN_NAME}:/tests_directory/${PLUGIN_NAME} \
  -v  $(pwd)/../docs/processing:/processing \
  -e DISPLAY=:99 \
  -e QGIS_TESTING=True \
  qgis/qgis:release-3_10

sleep 10

echo "Setting up"
docker exec -t qgis-testing-environment sh -c "qgis_setup.sh ${PLUGIN_NAME}"
docker exec -t qgis-testing-environment sh \
  -c "qgis_testrunner.sh ${PLUGIN_NAME}.infra.processing_doc.generate_processing_doc"

docker kill qgis-testing-environment
docker rm qgis-testing-environment
