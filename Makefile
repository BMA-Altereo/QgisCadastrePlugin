start_tests:
	@echo 'Start docker-compose'
	@cd .docker && ./start.sh with-qgis

run_tests:
	@echo 'Running tests, containers must be running'
	@cd .docker && ./exec_tests.sh

stop_tests:
	@echo 'Stopping/killing containers'
	@cd .docker && ./stop.sh

tests: start_tests run_tests stop_tests
