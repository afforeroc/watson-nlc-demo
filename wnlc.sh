#!/bin/bash

# Files
CREDENTIALS_FILE="credentials.txt"
REGISTRY_FILE="registry.txt"

# Obtain credentials from credentials file
username=$(grep username $CREDENTIALS_FILE | awk -F"'" '{print $2}')
password=$(grep password $CREDENTIALS_FILE | awk -F"'" '{print $2}')

# Watson NLC Gateway
nlc_gateway="https://gateway.watsonplatform.net/natural-language-classifier/api/v1/classifiers"


if [ $1 == "-push" ]; then
	# Obtain parameters
	classifier_base_name=$2
	language=$3
	data_train_file=$4

	# Add two letters to classifier name
	two_lttrs=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 2 | head -n 1)
	classifier_name="${classifier_base_name}-${two_lttrs}"

	# Costruct metadata for request
	json_base="{\"language\":\"en\",\"name\":\"Classifier\"}"
	json=$(jq -c "{\"language\":\""${language/$'\r'/}"\",\"name\":\""${classifier_name/$'\r'/}"\"}"<<<"$json_base")
	metadata="$training_metadata=$json"

	# Construct training file
	trng_file="training_data=@${data_train_file}"
	
	# json response is separated in header and body
	response=$(curl -i --user "${username}":"${password}" -F "$trng_file" -F "$metadata" "${nlc_gateway}")
	header=$(echo "$response" | sed "/^\s*$(printf '\r')*$/q")
	body=$(echo "$response" | sed "1,/^\s*$(printf '\r')*$/d" | jq .)
	http_status=$(echo $header | grep HTTP/2 | awk {'print $2'})
	
	# if http_status is 200, then it is OK
	if [ $http_status == 200 ]; then
		echo $body | jq '.name'
		echo $body | jq '.classifier_id'
		echo $body | jq '.status'
		echo "${name}:${classifier_id}" >> $REGISTRY_FILE
	else
		echo "Bad request"
	fi

elif [ $1 == "-status" ]; then
	# Obtain parameters
	classifier_name=$2

	# Obtain the classifier id
	line=$(grep -F "$classifier_name" $REGISTRY_FILE)
	classifier_id=$(cut -d ":" -f 2 <<< "$line")

	# Obtain classifier status
	response=$(curl -i --user "${username}":"${password}" "${nlc_gateway}/${classifier_id}")
	header=$(echo "$response" | sed "/^\s*$(printf '\r')*$/q")
	body=$(echo "$response" | sed "1,/^\s*$(printf '\r')*$/d" | jq .)
	http_status=$(echo $header | grep HTTP/2 | awk {'print $2'})
	classifier_status=$(echo $data | jq '.status')

	# Output
	echo "classifier_name = ${classifier_name}"
	echo "classifier_id = ${classifier_id}"
	echo "classifier_status = ${classifier_status}"
elif [ $1 == "-test" ]; then
	# Obtain parameters
	classifier_name=$2
	TEST_FILE=$3

	# Obtain the classifier id
	line=$(grep -F "$classifier_name" $REGISTRY_FILE)
	classifier_id=$(cut -d ":" -f 2 <<< "$line")
	echo "$classifier_id"

	#Obtain text from test.txt
	line=$(head -n 1 $TEST_FILE)

	# Obtain text classification
	curl -G --user "${username}":"${password}" "${nlc_gateway}/${classifier_id}/classify" --data-urlencode "text=${line}"
fi
