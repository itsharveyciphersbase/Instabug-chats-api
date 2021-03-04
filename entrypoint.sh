until nc -z -v -w30 $DB_HOST 3306
do
  echo "Waiting for database connection..."
  # wait for 5 seconds before check again
  sleep 5
done
echo "MySQL is up and running"

bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:create db:migrate
echo "Database is ready!"

# Wait for Elasticsearch
# until nc -z -v -w30 $ELASTICSEARCH_HOST 9200
# do
#   echo 'Waiting for Elasticsearch...'
#   sleep 1
# done
# echo "Elasticsearch is up and running"

rails s -b 0.0.0.0