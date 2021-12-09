#!/usr/bin/env bash
# Configures the custom index template that will be used in the studysnap elasticsearch cluster

# Install pre-requisites (curl)
apk add --no-cache curl

if [[ -z $ES_HOST || -z $ES_PORT ]]; then
  echo "Please specify ES_HOST and ES_PORT in the environment"
  exit 1
fi

# Install wait-for-it
curl -o /pre-install/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/e1f115e4ca285c3c24e847c4dd4be955e0ed51c2/wait-for-it.sh 1> /dev/null
chmod 755 /pre-install/wait-for-it.sh
/pre-install/wait-for-it.sh $ES_HOST:$ES_PORT -s -t 300 -- echo "Elasticsearch service is up!"

if [[ $? -eq 143 ]]; then
  echo "Elasticsearch never came up..."
  exit 1
fi

curl "http://${ES_HOST}:${ES_PORT}/_cat/health" &> /dev/null
while [ $? -ne 0 ]; do
  echo "Elasticsearch not in a ready(green) state yet..."
  sleep 5
  curl "http://${ES_HOST}:${ES_PORT}/_cat/health" &> /dev/null
done

if [ $? -ne 0 ]; then
  echo "Elasticsearch service apparently never started... cannot continue."
  exit 1
fi

# All Data for requests
read -r -d '' ES_INDEX_TEMPLATE_CONFIG << EOM
  {
    "index_patterns": ["*notes*"],
    "priority": 1,
    "template": {
      "settings": { 
        "analysis": {
          "analyzer": {
            "insensitive_whitespace_analyzer": {
              "type": "custom", 
              "tokenizer": "standard",
              "char_filter": [
                "html_strip"
              ],
              "filter": [
                "lowercase",
                "asciifolding"
              ]
            }
          }
        }
      },
      "mappings": {
        "properties": {
          "title": {
            "type": "text",
            "analyzer": "insensitive_whitespace_analyzer"
          },
          "keywords": {
            "type": "text",
            "analyzer": "insensitive_whitespace_analyzer"
          },
          "short_description": {
            "type": "text",
            "analyzer": "insensitive_whitespace_analyzer"
          },
          "note_abstract": {
            "type": "text",
            "analyzer": "insensitive_whitespace_analyzer"
          }
        }
      }
    }
  }
EOM

# Create the ES Index Template
echo "deleting any existing index (matching: notes) ..."
curl -X DELETE "${ES_HOST}:${ES_PORT}/notes?pretty" -H "Content-Type: application/json" &> /dev/null
[[ $? -eq 0 ]] && echo "Done!"
echo "creating new index template with proper mappings ..."
curl -X PUT "${ES_HOST}:${ES_PORT}/_index_template/standard?pretty" -H "Content-Type: application/json" -d"${ES_INDEX_TEMPLATE_CONFIG}" &> /dev/null

if [[ $? -eq 0 ]]; then
  echo "Success!"
  exit 0
else
  echo "Error occurred when creating the index template ..."
  exit 1
fi
