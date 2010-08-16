PYTHONPATH=$pwd/whisper nohup ./bin/run-graphite-devel-server.py --libs=$pwd/webapp/ /usr/local/share/graphite/ >> ./storage/log/webapp/server.log 2>&1 &
PYTHONPATH=$pwd/whisper nohup ./carbon/bin/carbon-cache.py --debug start >> ./storage/log/carbon-cache/console.log 2>&1 &
