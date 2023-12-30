deploy:
	bash azure_deploy.sh
start_airflow: deploy
	astro dev start
up: deploy start_airflow
down:
	 > .env && chmod -R 777 .env && az ad app delete --id $$(az ad app list --display-name "airflow-app" --query [0].id -o tsv) && az group delete --name "fbdataengineeringrg" --yes && astro dev kill